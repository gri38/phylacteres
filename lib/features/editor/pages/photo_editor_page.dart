import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../theme/app_colors.dart';
import '../models/speech_bubble.dart';
import '../services/bubble_renderer.dart';
import '../services/bubble_layout_registry.dart';
import '../services/image_codec_service.dart';
import '../services/photo_persistence_service.dart';
import '../widgets/bubble_picker_sheet.dart';
import '../widgets/busy_overlay.dart';
import '../widgets/bubble_text_editing_controller.dart';
import '../widgets/editor_canvas.dart';
import '../widgets/editor_empty_state.dart';
import '../widgets/editor_toolbar.dart';
import '../widgets/text_toolbox.dart';
import 'crop_editor_page.dart';

class PhotoEditorPage extends StatefulWidget {
  const PhotoEditorPage({super.key});

  @override
  State<PhotoEditorPage> createState() => _PhotoEditorPageState();
}

class _PhotoEditorPageState extends State<PhotoEditorPage> {
  final ImagePicker _picker = ImagePicker();
  final ImageCodecService _imageCodecService = const ImageCodecService();
  final PhotoPersistenceService _photoPersistenceService =
      const PhotoPersistenceService();
  final TransformationController _transformationController =
      TransformationController();
  final GlobalKey _canvasKey = GlobalKey();
  final BubbleTextEditingController _bubbleTextController =
      BubbleTextEditingController();
  final FocusNode _bubbleTextFocusNode = FocusNode();

  Uint8List? _workingImageBytes;
  Size? _imageSize;
  String? _sourceImagePath;
  String _sourceExtension = '.jpg';
  List<SpeechBubbleData> _bubbles = const <SpeechBubbleData>[];
  String? _selectedBubbleId;
  String? _editingBubbleId;
  bool _isBusy = false;
  String _busyLabel = 'Traitement…';
  int _bubbleSeed = 0;
  _BubbleGestureSession? _activeBubbleGesture;
  TextSelection? _lastKnownEditingSelection;

  bool get _hasImage => _workingImageBytes != null && _imageSize != null;

  SpeechBubbleData? get _selectedBubble {
    final bubbleId = _selectedBubbleId;
    if (bubbleId == null) {
      return null;
    }
    for (final bubble in _bubbles) {
      if (bubble.id == bubbleId) {
        return bubble;
      }
    }
    return null;
  }

  bool get _isEditingSelectedBubble =>
      _editingBubbleId != null && _editingBubbleId == _selectedBubbleId;

  @override
  void initState() {
    super.initState();
    BubbleLayoutRegistry.instance.ensureLoaded();
    _bubbleTextController.addListener(_handleInlineTextChanged);
  }

  @override
  void dispose() {
    _bubbleTextController.dispose();
    _bubbleTextFocusNode.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted || picked == null) {
      return;
    }

    await _runBusy('Chargement de la photo…', () async {
      _stopEditingText();
      final extension = _imageCodecService.normalizedExtension(
        p.extension(picked.path),
      );
      final sourceBytes = await picked.readAsBytes();
      final normalizedBytes = await _imageCodecService.normalizeSourceBytes(
        sourceBytes,
        extension,
      );
      final size = await _imageCodecService.decodeImageSize(normalizedBytes);

      setState(() {
        _workingImageBytes = normalizedBytes;
        _imageSize = size;
        _sourceImagePath = picked.path;
        _sourceExtension = extension;
        _bubbles = const <SpeechBubbleData>[];
        _selectedBubbleId = null;
        _editingBubbleId = null;
      });
      _resetPhotoZoom();
    });
  }

  Future<void> _openBubblePicker() async {
    if (!_hasImage) {
      _showMessage('Chargez une photo avant d’ajouter une bulle.');
      return;
    }

    final template = await _showBubblePicker();

    if (!mounted || template == null) {
      return;
    }

    final bubble = template.createBubble(bubbleId: 'bubble_${_bubbleSeed++}');
    setState(() {
      _bubbles = [..._bubbles, bubble];
      _selectedBubbleId = bubble.id;
      _editingBubbleId = null;
    });
  }

  Future<BubbleTemplate?> _showBubblePicker() {
    return showModalBottomSheet<BubbleTemplate>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const BubblePickerSheet(),
    );
  }

  Future<void> _changeSelectedBubbleShape() async {
    final selectedBubble = _selectedBubble;
    if (selectedBubble == null) {
      return;
    }

    _stopEditingText();
    final template = await _showBubblePicker();
    if (!mounted || template == null) {
      return;
    }

    setState(() {
      _bubbles = _bubbles.map((bubble) {
        if (bubble.id != selectedBubble.id) {
          return bubble;
        }
        return bubble.copyWith(
          shape: template.shape,
          tailStyle: template.tailStyle,
          assetPath: template.assetPath,
        );
      }).toList();
    });
  }

  void _startEditingSelectedBubble() {
    final bubble = _selectedBubble;
    if (bubble == null) {
      return;
    }

    if (_editingBubbleId == bubble.id) {
      return;
    }

    _bubbleTextController.value = TextEditingValue(
      text: bubble.text,
      selection: TextSelection.collapsed(offset: bubble.text.length),
    );
    _lastKnownEditingSelection = _bubbleTextController.selection;

    setState(() {
      _editingBubbleId = bubble.id;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _bubbleTextFocusNode.requestFocus();
      }
    });
  }

  void _stopEditingText() {
    if (_editingBubbleId == null) {
      return;
    }
    _bubbleTextFocusNode.unfocus();
    _bubbleTextController.styledSpanBuilder = null;
    _lastKnownEditingSelection = null;
    setState(() {
      _editingBubbleId = null;
    });
  }

  void _handleInlineTextChanged() {
    final editingId = _editingBubbleId;
    if (editingId == null) {
      return;
    }

    if (_bubbleTextController.selection.isValid) {
      _lastKnownEditingSelection = _bubbleTextController.selection;
    }

    setState(() {
      _bubbles = _bubbles.map((bubble) {
        if (bubble.id != editingId) {
          return bubble;
        }
        return bubble.copyWith(text: _bubbleTextController.text);
      }).toList();
    });
  }

  void _toggleTailVertical() {
    _updateSelectedBubble(
      (bubble) => bubble.copyWith(tailOnTop: !bubble.tailOnTop),
    );
  }

  void _toggleTailHorizontal() {
    _updateSelectedBubble(
      (bubble) => bubble.copyWith(tailOnLeft: !bubble.tailOnLeft),
    );
  }

  Future<void> _openCropEditor() async {
    if (!_hasImage) {
      return;
    }

    _stopEditingText();

    final cropRect = await Navigator.of(context).push<Rect>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => CropEditorPage(
          imageBytes: _workingImageBytes!,
          imageSize: _imageSize!,
        ),
      ),
    );

    if (!mounted || cropRect == null) {
      return;
    }

    await _applyCrop(cropRect);
  }

  Future<void> _applyCrop(Rect normalizedCropRect) async {
    if (!_hasImage) {
      return;
    }

    await _runBusy('Application du crop…', () async {
      final decoded = img.decodeImage(_workingImageBytes!);
      if (decoded == null) {
        throw StateError('Impossible de lire l’image courante.');
      }

      final cropRect = Rect.fromLTWH(
        (normalizedCropRect.left.clamp(0.0, 1.0) as num).toDouble(),
        (normalizedCropRect.top.clamp(0.0, 1.0) as num).toDouble(),
        (normalizedCropRect.width.clamp(0.05, 1.0) as num).toDouble(),
        (normalizedCropRect.height.clamp(0.05, 1.0) as num).toDouble(),
      );

      final x = (cropRect.left * decoded.width).round().clamp(
        0,
        decoded.width - 1,
      );
      final y = (cropRect.top * decoded.height).round().clamp(
        0,
        decoded.height - 1,
      );
      final width = (cropRect.width * decoded.width).round().clamp(
        1,
        decoded.width - x,
      );
      final height = (cropRect.height * decoded.height).round().clamp(
        1,
        decoded.height - y,
      );

      final cropped = img.copyCrop(
        decoded,
        x: x,
        y: y,
        width: width,
        height: height,
      );
      final nextBytes = Uint8List.fromList(
        _imageCodecService.encodeRaster(cropped, _sourceExtension),
      );
      final nextBubbles = _transformBubblesAfterCrop(cropRect);

      setState(() {
        _workingImageBytes = nextBytes;
        _imageSize = Size(width.toDouble(), height.toDouble());
        _bubbles = nextBubbles;
        _selectedBubbleId =
            nextBubbles.any((bubble) => bubble.id == _selectedBubbleId)
            ? _selectedBubbleId
            : null;
      });
      _resetPhotoZoom();
    });
  }

  List<SpeechBubbleData> _transformBubblesAfterCrop(Rect cropRect) {
    final transformed = <SpeechBubbleData>[];

    for (final bubble in _bubbles) {
      final bubbleBounds = Rect.fromCenter(
        center: bubble.center,
        width: bubble.widthFactor,
        height: bubble.heightFactor,
      );
      if (!bubbleBounds.overlaps(cropRect)) {
        continue;
      }

      final newCenter = Offset(
        (bubble.center.dx - cropRect.left) / cropRect.width,
        (bubble.center.dy - cropRect.top) / cropRect.height,
      );

      final newWidth = bubble.widthFactor / cropRect.width;
      final newHeight = bubble.heightFactor / cropRect.height;

      transformed.add(
        bubble.copyWith(
          center: Offset(
            (newCenter.dx.clamp(0.0, 1.0) as num).toDouble(),
            (newCenter.dy.clamp(0.0, 1.0) as num).toDouble(),
          ),
          widthFactor: (newWidth.clamp(0.08, 1.4) as num).toDouble(),
          heightFactor: (newHeight.clamp(0.08, 1.2) as num).toDouble(),
        ),
      );
    }

    return transformed;
  }

  Future<void> _saveRenderedImage() async {
    if (!_hasImage || _sourceImagePath == null) {
      _showMessage('Aucune photo à enregistrer.');
      return;
    }

    _stopEditingText();

    final outputExtension = _sourceExtension == '.png' ? '.png' : '.jpg';
    final targetPath = _photoPersistenceService.buildSiblingPath(
      _sourceImagePath!,
      outputExtension,
    );

    final saved = await _runBusy('Enregistrement de la photo…', () async {
      final bytes = await BubbleRenderer.renderCompositedImage(
        baseImageBytes: _workingImageBytes!,
        baseSize: _imageSize!,
        bubbles: _bubbles,
        extension: outputExtension,
      );
      await _photoPersistenceService.saveBytes(
        bytes: bytes,
        targetPath: targetPath,
      );
    });

    if (!mounted || !saved) {
      return;
    }

    _showMessage('Nouvelle image enregistrée à côté de l’originale.');
  }

  void _applyFontChange(BubbleFontOption font) {
    final selection = _selectionForStyleUpdate();
    _updateSelectedBubble(
      (bubble) => bubble.applyFontStyle(font, selection: selection),
    );
    _restoreEditingTextFocus();
  }

  void _applyTextColorChange(Color color) {
    final selection = _selectionForStyleUpdate();
    _updateSelectedBubble(
      (bubble) => bubble.applyTextColorStyle(color, selection: selection),
    );
    _restoreEditingTextFocus();
  }

  TextSelection? _selectionForStyleUpdate() {
    if (!_isEditingSelectedBubble) {
      return null;
    }
    final selection = _bubbleTextController.selection;
    return selection.isValid ? selection : _lastKnownEditingSelection;
  }

  void _restoreEditingTextFocus() {
    if (!_isEditingSelectedBubble) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _bubbleTextFocusNode.requestFocus();
      final selection = _lastKnownEditingSelection;
      if (selection != null && selection.isValid) {
        _bubbleTextController.selection = selection;
      }
    });
  }

  void _handleBubbleTap(String bubbleId) {
    if (_selectedBubbleId == bubbleId) {
      _startEditingSelectedBubble();
      return;
    }

    _stopEditingText();
    setState(() {
      _selectedBubbleId = bubbleId;
      _editingBubbleId = null;
    });
  }

  void _handleBubbleScaleStart(
    SpeechBubbleData bubble,
    ScaleStartDetails details,
    Size displaySize,
  ) {
    _stopEditingText();
    final centerPixels = Offset(
      bubble.center.dx * displaySize.width,
      bubble.center.dy * displaySize.height,
    );

    setState(() {
      _selectedBubbleId = bubble.id;
      _activeBubbleGesture = _BubbleGestureSession(
        bubbleId: bubble.id,
        startFocalPoint: _globalToCanvas(details.focalPoint),
        startCenterPixels: centerPixels,
        startWidthFactor: bubble.widthFactor,
        startHeightFactor: bubble.heightFactor,
        startRotation: bubble.rotation,
      );
    });
  }

  void _handleBubbleScaleUpdate(
    SpeechBubbleData bubble,
    ScaleUpdateDetails details,
    Size displaySize,
  ) {
    final session = _activeBubbleGesture;
    if (session == null || session.bubbleId != bubble.id) {
      return;
    }

    final currentFocal = _globalToCanvas(details.focalPoint);
    final delta = currentFocal - session.startFocalPoint;
    final centerPixels = session.startCenterPixels + delta;

    final nextWidthFactor =
        ((session.startWidthFactor * details.scale).clamp(0.12, 1.4) as num)
            .toDouble();
    final nextHeightFactor =
        ((session.startHeightFactor * details.scale).clamp(0.1, 1.2) as num)
            .toDouble();
    final halfWidth = nextWidthFactor / 2;
    final halfHeight = nextHeightFactor / 2;

    final nextCenter = Offset(
      ((centerPixels.dx / displaySize.width).clamp(halfWidth, 1 - halfWidth)
              as num)
          .toDouble(),
      ((centerPixels.dy / displaySize.height).clamp(halfHeight, 1 - halfHeight)
              as num)
          .toDouble(),
    );

    setState(() {
      _bubbles = _bubbles.map((item) {
        if (item.id != bubble.id) {
          return item;
        }
        return item.copyWith(
          center: nextCenter,
          widthFactor: nextWidthFactor,
          heightFactor: nextHeightFactor,
          rotation: session.startRotation + details.rotation,
        );
      }).toList();
    });
  }

  void _handleBubbleScaleEnd() {
    _activeBubbleGesture = null;
  }

  void _clearSelection() {
    if (_selectedBubbleId == null) {
      return;
    }
    _stopEditingText();
    setState(() {
      _selectedBubbleId = null;
      _editingBubbleId = null;
    });
  }

  void _removeSelectedBubble() {
    final bubbleId = _selectedBubbleId;
    if (bubbleId == null) {
      return;
    }

    _stopEditingText();
    setState(() {
      _bubbles = _bubbles.where((bubble) => bubble.id != bubbleId).toList();
      _selectedBubbleId = null;
      _editingBubbleId = null;
    });
  }

  void _updateSelectedBubble(
    SpeechBubbleData Function(SpeechBubbleData bubble) update,
  ) {
    final bubbleId = _selectedBubbleId;
    if (bubbleId == null) {
      return;
    }

    setState(() {
      _bubbles = _bubbles.map((bubble) {
        if (bubble.id != bubbleId) {
          return bubble;
        }
        return update(bubble);
      }).toList();
    });
  }

  void _resetPhotoZoom() {
    _transformationController.value = Matrix4.identity();
  }

  Offset _globalToCanvas(Offset globalPosition) {
    final context = _canvasKey.currentContext;
    if (context == null) {
      return Offset.zero;
    }
    final renderBox = context.findRenderObject() as RenderBox;
    return renderBox.globalToLocal(globalPosition);
  }

  Future<bool> _runBusy(String label, Future<void> Function() action) async {
    setState(() {
      _isBusy = true;
      _busyLabel = label;
    });

    try {
      await action();
      return true;
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString().replaceFirst('Exception: ', ''));
      }
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
          _busyLabel = 'Traitement…';
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final selectedBubble = _selectedBubble;
    final isEditingText = _isEditingSelectedBubble;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phylactère'),
        actions: [
          IconButton(
            onPressed: _hasImage ? _resetPhotoZoom : null,
            tooltip: 'Réinitialiser le zoom photo',
            icon: const Icon(Icons.center_focus_strong),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.canvasBackdrop,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: _hasImage
                          ? EditorCanvas(
                              imageBytes: _workingImageBytes!,
                              imageSize: _imageSize!,
                              bubbles: _bubbles,
                              selectedBubbleId: _selectedBubbleId,
                              selectedBubble: selectedBubble,
                              isEditingText: isEditingText,
                              textController: _bubbleTextController,
                              textFocusNode: _bubbleTextFocusNode,
                              transformationController:
                                  _transformationController,
                              canvasKey: _canvasKey,
                              onClearSelection: _clearSelection,
                              onBubbleTap: _handleBubbleTap,
                              onBubbleScaleStart: _handleBubbleScaleStart,
                              onBubbleScaleUpdate: _handleBubbleScaleUpdate,
                              onBubbleScaleEnd: _handleBubbleScaleEnd,
                              onChangeShape: _changeSelectedBubbleShape,
                              onFlipHorizontal: _toggleTailHorizontal,
                              onFlipVertical: _toggleTailVertical,
                              onDeleteSelectedBubble: _removeSelectedBubble,
                            )
                          : EditorEmptyState(onPickImage: _pickImage),
                    ),
                  ),
                ),
                if (selectedBubble != null && !isEditingText)
                  BubbleTextToolbox(
                    bubble: selectedBubble,
                    onFontChanged: _applyFontChange,
                    onTextColorChanged: _applyTextColorChange,
                    onFontScaleChanged: (value) => _updateSelectedBubble(
                      (bubble) => bubble.copyWith(fontScaleFactor: value),
                    ),
                    onTextAlignChanged: (alignment) => _updateSelectedBubble(
                      (bubble) => bubble.copyWith(textAlign: alignment),
                    ),
                  ),
                EditorToolbar(
                  hasImage: _hasImage,
                  onPickImage: _pickImage,
                  onAddBubble: _openBubblePicker,
                  onCrop: _openCropEditor,
                  onSave: _saveRenderedImage,
                ),
              ],
            ),
            if (_isBusy) BusyOverlay(label: _busyLabel),
          ],
        ),
      ),
    );
  }

}

class _BubbleGestureSession {
  const _BubbleGestureSession({
    required this.bubbleId,
    required this.startFocalPoint,
    required this.startCenterPixels,
    required this.startWidthFactor,
    required this.startHeightFactor,
    required this.startRotation,
  });

  final String bubbleId;
  final Offset startFocalPoint;
  final Offset startCenterPixels;
  final double startWidthFactor;
  final double startHeightFactor;
  final double startRotation;
}

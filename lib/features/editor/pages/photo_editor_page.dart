import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../theme/app_colors.dart';
import '../models/speech_bubble.dart';
import '../models/text_sticker.dart';
import '../services/bubble_layout_registry.dart';
import '../services/bubble_renderer.dart';
import '../services/image_codec_service.dart';
import '../services/photo_persistence_service.dart';
import '../widgets/bubble_picker_sheet.dart';
import '../widgets/bubble_text_editing_controller.dart';
import '../widgets/busy_overlay.dart';
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
  List<TextStickerData> _textItems = const <TextStickerData>[];
  String? _selectedBubbleId;
  String? _selectedTextItemId;
  String? _editingBubbleId;
  String? _editingTextItemId;
  bool _isBusy = false;
  String _busyLabel = 'Traitement…';
  int _bubbleSeed = 0;
  int _textItemSeed = 0;
  _EditorGestureSession? _activeGesture;
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

  TextStickerData? get _selectedTextItem {
    final textItemId = _selectedTextItemId;
    if (textItemId == null) {
      return null;
    }
    for (final textItem in _textItems) {
      if (textItem.id == textItemId) {
        return textItem;
      }
    }
    return null;
  }

  bool get _isEditingSelectedBubble =>
      _editingBubbleId != null && _editingBubbleId == _selectedBubbleId;

  bool get _isEditingSelectedTextItem =>
      _editingTextItemId != null && _editingTextItemId == _selectedTextItemId;

  bool get _isEditingSelectedElement =>
      _isEditingSelectedBubble || _isEditingSelectedTextItem;

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
        _textItems = const <TextStickerData>[];
        _selectedBubbleId = null;
        _selectedTextItemId = null;
        _editingBubbleId = null;
        _editingTextItemId = null;
      });
      _resetPhotoZoom();
    });
  }

  Future<void> _openBubblePicker() async {
    if (!_hasImage) {
      _showMessage('Chargez une photo avant d’ajouter un phylactère.');
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
      _selectedTextItemId = null;
      _editingBubbleId = null;
      _editingTextItemId = null;
    });
  }

  void _addTextItem() {
    if (!_hasImage) {
      _showMessage('Chargez une photo avant d’ajouter du texte.');
      return;
    }

    final textItem = TextStickerData.create(id: 'text_${_textItemSeed++}');
    setState(() {
      _textItems = [..._textItems, textItem];
      _selectedTextItemId = textItem.id;
      _selectedBubbleId = null;
      _editingBubbleId = null;
      _editingTextItemId = null;
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
        var updatedBubble = bubble.copyWith(
          shape: template.shape,
          tailStyle: template.tailStyle,
          assetPath: template.assetPath,
        );
        if (template.defaultFont != null) {
          updatedBubble = updatedBubble.applyFontStyle(template.defaultFont!);
        }
        return _autoSizeBubbleToText(updatedBubble);
      }).toList();
    });
  }

  void _startEditingSelectedBubble() {
    final bubble = _selectedBubble;
    if (bubble == null || _editingBubbleId == bubble.id) {
      return;
    }

    _bubbleTextController.value = TextEditingValue(
      text: bubble.text,
      selection: TextSelection.collapsed(offset: bubble.text.length),
    );
    _lastKnownEditingSelection = _bubbleTextController.selection;

    setState(() {
      _editingBubbleId = bubble.id;
      _editingTextItemId = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _bubbleTextFocusNode.requestFocus();
      }
    });
  }

  void _startEditingSelectedTextItem() {
    final textItem = _selectedTextItem;
    if (textItem == null || _editingTextItemId == textItem.id) {
      return;
    }

    _bubbleTextController.value = TextEditingValue(
      text: textItem.text,
      selection: TextSelection.collapsed(offset: textItem.text.length),
    );
    _lastKnownEditingSelection = _bubbleTextController.selection;

    setState(() {
      _editingTextItemId = textItem.id;
      _editingBubbleId = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _bubbleTextFocusNode.requestFocus();
      }
    });
  }

  void _stopEditingText() {
    if (_editingBubbleId == null && _editingTextItemId == null) {
      return;
    }
    _bubbleTextFocusNode.unfocus();
    _bubbleTextController.styledSpanBuilder = null;
    _lastKnownEditingSelection = null;
    setState(() {
      _editingBubbleId = null;
      _editingTextItemId = null;
    });
  }

  void _handleInlineTextChanged() {
    final editingBubbleId = _editingBubbleId;
    final editingTextItemId = _editingTextItemId;
    if (editingBubbleId == null && editingTextItemId == null) {
      return;
    }

    if (_bubbleTextController.selection.isValid) {
      _lastKnownEditingSelection = _bubbleTextController.selection;
    }

    setState(() {
      if (editingBubbleId != null) {
        _bubbles = _bubbles.map((bubble) {
          if (bubble.id != editingBubbleId) {
            return bubble;
          }
          return _autoSizeBubbleToText(
            bubble.copyWith(text: _bubbleTextController.text),
          );
        }).toList();
      } else if (editingTextItemId != null) {
        _textItems = _textItems.map((textItem) {
          if (textItem.id != editingTextItemId) {
            return textItem;
          }
          return textItem.copyWith(text: _bubbleTextController.text);
        }).toList();
      }
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

  void _resetSelectedBubbleRotation() {
    _updateSelectedBubble((bubble) => bubble.copyWith(rotation: 0));
  }

  void _resetSelectedTextRotation() {
    _updateSelectedTextItem((textItem) => textItem.copyWith(rotation: 0));
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
      final nextTextItems = _transformTextItemsAfterCrop(cropRect);

      setState(() {
        _workingImageBytes = nextBytes;
        _imageSize = Size(width.toDouble(), height.toDouble());
        _bubbles = nextBubbles;
        _textItems = nextTextItems;
        _selectedBubbleId =
            nextBubbles.any((bubble) => bubble.id == _selectedBubbleId)
            ? _selectedBubbleId
            : null;
        _selectedTextItemId =
            nextTextItems.any((textItem) => textItem.id == _selectedTextItemId)
            ? _selectedTextItemId
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

  List<TextStickerData> _transformTextItemsAfterCrop(Rect cropRect) {
    final transformed = <TextStickerData>[];

    for (final textItem in _textItems) {
      final textBounds = Rect.fromCenter(
        center: textItem.center,
        width: textItem.widthFactor,
        height: textItem.heightFactor,
      );
      if (!textBounds.overlaps(cropRect)) {
        continue;
      }

      final newCenter = Offset(
        (textItem.center.dx - cropRect.left) / cropRect.width,
        (textItem.center.dy - cropRect.top) / cropRect.height,
      );

      final newWidth = textItem.widthFactor / cropRect.width;
      final newHeight = textItem.heightFactor / cropRect.height;

      transformed.add(
        textItem.copyWith(
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
    String? savedLocation;

    final saved = await _runBusy('Enregistrement de la photo…', () async {
      final bytes = await _renderCurrentImage(outputExtension);
      savedLocation = await _photoPersistenceService.saveBytes(
        bytes: bytes,
        sourcePath: _sourceImagePath!,
        extension: outputExtension,
      );
    });

    if (!mounted || !saved) {
      return;
    }

    _showMessage(
      savedLocation == null
          ? 'Image enregistrée.'
          : 'Image enregistrée dans $savedLocation.',
    );
  }

  Future<void> _shareRenderedImage() async {
    if (!_hasImage || _sourceImagePath == null) {
      _showMessage('Aucune photo à partager.');
      return;
    }

    _stopEditingText();

    final outputExtension = _sourceExtension == '.png' ? '.png' : '.jpg';
    await _runBusy('Préparation du partage…', () async {
      final bytes = await _renderCurrentImage(outputExtension);
      await _photoPersistenceService.shareBytes(
        bytes: bytes,
        sourcePath: _sourceImagePath!,
        extension: outputExtension,
      );
    });
  }

  Future<Uint8List> _renderCurrentImage(String outputExtension) {
    return BubbleRenderer.renderCompositedImage(
      baseImageBytes: _workingImageBytes!,
      baseSize: _imageSize!,
      bubbles: _bubbles,
      textItems: _textItems,
      extension: outputExtension,
    );
  }

  void _applyFontChange(BubbleFontOption font) {
    final selection = _selectionForStyleUpdate();
    if (_selectedBubble != null) {
      _updateSelectedBubbleTextLayout(
        (bubble) => bubble.applyFontStyle(font, selection: selection),
      );
    } else if (_selectedTextItem != null) {
      _updateSelectedTextItem(
        (textItem) => textItem.applyFontStyle(font, selection: selection),
      );
    }
    _restoreEditingTextFocus();
  }

  void _applyTextColorChange(Color color) {
    final selection = _selectionForStyleUpdate();
    if (_selectedBubble != null) {
      _updateSelectedBubble(
        (bubble) => bubble.applyTextColorStyle(color, selection: selection),
      );
    } else if (_selectedTextItem != null) {
      _updateSelectedTextItem(
        (textItem) => textItem.applyTextColorStyle(color, selection: selection),
      );
    }
    _restoreEditingTextFocus();
  }

  void _applyBackgroundColorChange(Color color) {
    _updateSelectedTextItem(
      (textItem) => textItem.copyWith(backgroundColor: color),
    );
    _restoreEditingTextFocus();
  }

  void _applyBoldChange(bool isBold) {
    if (_selectedBubble != null) {
      _updateSelectedBubbleTextLayout(
        (bubble) => bubble.applyBoldStyle(isBold),
      );
    } else if (_selectedTextItem != null) {
      _updateSelectedTextItem((textItem) => textItem.applyBoldStyle(isBold));
    }
  }

  void _applyItalicChange(bool isItalic) {
    if (_selectedBubble != null) {
      _updateSelectedBubbleTextLayout(
        (bubble) => bubble.applyItalicStyle(isItalic),
      );
    } else if (_selectedTextItem != null) {
      _updateSelectedTextItem(
        (textItem) => textItem.applyItalicStyle(isItalic),
      );
    }
  }

  void _applyTextAlignChange(TextAlign alignment) {
    if (_selectedBubble != null) {
      _updateSelectedBubbleTextLayout(
        (bubble) => bubble.copyWith(textAlign: alignment),
      );
    } else if (_selectedTextItem != null) {
      _updateSelectedTextItem(
        (textItem) => textItem.copyWith(textAlign: alignment),
      );
    }
  }

  TextSelection? _selectionForStyleUpdate() {
    if (!_isEditingSelectedBubble && !_isEditingSelectedTextItem) {
      return null;
    }
    final selection = _bubbleTextController.selection;
    return selection.isValid ? selection : _lastKnownEditingSelection;
  }

  void _restoreEditingTextFocus() {
    if (!_isEditingSelectedBubble && !_isEditingSelectedTextItem) {
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
      _selectedTextItemId = null;
      _editingBubbleId = null;
      _editingTextItemId = null;
    });
  }

  void _handleTextItemTap(String textItemId) {
    if (_selectedTextItemId == textItemId) {
      _startEditingSelectedTextItem();
      return;
    }

    _stopEditingText();
    setState(() {
      _selectedTextItemId = textItemId;
      _selectedBubbleId = null;
      _editingBubbleId = null;
      _editingTextItemId = null;
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
      _selectedTextItemId = null;
      _activeGesture = _EditorGestureSession(
        elementId: bubble.id,
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
    final session = _activeGesture;
    if (session == null || session.elementId != bubble.id) {
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

  void _handleTextScaleStart(
    TextStickerData textItem,
    ScaleStartDetails details,
    Size displaySize,
  ) {
    _stopEditingText();
    final centerPixels = Offset(
      textItem.center.dx * displaySize.width,
      textItem.center.dy * displaySize.height,
    );

    setState(() {
      _selectedTextItemId = textItem.id;
      _selectedBubbleId = null;
      _activeGesture = _EditorGestureSession(
        elementId: textItem.id,
        startFocalPoint: _globalToCanvas(details.focalPoint),
        startCenterPixels: centerPixels,
        startWidthFactor: textItem.widthFactor,
        startHeightFactor: textItem.heightFactor,
        startRotation: textItem.rotation,
      );
    });
  }

  void _handleTextScaleUpdate(
    TextStickerData textItem,
    ScaleUpdateDetails details,
    Size displaySize,
  ) {
    final session = _activeGesture;
    if (session == null || session.elementId != textItem.id) {
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
      _textItems = _textItems.map((item) {
        if (item.id != textItem.id) {
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

  void _handleElementScaleEnd() {
    _activeGesture = null;
  }

  void _clearSelection() {
    if (_selectedBubbleId == null && _selectedTextItemId == null) {
      return;
    }
    _stopEditingText();
    setState(() {
      _selectedBubbleId = null;
      _selectedTextItemId = null;
      _editingBubbleId = null;
      _editingTextItemId = null;
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

  void _removeSelectedTextItem() {
    final textItemId = _selectedTextItemId;
    if (textItemId == null) {
      return;
    }

    _stopEditingText();
    setState(() {
      _textItems = _textItems
          .where((textItem) => textItem.id != textItemId)
          .toList();
      _selectedTextItemId = null;
      _editingTextItemId = null;
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

  void _updateSelectedBubbleTextLayout(
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
        return _autoSizeBubbleToText(update(bubble));
      }).toList();
    });
  }

  SpeechBubbleData _autoSizeBubbleToText(SpeechBubbleData bubble) {
    final imageSize = _imageSize;
    final stretchSpec = BubbleTemplate.fromAssetPath(
      bubble.assetPath,
    )?.stretchSpec;
    if (imageSize == null ||
        stretchSpec == null ||
        !stretchSpec.autoSizeToText) {
      return bubble;
    }

    var candidateSize = Size(
      bubble.widthFactor * imageSize.width,
      bubble.heightFactor * imageSize.height,
    );
    final fixedWidth = candidateSize.width;
    final widthScale = fixedWidth / stretchSpec.sourceSize.width;
    final minHeight = stretchSpec.sourceSize.height * widthScale;
    final maxHeight = imageSize.height * stretchSpec.maxHeightFactor;
    final heightFloor = math.min(minHeight, maxHeight);
    final measuredText = bubble.text.trim().isEmpty ? ' ' : bubble.text;

    for (var pass = 0; pass < 4; pass++) {
      final padding = BubbleRenderer.contentPadding(bubble, candidateSize);
      final textWidth = math.max(1.0, fixedWidth - padding.horizontal);
      final widthAwareSize = Size(fixedWidth, candidateSize.height);
      final widthAwarePadding = BubbleRenderer.contentPadding(
        bubble,
        widthAwareSize,
      );
      final heightProbePainter = TextPainter(
        text: bubble.buildStyledTextSpan(
          widthAwareSize,
          overrideText: measuredText,
        ),
        textAlign: bubble.textAlign,
        textDirection: TextDirection.ltr,
        maxLines: 24,
      )..layout(maxWidth: math.max(1.0, textWidth));

      final probeTextStyle = bubble.textStyleFor(widthAwareSize);
      final singleLineHeight =
          (probeTextStyle.fontSize ?? 0) * (probeTextStyle.height ?? 1.15);
      final extraVerticalSafety = (probeTextStyle.fontSize ?? 0) * 0.26;
      final desiredHeight =
          (math.max(heightProbePainter.height, singleLineHeight) +
                  widthAwarePadding.vertical +
                  extraVerticalSafety)
              .clamp(heightFloor, maxHeight)
              .toDouble();

      final nextSize = Size(fixedWidth, desiredHeight);
      if ((nextSize.height - candidateSize.height).abs() < 0.5) {
        candidateSize = nextSize;
        break;
      }
      candidateSize = nextSize;
    }

    final nextWidthFactor = bubble.widthFactor;
    final nextHeightFactor = (candidateSize.height / imageSize.height)
        .clamp(0.1, 1.2)
        .toDouble();
    final halfWidth = nextWidthFactor / 2;
    final halfHeight = nextHeightFactor / 2;

    return bubble.copyWith(
      widthFactor: nextWidthFactor,
      heightFactor: nextHeightFactor,
      center: Offset(
        _clampElementCenterAxis(bubble.center.dx, halfWidth),
        _clampElementCenterAxis(bubble.center.dy, halfHeight),
      ),
    );
  }

  double _clampElementCenterAxis(double center, double halfExtent) {
    final minCenter = halfExtent;
    final maxCenter = 1 - halfExtent;
    if (minCenter > maxCenter) {
      return 0.5;
    }
    return (center.clamp(minCenter, maxCenter) as num).toDouble();
  }

  void _updateSelectedTextItem(
    TextStickerData Function(TextStickerData textItem) update,
  ) {
    final textItemId = _selectedTextItemId;
    if (textItemId == null) {
      return;
    }

    setState(() {
      _textItems = _textItems.map((textItem) {
        if (textItem.id != textItemId) {
          return textItem;
        }
        return update(textItem);
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
    final selectedTextItem = _selectedTextItem;
    final isEditingText = _isEditingSelectedElement;

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
                              textItems: _textItems,
                              selectedBubbleId: _selectedBubbleId,
                              selectedBubble: selectedBubble,
                              selectedTextItem: selectedTextItem,
                              isEditingText: _isEditingSelectedBubble,
                              isEditingTextItem: _isEditingSelectedTextItem,
                              textController: _bubbleTextController,
                              textFocusNode: _bubbleTextFocusNode,
                              transformationController:
                                  _transformationController,
                              canvasKey: _canvasKey,
                              onClearSelection: _clearSelection,
                              onBubbleTap: _handleBubbleTap,
                              onBubbleScaleStart: _handleBubbleScaleStart,
                              onBubbleScaleUpdate: _handleBubbleScaleUpdate,
                              onBubbleScaleEnd: _handleElementScaleEnd,
                              onTextTap: _handleTextItemTap,
                              onTextScaleStart: _handleTextScaleStart,
                              onTextScaleUpdate: _handleTextScaleUpdate,
                              onTextScaleEnd: _handleElementScaleEnd,
                              onChangeShape: _changeSelectedBubbleShape,
                              onFlipHorizontal: _toggleTailHorizontal,
                              onFlipVertical: _toggleTailVertical,
                              onResetRotation: _resetSelectedBubbleRotation,
                              onDeleteSelectedBubble: _removeSelectedBubble,
                              onResetTextRotation: _resetSelectedTextRotation,
                              onDeleteSelectedText: _removeSelectedTextItem,
                            )
                          : EditorEmptyState(onPickImage: _pickImage),
                    ),
                  ),
                ),
                if (selectedBubble != null && !isEditingText)
                  TextToolbox(
                    font: selectedBubble.font,
                    textColor: selectedBubble.textColor,
                    fontScaleFactor: selectedBubble.fontScaleFactor,
                    textAlign: selectedBubble.textAlign,
                    isBold: selectedBubble.isBold,
                    isItalic: selectedBubble.isItalic,
                    onFontChanged: _applyFontChange,
                    onTextColorChanged: _applyTextColorChange,
                    onFontScaleChanged: (value) =>
                        _updateSelectedBubbleTextLayout(
                          (bubble) => bubble.copyWith(fontScaleFactor: value),
                        ),
                    onTextAlignChanged: _applyTextAlignChange,
                    onBoldChanged: _applyBoldChange,
                    onItalicChanged: _applyItalicChange,
                  ),
                if (selectedTextItem != null && !isEditingText)
                  TextToolbox(
                    font: selectedTextItem.font,
                    textColor: selectedTextItem.textColor,
                    fontScaleFactor: selectedTextItem.fontScaleFactor,
                    textAlign: selectedTextItem.textAlign,
                    isBold: selectedTextItem.isBold,
                    isItalic: selectedTextItem.isItalic,
                    onFontChanged: _applyFontChange,
                    onTextColorChanged: _applyTextColorChange,
                    onFontScaleChanged: (value) => _updateSelectedTextItem(
                      (textItem) => textItem.copyWith(fontScaleFactor: value),
                    ),
                    onTextAlignChanged: _applyTextAlignChange,
                    onBoldChanged: _applyBoldChange,
                    onItalicChanged: _applyItalicChange,
                    backgroundColor: selectedTextItem.backgroundColor,
                    onBackgroundColorChanged: _applyBackgroundColorChange,
                  ),
                EditorToolbar(
                  hasImage: _hasImage,
                  onPickImage: _pickImage,
                  onAddBubble: _openBubblePicker,
                  onAddText: _addTextItem,
                  onCrop: _openCropEditor,
                  onShare: _shareRenderedImage,
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

class _EditorGestureSession {
  const _EditorGestureSession({
    required this.elementId,
    required this.startFocalPoint,
    required this.startCenterPixels,
    required this.startWidthFactor,
    required this.startHeightFactor,
    required this.startRotation,
  });

  final String elementId;
  final Offset startFocalPoint;
  final Offset startCenterPixels;
  final double startWidthFactor;
  final double startHeightFactor;
  final double startRotation;
}

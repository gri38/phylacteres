// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get processing => 'Processing…';

  @override
  String get loadingPhoto => 'Loading photo…';

  @override
  String get loadPhotoBeforeAddingBubble => 'Load a photo before adding a speech bubble.';

  @override
  String get loadPhotoBeforeAddingText => 'Load a photo before adding text.';

  @override
  String get applyingCrop => 'Applying crop…';

  @override
  String get currentImageReadError => 'Could not read the current image.';

  @override
  String get noPhotoToSave => 'No photo to save.';

  @override
  String get savingPhoto => 'Saving photo…';

  @override
  String get imageSaved => 'Image saved.';

  @override
  String imageSavedIn(String savedLocation) {
    return 'Image saved in $savedLocation.';
  }

  @override
  String get noPhotoToShare => 'No photo to share.';

  @override
  String get preparingShare => 'Preparing share…';

  @override
  String get resetPhotoZoom => 'Reset photo zoom';

  @override
  String get crop => 'Crop';

  @override
  String get apply => 'Apply';

  @override
  String get loadPhotoToStart => 'Load a photo to start.';

  @override
  String get editorEmptyInstructions =>
      'Then add your bubbles, move them with your finger, pinch to resize them, and rotate them with two fingers.';

  @override
  String get choosePhoto => 'Choose a photo';

  @override
  String get photo => 'Photo';

  @override
  String get speechBubble => 'Speech bubble';

  @override
  String get text => 'Text';

  @override
  String get share => 'Share';

  @override
  String get save => 'Save';

  @override
  String get tapAgainToWrite => 'Tap again to write';

  @override
  String get writeHint => 'Write…';

  @override
  String get changeSpeechBubble => 'Change speech bubble';

  @override
  String get flipHorizontally => 'Flip horizontally';

  @override
  String get flipVertically => 'Flip vertically';

  @override
  String get resetRotation => 'Reset to 0°';

  @override
  String get delete => 'Delete';

  @override
  String get font => 'Font';

  @override
  String get textColor => 'Text color';

  @override
  String get bold => 'Bold';

  @override
  String get italic => 'Italic';

  @override
  String get alignment => 'Alignment';

  @override
  String get textBackground => 'Text background';

  @override
  String get transparent => 'Transparent';

  @override
  String get color => 'Color';

  @override
  String opacityPercent(int opacity) {
    return 'Opacity $opacity%';
  }

  @override
  String get saturation => 'Saturation';

  @override
  String get transparency => 'Transparency';

  @override
  String get cancel => 'Cancel';

  @override
  String get outputFolderName => 'Phylactères';

  @override
  String get saveConfirmationError => 'Could not confirm that the image was saved.';

  @override
  String get androidOnlyShareUnsupported => 'Sharing is only available on Android in this version.';

  @override
  String get pathArgumentRequired => 'The path is required.';

  @override
  String get saveImageArgumentsRequired => 'Image data, source path, extension, and MIME type are required.';

  @override
  String get shareImageArgumentsRequired => 'Image data, file name, and MIME type are required.';

  @override
  String get outputFolderCreateError => 'Could not create the output folder.';

  @override
  String get galleryEntryCreateError => 'Could not create the gallery entry.';

  @override
  String get galleryOutputStreamOpenError => 'Could not open the gallery output stream.';

  @override
  String get shareImageChooserTitle => 'Share image';
}

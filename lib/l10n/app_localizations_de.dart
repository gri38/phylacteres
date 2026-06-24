// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get processing => 'Verarbeitung…';

  @override
  String get loadingPhoto => 'Foto wird geladen…';

  @override
  String get loadPhotoBeforeAddingBubble =>
      'Lade ein Foto, bevor du eine Sprechblase hinzufügst.';

  @override
  String get loadPhotoBeforeAddingText =>
      'Lade ein Foto, bevor du Text hinzufügst.';

  @override
  String get applyingCrop => 'Zuschnitt wird angewendet…';

  @override
  String get currentImageReadError =>
      'Das aktuelle Bild konnte nicht gelesen werden.';

  @override
  String get noPhotoToSave => 'Kein Foto zum Speichern.';

  @override
  String get savingPhoto => 'Foto wird gespeichert…';

  @override
  String get imageSaved => 'Bild gespeichert.';

  @override
  String imageSavedIn(String savedLocation) {
    return 'Bild gespeichert in $savedLocation.';
  }

  @override
  String get noPhotoToShare => 'Kein Foto zum Teilen.';

  @override
  String get preparingShare => 'Teilen wird vorbereitet…';

  @override
  String get resetPhotoZoom => 'Fotozoom zurücksetzen';

  @override
  String get crop => 'Zuschneiden';

  @override
  String get apply => 'Anwenden';

  @override
  String get loadPhotoToStart => 'Lade ein Foto, um zu beginnen.';

  @override
  String get editorEmptyInstructions =>
      'Füge dann deine Sprechblasen hinzu, verschiebe sie mit dem Finger, ziehe sie mit zwei Fingern größer oder kleiner und drehe sie mit zwei Fingern.';

  @override
  String get choosePhoto => 'Foto auswählen';

  @override
  String get photo => 'Foto';

  @override
  String get speechBubble => 'Sprechblase';

  @override
  String get text => 'Text';

  @override
  String get share => 'Teilen';

  @override
  String get save => 'Speichern';

  @override
  String get tapAgainToWrite => 'Tippe erneut, um zu schreiben';

  @override
  String get writeHint => 'Schreiben…';

  @override
  String get changeSpeechBubble => 'Sprechblase ändern';

  @override
  String get flipHorizontally => 'Horizontal spiegeln';

  @override
  String get flipVertically => 'Vertikal spiegeln';

  @override
  String get resetRotation => 'Auf 0° zurücksetzen';

  @override
  String get delete => 'Löschen';

  @override
  String get font => 'Schriftart';

  @override
  String get textColor => 'Textfarbe';

  @override
  String get bold => 'Fett';

  @override
  String get italic => 'Kursiv';

  @override
  String get alignment => 'Ausrichtung';

  @override
  String get textBackground => 'Texthintergrund';

  @override
  String get transparent => 'Transparent';

  @override
  String get color => 'Farbe';

  @override
  String opacityPercent(int opacity) {
    return 'Deckkraft $opacity%';
  }

  @override
  String get saturation => 'Sättigung';

  @override
  String get transparency => 'Transparenz';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get outputFolderName => 'Phylactères';

  @override
  String get saveConfirmationError =>
      'Es konnte nicht bestätigt werden, dass das Bild gespeichert wurde.';

  @override
  String get androidOnlyShareUnsupported =>
      'Teilen ist in dieser Version nur unter Android verfügbar.';

  @override
  String get pathArgumentRequired => 'Der Pfad ist erforderlich.';

  @override
  String get saveImageArgumentsRequired =>
      'Bilddaten, Quellpfad, Erweiterung und MIME-Typ sind erforderlich.';

  @override
  String get shareImageArgumentsRequired =>
      'Bilddaten, Dateiname und MIME-Typ sind erforderlich.';

  @override
  String get outputFolderCreateError =>
      'Der Ausgabeordner konnte nicht erstellt werden.';

  @override
  String get galleryEntryCreateError =>
      'Der Galerieeintrag konnte nicht erstellt werden.';

  @override
  String get galleryOutputStreamOpenError =>
      'Der Ausgabestream der Galerie konnte nicht geöffnet werden.';

  @override
  String get shareImageChooserTitle => 'Bild teilen';
}

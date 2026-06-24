// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get processing => 'Traitement…';

  @override
  String get loadingPhoto => 'Chargement de la photo…';

  @override
  String get loadPhotoBeforeAddingBubble => 'Chargez une photo avant d’ajouter un phylactère.';

  @override
  String get loadPhotoBeforeAddingText => 'Chargez une photo avant d’ajouter du texte.';

  @override
  String get applyingCrop => 'Application du recadrage…';

  @override
  String get currentImageReadError => 'Impossible de lire l’image courante.';

  @override
  String get noPhotoToSave => 'Aucune photo à enregistrer.';

  @override
  String get savingPhoto => 'Enregistrement de la photo…';

  @override
  String get imageSaved => 'Image enregistrée.';

  @override
  String imageSavedIn(String savedLocation) {
    return 'Image enregistrée dans $savedLocation.';
  }

  @override
  String get noPhotoToShare => 'Aucune photo à partager.';

  @override
  String get preparingShare => 'Préparation du partage…';

  @override
  String get resetPhotoZoom => 'Réinitialiser le zoom photo';

  @override
  String get crop => 'Recadrer';

  @override
  String get apply => 'Appliquer';

  @override
  String get loadPhotoToStart => 'Chargez une photo pour commencer.';

  @override
  String get editorEmptyInstructions =>
      'Ajoutez ensuite vos bulles, déplacez-les au doigt, pincez pour les redimensionner et tournez-les à deux doigts.';

  @override
  String get choosePhoto => 'Choisir une photo';

  @override
  String get photo => 'Photo';

  @override
  String get speechBubble => 'Phylactère';

  @override
  String get text => 'Texte';

  @override
  String get share => 'Partager';

  @override
  String get save => 'Enregistrer';

  @override
  String get tapAgainToWrite => 'Touchez encore pour écrire';

  @override
  String get writeHint => 'Écrire…';

  @override
  String get changeSpeechBubble => 'Changer de phylactère';

  @override
  String get flipHorizontally => 'Inverser horizontalement';

  @override
  String get flipVertically => 'Inverser verticalement';

  @override
  String get resetRotation => 'Remettre à 0°';

  @override
  String get delete => 'Supprimer';

  @override
  String get font => 'Police';

  @override
  String get textColor => 'Couleur du texte';

  @override
  String get bold => 'Gras';

  @override
  String get italic => 'Italique';

  @override
  String get alignment => 'Alignement';

  @override
  String get textBackground => 'Fond du texte';

  @override
  String get transparent => 'Transparent';

  @override
  String get color => 'Couleur';

  @override
  String opacityPercent(int opacity) {
    return 'Opacité $opacity%';
  }

  @override
  String get saturation => 'Saturation';

  @override
  String get transparency => 'Transparence';

  @override
  String get cancel => 'Annuler';

  @override
  String get outputFolderName => 'Phylactères';

  @override
  String get saveConfirmationError => 'Impossible de confirmer l’enregistrement de l’image.';

  @override
  String get androidOnlyShareUnsupported => 'Le partage est disponible uniquement sur Android dans cette version.';

  @override
  String get pathArgumentRequired => 'Le chemin est requis.';

  @override
  String get saveImageArgumentsRequired =>
      'Les données de l’image, le chemin source, l’extension et le type MIME sont requis.';

  @override
  String get shareImageArgumentsRequired => 'Les données de l’image, le nom du fichier et le type MIME sont requis.';

  @override
  String get outputFolderCreateError => 'Impossible de créer le dossier de sortie.';

  @override
  String get galleryEntryCreateError => 'Impossible de créer l’entrée dans la galerie.';

  @override
  String get galleryOutputStreamOpenError => 'Impossible d’ouvrir le flux d’écriture de la galerie.';

  @override
  String get shareImageChooserTitle => 'Partager l’image';
}

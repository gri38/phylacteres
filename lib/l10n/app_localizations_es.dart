// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get processing => 'Procesando…';

  @override
  String get loadingPhoto => 'Cargando foto…';

  @override
  String get loadPhotoBeforeAddingBubble => 'Carga una foto antes de añadir un bocadillo.';

  @override
  String get loadPhotoBeforeAddingText => 'Carga una foto antes de añadir texto.';

  @override
  String get applyingCrop => 'Aplicando recorte…';

  @override
  String get currentImageReadError => 'No se pudo leer la imagen actual.';

  @override
  String get noPhotoToSave => 'No hay ninguna foto para guardar.';

  @override
  String get savingPhoto => 'Guardando foto…';

  @override
  String get imageSaved => 'Imagen guardada.';

  @override
  String imageSavedIn(String savedLocation) {
    return 'Imagen guardada en $savedLocation.';
  }

  @override
  String get noPhotoToShare => 'No hay ninguna foto para compartir.';

  @override
  String get preparingShare => 'Preparando para compartir…';

  @override
  String get resetPhotoZoom => 'Restablecer el zoom de la foto';

  @override
  String get crop => 'Recortar';

  @override
  String get apply => 'Aplicar';

  @override
  String get loadPhotoToStart => 'Carga una foto para empezar.';

  @override
  String get editorEmptyInstructions =>
      'Después añade tus bocadillos, muévelos con el dedo, pellizca para cambiar su tamaño y gíralos con dos dedos.';

  @override
  String get choosePhoto => 'Elegir una foto';

  @override
  String get photo => 'Foto';

  @override
  String get speechBubble => 'Bocadillo';

  @override
  String get text => 'Texto';

  @override
  String get share => 'Compartir';

  @override
  String get save => 'Guardar';

  @override
  String get tapAgainToWrite => 'Toca de nuevo para escribir';

  @override
  String get writeHint => 'Escribir…';

  @override
  String get changeSpeechBubble => 'Cambiar bocadillo';

  @override
  String get flipHorizontally => 'Invertir horizontalmente';

  @override
  String get flipVertically => 'Invertir verticalmente';

  @override
  String get resetRotation => 'Restablecer a 0°';

  @override
  String get delete => 'Eliminar';

  @override
  String get font => 'Fuente';

  @override
  String get textColor => 'Color del texto';

  @override
  String get bold => 'Negrita';

  @override
  String get italic => 'Cursiva';

  @override
  String get alignment => 'Alineación';

  @override
  String get textBackground => 'Fondo del texto';

  @override
  String get transparent => 'Transparente';

  @override
  String get color => 'Color';

  @override
  String opacityPercent(int opacity) {
    return 'Opacidad $opacity%';
  }

  @override
  String get saturation => 'Saturación';

  @override
  String get transparency => 'Transparencia';

  @override
  String get cancel => 'Cancelar';

  @override
  String get outputFolderName => 'Phylactères';

  @override
  String get saveConfirmationError => 'No se pudo confirmar que la imagen se haya guardado.';

  @override
  String get androidOnlyShareUnsupported => 'Compartir solo está disponible en Android en esta versión.';

  @override
  String get pathArgumentRequired => 'La ruta es obligatoria.';

  @override
  String get saveImageArgumentsRequired =>
      'Se requieren los datos de la imagen, la ruta de origen, la extensión y el tipo MIME.';

  @override
  String get shareImageArgumentsRequired =>
      'Se requieren los datos de la imagen, el nombre del archivo y el tipo MIME.';

  @override
  String get outputFolderCreateError => 'No se pudo crear la carpeta de salida.';

  @override
  String get galleryEntryCreateError => 'No se pudo crear la entrada en la galería.';

  @override
  String get galleryOutputStreamOpenError => 'No se pudo abrir el flujo de salida de la galería.';

  @override
  String get shareImageChooserTitle => 'Compartir imagen';
}

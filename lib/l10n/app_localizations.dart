import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de'), Locale('en'), Locale('es'), Locale('fr')];

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get processing;

  /// No description provided for @loadingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Loading photo…'**
  String get loadingPhoto;

  /// No description provided for @loadPhotoBeforeAddingBubble.
  ///
  /// In en, this message translates to:
  /// **'Load a photo before adding a speech bubble.'**
  String get loadPhotoBeforeAddingBubble;

  /// No description provided for @loadPhotoBeforeAddingText.
  ///
  /// In en, this message translates to:
  /// **'Load a photo before adding text.'**
  String get loadPhotoBeforeAddingText;

  /// No description provided for @applyingCrop.
  ///
  /// In en, this message translates to:
  /// **'Applying crop…'**
  String get applyingCrop;

  /// No description provided for @currentImageReadError.
  ///
  /// In en, this message translates to:
  /// **'Could not read the current image.'**
  String get currentImageReadError;

  /// No description provided for @noPhotoToSave.
  ///
  /// In en, this message translates to:
  /// **'No photo to save.'**
  String get noPhotoToSave;

  /// No description provided for @savingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Saving photo…'**
  String get savingPhoto;

  /// No description provided for @imageSaved.
  ///
  /// In en, this message translates to:
  /// **'Image saved.'**
  String get imageSaved;

  /// No description provided for @imageSavedIn.
  ///
  /// In en, this message translates to:
  /// **'Image saved in {savedLocation}.'**
  String imageSavedIn(String savedLocation);

  /// No description provided for @noPhotoToShare.
  ///
  /// In en, this message translates to:
  /// **'No photo to share.'**
  String get noPhotoToShare;

  /// No description provided for @preparingShare.
  ///
  /// In en, this message translates to:
  /// **'Preparing share…'**
  String get preparingShare;

  /// No description provided for @resetPhotoZoom.
  ///
  /// In en, this message translates to:
  /// **'Reset photo zoom'**
  String get resetPhotoZoom;

  /// No description provided for @crop.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get crop;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @loadPhotoToStart.
  ///
  /// In en, this message translates to:
  /// **'Load a photo to start.'**
  String get loadPhotoToStart;

  /// No description provided for @editorEmptyInstructions.
  ///
  /// In en, this message translates to:
  /// **'Then add your bubbles, move them with your finger, pinch to resize them, and rotate them with two fingers.'**
  String get editorEmptyInstructions;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose a photo'**
  String get choosePhoto;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @speechBubble.
  ///
  /// In en, this message translates to:
  /// **'Speech bubble'**
  String get speechBubble;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @tapAgainToWrite.
  ///
  /// In en, this message translates to:
  /// **'Tap again to write'**
  String get tapAgainToWrite;

  /// No description provided for @writeHint.
  ///
  /// In en, this message translates to:
  /// **'Write…'**
  String get writeHint;

  /// No description provided for @changeSpeechBubble.
  ///
  /// In en, this message translates to:
  /// **'Change speech bubble'**
  String get changeSpeechBubble;

  /// No description provided for @flipHorizontally.
  ///
  /// In en, this message translates to:
  /// **'Flip horizontally'**
  String get flipHorizontally;

  /// No description provided for @flipVertically.
  ///
  /// In en, this message translates to:
  /// **'Flip vertically'**
  String get flipVertically;

  /// No description provided for @resetRotation.
  ///
  /// In en, this message translates to:
  /// **'Reset to 0°'**
  String get resetRotation;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @font.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get font;

  /// No description provided for @textColor.
  ///
  /// In en, this message translates to:
  /// **'Text color'**
  String get textColor;

  /// No description provided for @bold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// No description provided for @italic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get italic;

  /// No description provided for @alignment.
  ///
  /// In en, this message translates to:
  /// **'Alignment'**
  String get alignment;

  /// No description provided for @textBackground.
  ///
  /// In en, this message translates to:
  /// **'Text background'**
  String get textBackground;

  /// No description provided for @transparent.
  ///
  /// In en, this message translates to:
  /// **'Transparent'**
  String get transparent;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @opacityPercent.
  ///
  /// In en, this message translates to:
  /// **'Opacity {opacity}%'**
  String opacityPercent(int opacity);

  /// No description provided for @saturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get saturation;

  /// No description provided for @transparency.
  ///
  /// In en, this message translates to:
  /// **'Transparency'**
  String get transparency;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @outputFolderName.
  ///
  /// In en, this message translates to:
  /// **'Phylactères'**
  String get outputFolderName;

  /// No description provided for @saveConfirmationError.
  ///
  /// In en, this message translates to:
  /// **'Could not confirm that the image was saved.'**
  String get saveConfirmationError;

  /// No description provided for @androidOnlyShareUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Sharing is only available on Android in this version.'**
  String get androidOnlyShareUnsupported;

  /// No description provided for @pathArgumentRequired.
  ///
  /// In en, this message translates to:
  /// **'The path is required.'**
  String get pathArgumentRequired;

  /// No description provided for @saveImageArgumentsRequired.
  ///
  /// In en, this message translates to:
  /// **'Image data, source path, extension, and MIME type are required.'**
  String get saveImageArgumentsRequired;

  /// No description provided for @shareImageArgumentsRequired.
  ///
  /// In en, this message translates to:
  /// **'Image data, file name, and MIME type are required.'**
  String get shareImageArgumentsRequired;

  /// No description provided for @outputFolderCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create the output folder.'**
  String get outputFolderCreateError;

  /// No description provided for @galleryEntryCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create the gallery entry.'**
  String get galleryEntryCreateError;

  /// No description provided for @galleryOutputStreamOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the gallery output stream.'**
  String get galleryOutputStreamOpenError;

  /// No description provided for @shareImageChooserTitle.
  ///
  /// In en, this message translates to:
  /// **'Share image'**
  String get shareImageChooserTitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

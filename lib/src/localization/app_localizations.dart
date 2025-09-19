import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('hu'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('ms'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// No description provided for @appParlerAI.
  ///
  /// In en, this message translates to:
  /// **'ParlerAI'**
  String get appParlerAI;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get connecting;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Start Recording'**
  String get startRecording;

  /// No description provided for @pauseRecording.
  ///
  /// In en, this message translates to:
  /// **'Pause Recording'**
  String get pauseRecording;

  /// No description provided for @pleaseWaitParlerAIIsRespondingU.
  ///
  /// In en, this message translates to:
  /// **'I\'m thinking'**
  String get pleaseWaitParlerAIIsRespondingU;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @copine.
  ///
  /// In en, this message translates to:
  /// **'Parlerai'**
  String get copine;

  /// No description provided for @audioMessage.
  ///
  /// In en, this message translates to:
  /// **'Audio Message'**
  String get audioMessage;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @chatHistory.
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistory;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @aiEngine.
  ///
  /// In en, this message translates to:
  /// **'AI Engine'**
  String get aiEngine;

  /// No description provided for @chooseTheOneYouPrefer.
  ///
  /// In en, this message translates to:
  /// **'Choose the one you prefer'**
  String get chooseTheOneYouPrefer;

  /// No description provided for @changeNow.
  ///
  /// In en, this message translates to:
  /// **'Change Now'**
  String get changeNow;

  /// No description provided for @operationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Operation Completed'**
  String get operationCompleted;

  /// No description provided for @openaiIntro.
  ///
  /// In en, this message translates to:
  /// **'Developed in the USA, with ChatGPT as the pioneer. With its ability to generate realistic conversations, OpenAI helps MaCopine provide lively and varied dialogues, just like speaking with a true friend.'**
  String get openaiIntro;

  /// No description provided for @deepseekIntro.
  ///
  /// In en, this message translates to:
  /// **'Developed in China, it\'s the first powerful Chinese AI known to the world. Its engine helps MaCopine analyze your responses and provide personalized feedback, improving your pronunciation and fluency in a friendly and constructive manner.'**
  String get deepseekIntro;

  /// No description provided for @lechatIntro.
  ///
  /// In en, this message translates to:
  /// **'Developed in France by Mistral AI, the first popular French AI product known to the world. LeChat helps MaCopine with casual and relaxed exchanges, simulating informal conversations, and creating an authentic and friendly experience to enhance your speaking skills.'**
  String get lechatIntro;

  /// No description provided for @grokIntro.
  ///
  /// In en, this message translates to:
  /// **'Developed in the United States by Elon Musk\'s AI team. Grok brings cutting-edge conversational AI capabilities to MaCopine, offering intelligent and engaging conversations to improve your language skills in real-time.'**
  String get grokIntro;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @maximumRecording.
  ///
  /// In en, this message translates to:
  /// **'Maximum Recording'**
  String get maximumRecording;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// No description provided for @microphonePermission.
  ///
  /// In en, this message translates to:
  /// **'Microphone Permission'**
  String get microphonePermission;

  /// No description provided for @microphonePermissionRequest.
  ///
  /// In en, this message translates to:
  /// **'ParlerAI requires access to your microphone to enable audio recording and interaction features. Please grant microphone access to enjoy the full experience of the app.'**
  String get microphonePermissionRequest;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @privacyData.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data'**
  String get privacyData;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsofService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsofService;

  /// No description provided for @deleteAllMyData.
  ///
  /// In en, this message translates to:
  /// **'Delete All My Data'**
  String get deleteAllMyData;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteMyAccount;

  /// No description provided for @deleteAllMyDataHints.
  ///
  /// In en, this message translates to:
  /// **'Once you delete all of your data, there is no going back, and you cannot recover your data. Please be certain.'**
  String get deleteAllMyDataHints;

  /// No description provided for @deleteMyAccountHints.
  ///
  /// In en, this message translates to:
  /// **'Once you delete your account, there is no going back, and you cannot sign in with this account again. Please be certain.'**
  String get deleteMyAccountHints;

  /// No description provided for @textChatInstructionGuide1.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m Parlerai, your French C2 level friend, how can I help with your French grammar and sentence structure questions today? You can also ask me about the French culture, cuisine, tradition and language, or anything you would like to talk.'**
  String get textChatInstructionGuide1;

  /// No description provided for @hiHowAreYouGoingToday.
  ///
  /// In en, this message translates to:
  /// **'Hi How are you going today?'**
  String get hiHowAreYouGoingToday;

  /// No description provided for @pleaseTellMeAboutYourQuestions.
  ///
  /// In en, this message translates to:
  /// **'Please tell me about your questions'**
  String get pleaseTellMeAboutYourQuestions;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @dislike.
  ///
  /// In en, this message translates to:
  /// **'Dislike'**
  String get dislike;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @thankYouForYourSupporting.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your supporting.'**
  String get thankYouForYourSupporting;

  /// No description provided for @weWillContinueWorkingToImproveTheContent.
  ///
  /// In en, this message translates to:
  /// **'Thank you. We will continue working to improve the content.'**
  String get weWillContinueWorkingToImproveTheContent;

  /// No description provided for @weApologizeForTheInappropriateContent.
  ///
  /// In en, this message translates to:
  /// **'We apologize for the inappropriate content and are committed to improving it.'**
  String get weApologizeForTheInappropriateContent;

  /// No description provided for @iapCapabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Procure Your \nParlerAI Plus'**
  String get iapCapabilityTitle;

  /// No description provided for @iapCapabilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your French C2 level friend'**
  String get iapCapabilitySubtitle;

  /// No description provided for @iapCapability1.
  ///
  /// In en, this message translates to:
  /// **'Everything is Free'**
  String get iapCapability1;

  /// No description provided for @iapCapability2.
  ///
  /// In en, this message translates to:
  /// **'Advanced interaction through voice mode'**
  String get iapCapability2;

  /// No description provided for @iapCapability3.
  ///
  /// In en, this message translates to:
  /// **'Unlimited access to ParlerAI Realtime Call'**
  String get iapCapability3;

  /// No description provided for @iapCapability4.
  ///
  /// In en, this message translates to:
  /// **'Unlimited requests for text evaluation, corrections, grammar checks, and sentence structure improvements, etc.'**
  String get iapCapability4;

  /// No description provided for @iapCapability5.
  ///
  /// In en, this message translates to:
  /// **'Only pay for 8 months, 4 months free, with a 37% discount compared to the monthly plan'**
  String get iapCapability5;

  /// No description provided for @iapCapability6.
  ///
  /// In en, this message translates to:
  /// **'Only \$0.267 dollar per day'**
  String get iapCapability6;

  /// No description provided for @iapCapability7.
  ///
  /// In en, this message translates to:
  /// **'The first week is free to use'**
  String get iapCapability7;

  /// No description provided for @iapCapability8.
  ///
  /// In en, this message translates to:
  /// **'The first two weeks are free to use'**
  String get iapCapability8;

  /// No description provided for @iapBilledMonthly.
  ///
  /// In en, this message translates to:
  /// **'Billed monthly at \$12.99. Cancel anytime.'**
  String get iapBilledMonthly;

  /// No description provided for @iapBilledYearly.
  ///
  /// In en, this message translates to:
  /// **'Billed yearly at \$99.00. Cancel anytime.'**
  String get iapBilledYearly;

  /// No description provided for @iapMonthlyBtn.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get iapMonthlyBtn;

  /// No description provided for @iapYearlyBtn.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get iapYearlyBtn;

  /// No description provided for @iapPayButton.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to ParlerAI Plus'**
  String get iapPayButton;

  /// No description provided for @iapRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get iapRestore;

  /// No description provided for @iapPurchaseSucceeds.
  ///
  /// In en, this message translates to:
  /// **'Purchase Successful'**
  String get iapPurchaseSucceeds;

  /// No description provided for @iapPurchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase Failed'**
  String get iapPurchaseFailed;

  /// No description provided for @iapPurchaseCancelled.
  ///
  /// In en, this message translates to:
  /// **'Purchase Cancelled'**
  String get iapPurchaseCancelled;

  /// No description provided for @iapRestoredSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restored Successful'**
  String get iapRestoredSuccess;

  /// No description provided for @iapPurchaseHistory.
  ///
  /// In en, this message translates to:
  /// **'Purchase History'**
  String get iapPurchaseHistory;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @parlerAIPlus.
  ///
  /// In en, this message translates to:
  /// **'ParlerAI Plus'**
  String get parlerAIPlus;

  /// No description provided for @restorePurchase.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchase'**
  String get restorePurchase;

  /// No description provided for @iapValidUntilTheDate.
  ///
  /// In en, this message translates to:
  /// **'Valid until {theDate}'**
  String iapValidUntilTheDate(String theDate);

  /// No description provided for @appleTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Apple\'s Standard EULA'**
  String get appleTermsOfUse;

  /// No description provided for @iapIHaveReadAndConsentedTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'I have read and consented to the {TermsOfUse}, the {PrivacyPolicy}, and the {EULA}.'**
  String iapIHaveReadAndConsentedTermsOfUse(
      String TermsOfUse, String PrivacyPolicy, String EULA);

  /// No description provided for @learnFrench.
  ///
  /// In en, this message translates to:
  /// **'Learn French?'**
  String get learnFrench;

  /// No description provided for @callToParlerAI.
  ///
  /// In en, this message translates to:
  /// **'Call ParlerAI now!'**
  String get callToParlerAI;

  /// No description provided for @helloYouWantToLearnFrenchWithOceane.
  ///
  /// In en, this message translates to:
  /// **'Hi there! Would you like to learn French with your friend Parlerai?'**
  String get helloYouWantToLearnFrenchWithOceane;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'el',
        'en',
        'es',
        'fr',
        'hi',
        'hu',
        'id',
        'it',
        'ja',
        'ko',
        'ms',
        'pl',
        'pt',
        'ro',
        'ru',
        'th',
        'tr',
        'uk',
        'vi',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'hu':
      return AppLocalizationsHu();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ms':
      return AppLocalizationsMs();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

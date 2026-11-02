import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Prep Simulator for NTS'**
  String get appTitle;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this. Please restart the app. ({code})'**
  String loadError(String code);

  /// No description provided for @tabTests.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get tabTests;

  /// No description provided for @tabPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get tabPractice;

  /// No description provided for @tabGuide.
  ///
  /// In en, this message translates to:
  /// **'Guidance'**
  String get tabGuide;

  /// No description provided for @tabProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get tabProgress;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @testsIntro.
  ///
  /// In en, this message translates to:
  /// **'{count} questions in {minutes} minutes. 20 full-length tests.'**
  String testsIntro(int count, int minutes);

  /// No description provided for @testNumber.
  ///
  /// In en, this message translates to:
  /// **'Test {number}'**
  String testNumber(int number);

  /// No description provided for @bestScore.
  ///
  /// In en, this message translates to:
  /// **'Best {percent}%'**
  String bestScore(int percent);

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not taken'**
  String get notStarted;

  /// No description provided for @sectionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String sectionCount(int count);

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String minutesLabel(int minutes);

  /// No description provided for @useEthics.
  ///
  /// In en, this message translates to:
  /// **'I will sit Ethics instead of Islamic Studies'**
  String get useEthics;

  /// No description provided for @useEthicsHelp.
  ///
  /// In en, this message translates to:
  /// **'Non-Muslim candidates are usually offered Ethics. Check your test notice.'**
  String get useEthicsHelp;

  /// No description provided for @startTest.
  ///
  /// In en, this message translates to:
  /// **'Start test'**
  String get startTest;

  /// No description provided for @resumeTest.
  ///
  /// In en, this message translates to:
  /// **'Resume test'**
  String get resumeTest;

  /// No description provided for @restartTest.
  ///
  /// In en, this message translates to:
  /// **'Start again'**
  String get restartTest;

  /// No description provided for @paperRules.
  ///
  /// In en, this message translates to:
  /// **'Timed like the real test. You can move between questions, flag them and change answers. The timer pauses if you leave the test.'**
  String get paperRules;

  /// No description provided for @unofficialNote.
  ///
  /// In en, this message translates to:
  /// **'Independent practice test. Real papers can differ, so always follow your own NTS test notice.'**
  String get unofficialNote;

  /// No description provided for @previousAttempts.
  ///
  /// In en, this message translates to:
  /// **'Previous attempts'**
  String get previousAttempts;

  /// No description provided for @questionOf.
  ///
  /// In en, this message translates to:
  /// **'Question {number} of {total}'**
  String questionOf(int number, int total);

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @flag.
  ///
  /// In en, this message translates to:
  /// **'Flag'**
  String get flag;

  /// No description provided for @unflag.
  ///
  /// In en, this message translates to:
  /// **'Unflag'**
  String get unflag;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questions;

  /// No description provided for @clearAnswer.
  ///
  /// In en, this message translates to:
  /// **'Clear answer'**
  String get clearAnswer;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit test'**
  String get submit;

  /// No description provided for @submitTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit this test?'**
  String get submitTitle;

  /// No description provided for @submitBody.
  ///
  /// In en, this message translates to:
  /// **'Answered {answered} of {total}. Flagged {flagged}. You cannot change answers after submitting.'**
  String submitBody(int answered, int total, int flagged);

  /// No description provided for @keepWorking.
  ///
  /// In en, this message translates to:
  /// **'Keep working'**
  String get keepWorking;

  /// No description provided for @leaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this test?'**
  String get leaveTitle;

  /// No description provided for @leaveBody.
  ///
  /// In en, this message translates to:
  /// **'Your answers are saved and the timer pauses. You can resume from the test page.'**
  String get leaveBody;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @readPassage.
  ///
  /// In en, this message translates to:
  /// **'Show passage'**
  String get readPassage;

  /// No description provided for @hidePassage.
  ///
  /// In en, this message translates to:
  /// **'Hide passage'**
  String get hidePassage;

  /// No description provided for @timeLeft.
  ///
  /// In en, this message translates to:
  /// **'Time left'**
  String get timeLeft;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Your result'**
  String get results;

  /// No description provided for @scoreOutOf.
  ///
  /// In en, this message translates to:
  /// **'{correct} / {total}'**
  String scoreOutOf(int correct, int total);

  /// No description provided for @percentLabel.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String percentLabel(int percent);

  /// No description provided for @scoreNote.
  ///
  /// In en, this message translates to:
  /// **'Answered {answered}, skipped {skipped}. This is a practice score, not an official NTS result.'**
  String scoreNote(int answered, int skipped);

  /// No description provided for @bySection.
  ///
  /// In en, this message translates to:
  /// **'By section'**
  String get bySection;

  /// No description provided for @weakTopics.
  ///
  /// In en, this message translates to:
  /// **'Topics to work on'**
  String get weakTopics;

  /// No description provided for @reviewAnswers.
  ///
  /// In en, this message translates to:
  /// **'Review answers and explanations'**
  String get reviewAnswers;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back to tests'**
  String get backHome;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get filterWrong;

  /// No description provided for @filterSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get filterSkipped;

  /// No description provided for @filterEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here.'**
  String get filterEmpty;

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get yourAnswer;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get correctAnswer;

  /// No description provided for @notAnswered.
  ///
  /// In en, this message translates to:
  /// **'Not answered'**
  String get notAnswered;

  /// No description provided for @explanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanation;

  /// No description provided for @practiceIntro.
  ///
  /// In en, this message translates to:
  /// **'Short sets by topic. You see the answer and explanation straight away. These questions are separate from the 20 tests.'**
  String get practiceIntro;

  /// No description provided for @practiceTally.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} right'**
  String practiceTally(int correct, int total);

  /// No description provided for @practiceEmpty.
  ///
  /// In en, this message translates to:
  /// **'Questions for this topic are on the way.'**
  String get practiceEmpty;

  /// No description provided for @checkAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get checkAnswer;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @practiceAgain.
  ///
  /// In en, this message translates to:
  /// **'Practise again'**
  String get practiceAgain;

  /// No description provided for @practiceDone.
  ///
  /// In en, this message translates to:
  /// **'Practice finished'**
  String get practiceDone;

  /// No description provided for @guideLoading.
  ///
  /// In en, this message translates to:
  /// **'Guidance'**
  String get guideLoading;

  /// No description provided for @progressEmpty.
  ///
  /// In en, this message translates to:
  /// **'Finish a test or a practice set to see your progress here.'**
  String get progressEmpty;

  /// No description provided for @testsTaken.
  ///
  /// In en, this message translates to:
  /// **'Tests taken'**
  String get testsTaken;

  /// No description provided for @averageScore.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get averageScore;

  /// No description provided for @bestOverall.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get bestOverall;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'Test history'**
  String get history;

  /// No description provided for @topicMastery.
  ///
  /// In en, this message translates to:
  /// **'Weakest topics'**
  String get topicMastery;

  /// No description provided for @deleteAttempt.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAttempt;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Prep Simulator for NTS is an independent practice app by HomiLabs. It is not affiliated with, endorsed by or connected to the National Testing Service (NTS) or any employer or university. All questions are original practice material, not real NTS papers, and scores are for practice only.'**
  String get aboutBody;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacy;

  /// No description provided for @privacyChoices.
  ///
  /// In en, this message translates to:
  /// **'Privacy choices'**
  String get privacyChoices;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get terms;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact: homilabs.smc@gmail.com'**
  String get contact;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review answers'**
  String get reviewTitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

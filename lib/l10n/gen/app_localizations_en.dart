// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Prep Simulator for NTS';

  @override
  String loadError(String code) {
    return 'Could not load this. Please restart the app. ($code)';
  }

  @override
  String get tabTests => 'Tests';

  @override
  String get tabPractice => 'Practice';

  @override
  String get tabGuide => 'Guidance';

  @override
  String get tabProgress => 'Progress';

  @override
  String get about => 'About';

  @override
  String testsIntro(int count, int minutes) {
    return '$count questions in $minutes minutes. 20 full-length tests.';
  }

  @override
  String testNumber(int number) {
    return 'Test $number';
  }

  @override
  String bestScore(int percent) {
    return 'Best $percent%';
  }

  @override
  String get inProgress => 'In progress';

  @override
  String get notStarted => 'Not taken';

  @override
  String sectionCount(int count) {
    return '$count questions';
  }

  @override
  String minutesLabel(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get useEthics => 'I will sit Ethics instead of Islamic Studies';

  @override
  String get useEthicsHelp =>
      'Non-Muslim candidates are usually offered Ethics. Check your test notice.';

  @override
  String get startTest => 'Start test';

  @override
  String get resumeTest => 'Resume test';

  @override
  String get restartTest => 'Start again';

  @override
  String get paperRules =>
      'Timed like the real test. You can move between questions, flag them and change answers. The timer pauses if you leave the test.';

  @override
  String get unofficialNote =>
      'Independent practice test. Real papers can differ, so always follow your own NTS test notice.';

  @override
  String get previousAttempts => 'Previous attempts';

  @override
  String questionOf(int number, int total) {
    return 'Question $number of $total';
  }

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get flag => 'Flag';

  @override
  String get unflag => 'Unflag';

  @override
  String get questions => 'Questions';

  @override
  String get clearAnswer => 'Clear answer';

  @override
  String get submit => 'Submit test';

  @override
  String get submitTitle => 'Submit this test?';

  @override
  String submitBody(int answered, int total, int flagged) {
    return 'Answered $answered of $total. Flagged $flagged. You cannot change answers after submitting.';
  }

  @override
  String get keepWorking => 'Keep working';

  @override
  String get leaveTitle => 'Leave this test?';

  @override
  String get leaveBody =>
      'Your answers are saved and the timer pauses. You can resume from the test page.';

  @override
  String get leave => 'Leave';

  @override
  String get stay => 'Stay';

  @override
  String get readPassage => 'Show passage';

  @override
  String get hidePassage => 'Hide passage';

  @override
  String get timeLeft => 'Time left';

  @override
  String get results => 'Your result';

  @override
  String scoreOutOf(int correct, int total) {
    return '$correct / $total';
  }

  @override
  String percentLabel(int percent) {
    return '$percent%';
  }

  @override
  String scoreNote(int answered, int skipped) {
    return 'Answered $answered, skipped $skipped. This is a practice score, not an official NTS result.';
  }

  @override
  String get bySection => 'By section';

  @override
  String get weakTopics => 'Topics to work on';

  @override
  String get reviewAnswers => 'Review answers and explanations';

  @override
  String get backHome => 'Back to tests';

  @override
  String get filterAll => 'All';

  @override
  String get filterWrong => 'Wrong';

  @override
  String get filterSkipped => 'Skipped';

  @override
  String get filterEmpty => 'Nothing here.';

  @override
  String get yourAnswer => 'Your answer';

  @override
  String get correctAnswer => 'Correct answer';

  @override
  String get notAnswered => 'Not answered';

  @override
  String get explanation => 'Explanation';

  @override
  String get practiceIntro =>
      'Short sets by topic. You see the answer and explanation straight away. These questions are separate from the 20 tests.';

  @override
  String practiceTally(int correct, int total) {
    return '$correct of $total right';
  }

  @override
  String get practiceEmpty => 'Questions for this topic are on the way.';

  @override
  String get checkAnswer => 'Check';

  @override
  String get finish => 'Finish';

  @override
  String get practiceAgain => 'Practise again';

  @override
  String get practiceDone => 'Practice finished';

  @override
  String get guideLoading => 'Guidance';

  @override
  String get progressEmpty => 'Finish a test or a practice set to see your progress here.';

  @override
  String get testsTaken => 'Tests taken';

  @override
  String get averageScore => 'Average';

  @override
  String get bestOverall => 'Best';

  @override
  String get history => 'Test history';

  @override
  String get topicMastery => 'Weakest topics';

  @override
  String get deleteAttempt => 'Delete';

  @override
  String get aboutBody =>
      'Prep Simulator for NTS is an independent practice app by HomiLabs. It is not affiliated with, endorsed by or connected to the National Testing Service (NTS) or any employer or university. All questions are original practice material, not real NTS papers, and scores are for practice only.';

  @override
  String get privacy => 'Privacy policy';

  @override
  String get terms => 'Terms of use';

  @override
  String get website => 'Website';

  @override
  String get contact => 'Contact: homilabs.smc@gmail.com';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get reviewTitle => 'Review answers';
}

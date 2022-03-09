import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class FallbackCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ja';

  @override
  Future<CupertinoLocalizations> load(Locale locale) => JapaneseCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;

  @override
  String toString() => 'DefaultCupertinoLocalizations.delegate(ja_JP)';
}


/// US English strings for the cupertino widgets.
class JapaneseCupertinoLocalizations implements CupertinoLocalizations {
  /// Constructs an object that defines the cupertino widgets' localized strings
  /// for US English (only).
  ///
  /// [LocalizationsDelegate] implementations typically call the static [load]
  /// function, rather than constructing this class directly.
  const JapaneseCupertinoLocalizations();

  // The global version uses the translated string from the arb file.
  String get todayLabel => '今日';

  static const List<String> _shortWeekdays = <String>[
    '月',
    '火',
    '水',
    '木',
    '金',
    '土',
    '日',
  ];

  static const List<String> _shortMonths = <String>[
    '１月',
    '２月',
    '３月',
    '４月',
    '５月',
    '６月',
    '７月',
    '８月',
    '９月',
    '10月',
    '11月',
    '12月',
  ];

  static const List<String> _months = <String>[
    '１月',
    '２月',
    '３月',
    '４月',
    '５月',
    '６月',
    '７月',
    '８月',
    '９月',
    '10月',
    '11月',
    '12月',
  ];

  @override
  String datePickerYear(int yearIndex) => yearIndex.toString();

  @override
  String datePickerMonth(int monthIndex) => _months[monthIndex - 1];

  @override
  String datePickerDayOfMonth(int dayIndex) => dayIndex.toString();

  @override
  String datePickerHour(int hour) => hour.toString();

  @override
  String datePickerHourSemanticsLabel(int hour) => hour.toString() + " 時";

  @override
  String datePickerMinute(int minute) => minute.toString().padLeft(2, '0');

  @override
  String datePickerMinuteSemanticsLabel(int minute) {
    return minute.toString() + ' 分';
  }

  @override
  String datePickerMediumDate(DateTime date) {
    return '${_shortWeekdays[date.weekday - DateTime.monday]} '
        '${_shortMonths[date.month - DateTime.january]} '
        '${date.day.toString().padRight(2)}';
  }

  @override
  DatePickerDateOrder get datePickerDateOrder => DatePickerDateOrder.mdy;

  @override
  DatePickerDateTimeOrder get datePickerDateTimeOrder => DatePickerDateTimeOrder.date_time_dayPeriod;

  @override
  String get anteMeridiemAbbreviation => 'AM';

  @override
  String get postMeridiemAbbreviation => 'PM';

  @override
  String get alertDialogLabel => 'Info';

  @override
  String timerPickerHour(int hour) => hour.toString();

  @override
  String timerPickerMinute(int minute) => minute.toString();

  @override
  String timerPickerSecond(int second) => second.toString();

  @override
  String timerPickerHourLabel(int hour) => '時';

  @override
  String timerPickerMinuteLabel(int minute) => '分';

  @override
  String timerPickerSecondLabel(int second) => '秒';

  @override
  String get cutButtonLabel => 'カット';

  @override
  String get copyButtonLabel => 'コピー';

  @override
  String get pasteButtonLabel => 'ペースト';

  @override
  String get selectAllButtonLabel => '全て選択';

  /// Creates an object that provides US English resource values for the
  /// cupertino library widgets.
  ///
  /// The [locale] parameter is ignored.
  ///
  /// This method is typically used to create a [LocalizationsDelegate].
  static Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<CupertinoLocalizations>(const JapaneseCupertinoLocalizations());
  }

  /// A [LocalizationsDelegate] that uses [DefaultCupertinoLocalizations.load]
  /// to create an instance of this class.
  static const LocalizationsDelegate<CupertinoLocalizations> delegate = FallbackCupertinoLocalizationsDelegate();

  @override
  String get modalBarrierDismissLabel => 'Dismiss';

  @override
  String tabSemanticsLabel({int tabIndex, int tabCount}) {
    return '$tabIndex/$tabCount';
  }
}

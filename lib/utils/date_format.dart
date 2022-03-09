import 'package:intl/intl.dart';

String dateFormat(DateTime date) {
  final formatter = DateFormat('yyyy.MM.dd');
  return formatter.format(date);
}

String dateFormatJp(DateTime date) {
  final formatter = DateFormat('yyyy年MM月dd日');
  return formatter.format(date);
}

String dateFormatTime(DateTime dateTime) {
  final formatter = DateFormat("HH:mm");
  return formatter.format(dateTime);
}

String dateFormatLiveEvent(DateTime date) {
  final formatter = DateFormat('yyyy年MM月dd日HH:mm');
  return formatter.format(date);
}

String dateFormatLiveEventRelay(DateTime dateTime) {
  final formatter = DateFormat("M月d日HH:mm");
  return formatter.format(dateTime);
}

String dateFormatChat(DateTime dateTime) {
  final formatter = DateFormat("M/d HH:mm");
  return formatter.format(dateTime);
}

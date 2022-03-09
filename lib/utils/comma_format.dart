import 'package:intl/intl.dart';

String commaFormat(int number) {
  final NumberFormat format = NumberFormat('#,###', 'ja_JP');
  return format.format(number);
}

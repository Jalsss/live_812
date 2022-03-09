import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';

class CustomValidator {
  static String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value))
      return Lang.ENTER_EMAIL;
    else
      return null;
  }

  static String validateNickName(String value) {
    if (value.length < 3)
      return Lang.ENTER_NICKNAME;
    else
      return null;
  }

  static String validatePassword(String value) {
    Pattern pattern = r'^[0-9a-zA-Z\-_@.]+$';
    RegExp regex = RegExp(pattern);
    if (value.length < Consts.MIN_PASSWORD_LENGTH ||
        value.length > Consts.MAX_PASSWORD_LENGTH ||
        !regex.hasMatch(value))
      return Lang.ENTER_PASSWORD;
    else
      return null;
  }

  static String validateChatMessage(String value) {
    if (value.length > Consts.MAX_CHAT_MESSAGE_LENGTH)
      return Lang.CHAT_MESSAGE_TOO_LONG;
    else
      return null;
  }

  static String validateRequired(String value, {int minLength = 1}) {
    if (value == null || value.length < minLength)
      return Lang.REQUIRED;
    else
      return null;
  }

  static String validateNumber(String value, {int order}) {
    final exp = RegExp(r'^\d+$');
    if (value == null || !exp.hasMatch(value))
      return Lang.NUMBER_REQUIRED;
    else if (order != null && value.length != order)
      return Lang.NUMBER_REQUIRED;
    else
      return null;
  }

  static String validateShipping(String value) {
    final exp = RegExp(r'^\d+$');
    if (value == null || !exp.hasMatch(value)) {
      return Lang.REQUIRED;
    }
    int shipping = int.tryParse(value) ?? 0;
    if ((shipping < Consts.MIN_SHIPPING_DAY) ||
        (Consts.MAX_SHIPPING_DAY < shipping)) {
      return Lang.SHIPPING_REQUIRED;
    }
    return null;
  }

  static String validatePrice(String value) {
    final exp = RegExp(r'^\d+$');
    if (value == null || !exp.hasMatch(value) || int.tryParse(value) <= 0)
      return Lang.PRICE_REQUIRED;
    else
      return null;
  }

  static String validateRealName(String value) {
    if (value.isEmpty)
      return Lang.ENTER_TEXT;
    else
      return null;
  }

  static String validateAddress(String value) {
    if (value.isEmpty)
      return Lang.ENTER_TEXT;
    else
      return null;
  }

  static String validatePhoneNumber(String value) {
    final exp = RegExp(r'^\d+$');
    if (value == null || !exp.hasMatch(value))
      return Lang.PHONE_NUMBER_REQUIRED;
    else
      return null;
  }
}

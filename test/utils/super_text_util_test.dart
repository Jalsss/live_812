import 'package:flutter_test/flutter_test.dart';
import 'package:live812/utils/super_text_util.dart';

void main() {
  test('text', () {
    expect(
        SuperTextUtil.parse('hello'),
        [SuperText(SuperTextType.Text, 'hello')]);
  });
  test('url', () {
    expect(
        SuperTextUtil.parse('https://www.example.com/'),
        [SuperText(SuperTextType.Url, 'https://www.example.com/')]);
  });

  test('mixed', () {
    final url = 'https://www3.example.com/_!?/+-~=;.,*&@#\$%()\'[]';
    expect(
        SuperTextUtil.parse('hello $url world!\nhttp://www.abc.com'),
        [
          SuperText(SuperTextType.Text, 'hello '),
          SuperText(SuperTextType.Url, url),
          SuperText(SuperTextType.Text, ' world!\n'),
          SuperText(SuperTextType.Url, 'http://www.abc.com'),
        ]);
  });

  test('w/o deliminator', () {
    expect(
        SuperTextUtil.parse('needdelimhttp://aaa.jp'),
        [SuperText(SuperTextType.Text, 'needdelimhttp://aaa.jp')]);
  });
}

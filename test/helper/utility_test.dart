import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:test/test.dart';

void main() {
  group("Check Date time", () {
    test('Check post time', () {
      var date = DateTime.now().toUtc();
      var now = getChatTime(date.toString());
      expect(now, "now");

      var sec = getChatTime(date.add(Duration(seconds: -8)).toString());
      expect(sec, "8 s");

      var min = getChatTime(date.add(Duration(minutes: -8)).toString());
      expect(min, "8 m");

      var hour = getChatTime(date.add(Duration(hours: -8)).toString());
      expect(hour, "8 h");

      var yesterday = getChatTime(date.add(Duration(days: -1)).toString());
      expect(yesterday, "yesterday");

      var randomDate = getChatTime("2020-03-19T14:12:46.286410");
      expect(randomDate, "19 Mar");
    });

    test('Check Social Links', () {
      var url1 = getSocialLinks("google.com");
      expect(url1, "https://www.google.com");

      var url2 = getSocialLinks("www.google.com");
      expect(url2, "https://www.google.com");

      var url3 = getSocialLinks("http://www.google.com");
      expect(url3, "http://www.google.com");

      var url4 = getSocialLinks("https://www.google.com");
      expect(url4, "https://www.google.com");
    });

    test("Validate Email", () {
      final email1 = validateEmal("test@gmail.com");
      expect(true, email1);

      final email2 = validateEmal("test@gmail.com.com");
      expect(true, email2);

      final email3 = validateEmal("test@gmailcom");
      expect(false, email3);

      final email4 = validateEmal("testgmail.com");
      expect(false, email4);

      final email5 = validateEmal("@testgmail.com");
      expect(false, email5);
    });
  });
}

import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:test/test.dart';

void main() {
  group("Check Date time", () {
    test('Check post time', () {
      var date = DateTime.now().toUtc();
      var now = Utility.getChatTime(date.toString());
      expect(now, "now");

      var sec = Utility.getChatTime(date.add(Duration(seconds: -8)).toString());
      expect(sec, "8 s");

      var min = Utility.getChatTime(date.add(Duration(minutes: -8)).toString());
      expect(min, "8 m");

      var hour = Utility.getChatTime(date.add(Duration(hours: -8)).toString());
      expect(hour, "8 h");

      var yesterday =
          Utility.getChatTime(date.add(Duration(days: -1)).toString());
      expect(yesterday, "1d");

      var randomDate = Utility.getChatTime("2020-03-19T14:12:46.286410");
      expect(randomDate, "19 Mar");
    });

    test('Check Social Links', () {
      var url1 = Utility.getSocialLinks("google.com");
      expect(url1, "https://www.google.com");

      var url2 = Utility.getSocialLinks("www.google.com");
      expect(url2, "https://www.google.com");

      var url3 = Utility.getSocialLinks("http://www.google.com");
      expect(url3, "http://www.google.com");

      var url4 = Utility.getSocialLinks("https://www.google.com");
      expect(url4, "https://www.google.com");
    });

    test("Validate Email", () {
      final email1 = Utility.validateEmail("test@gmail.com");
      expect(true, email1);

      final email2 = Utility.validateEmail("test@gmail.com.com");
      expect(true, email2);

      final email3 = Utility.validateEmail("test@gmailcom");
      expect(false, email3);

      final email4 = Utility.validateEmail("testgmail.com");
      expect(false, email4);

      final email5 = Utility.validateEmail("@testgmail.com");
      expect(false, email5);
    });
  });
}

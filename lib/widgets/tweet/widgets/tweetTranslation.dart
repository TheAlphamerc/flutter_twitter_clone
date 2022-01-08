import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/url_text/customUrlText.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';

class TweetTranslation extends StatelessWidget {
  final String description;
  final String tweetKey;
  final TextStyle? textStyle;
  final TextStyle? urlStyle;
  final String? languageCode;
  const TweetTranslation(
      {Key? key,
      required this.tweetKey,
      required this.description,
      required this.languageCode,
      this.textStyle,
      this.urlStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String localeLanguageTag = Utility.getLocale(context).toLanguageTag();
    String localeLanguageCode = localeLanguageTag.split('-')[0];
    var state = Provider.of<FeedState>(context, listen: false);

    try {
      if (/*languageCode == null ||*/ languageCode == localeLanguageCode)
        return SizedBox.shrink();

      if (state.tweetsTranslations.containsKey(tweetKey)) {
        if (state.tweetsTranslations[tweetKey] != null) {
          return _translation(state.tweetsTranslations[tweetKey]!, context,
              textStyle, urlStyle);
        } else {
          return SizedBox.shrink();
        }
      } else {
        return FutureBuilder<Translation>(
          future: GoogleTranslator().translate(description.removeSpaces,
              from: languageCode ?? 'auto', to: localeLanguageCode),
          builder: (BuildContext context, AsyncSnapshot<Translation> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.text == snapshot.data!.source.trim()) {
                state.tweetsTranslations[tweetKey] = null;
                return SizedBox.shrink();
              }
              state.tweetsTranslations[tweetKey] = snapshot.data!;

              return _translation(snapshot.data!, context, textStyle, urlStyle);
            }
            if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return SizedBox.shrink();
          },
        );
      }
    } catch (e) {
      cprint(e);
      return SizedBox.shrink();
    }
  }
}

Widget _translation(Translation translation, BuildContext context,
    TextStyle? textStyle, TextStyle? urlStyle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Divider(thickness: 1),
            Row(
              children: [
                Text(
                  "Translated from ${translation.sourceLanguage} ",
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColor.lightGrey,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      UrlText(
        text: translation.text,
        onHashTagPressed: (tag) {
          cprint(tag);
        },
        style: textStyle,
        urlStyle: urlStyle,
      ),
    ],
  );
}

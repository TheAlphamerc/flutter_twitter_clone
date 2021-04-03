import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';

class LinkPreview extends StatelessWidget {
  const LinkPreview({Key key, this.url, this.text}) : super(key: key);
  final String url;
  final String text;

  /// Extract the url from text
  /// If text contains multiple weburl then only first url will be returned to fetch the url meta
  String getUrl() {
    if (text == null) {
      return null;
    }
    RegExp reg = RegExp(
        r"(https?|http)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]*");
    Iterable<Match> _matches = reg.allMatches(text);
    if (_matches.isNotEmpty) {
      return _matches.first.group(0);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var uri = url ?? getUrl();
    if (uri == null) {
      return SizedBox.shrink();
    }
    return FlutterLinkPreview(
      url: uri,
      builder: (info) {
        if (info == null) return const SizedBox();
        if (info is WebImageInfo) {
          return customInkWell(
            context: context,
            radius: BorderRadius.circular(10),
            onPressed: () {
              Utility.launchURL(url);
            },
            child: CachedNetworkImage(
              imageUrl: info.image,
              fit: BoxFit.contain,
            ),
          );
        }
        final WebInfo webInfo = info;

        if (!WebAnalyzer.isNotEmpty(webInfo.title)) return const SizedBox();
        return customInkWell(
          context: context,
          radius: BorderRadius.circular(10),
          onPressed: () {
            Utility.launchURL(url);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.extraLightGrey),
              color: webInfo.image != null
                  ? Theme.of(context).colorScheme.onPrimary
                  : const Color(0xFFF0F1F2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (webInfo.image != null && webInfo.image.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10)),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: webInfo.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (WebAnalyzer.isNotEmpty(webInfo.title)) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      webInfo.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.titleStyle,
                    ),
                  ),
                ],
                Padding(
                  padding: EdgeInsets.only(bottom: 5, left: 8, right: 8),
                  child: Text(
                    url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.subtitleStyle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

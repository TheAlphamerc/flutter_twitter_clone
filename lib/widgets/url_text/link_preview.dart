import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';

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
      showMultimedia: true,
      useMultithread: true,
      // cache: Duration(hours: 1),
      builder: (info) {
        if (info == null) return const SizedBox();
        if (info is WebImageInfo) {
          return CachedNetworkImage(
            imageUrl: info.image,
            fit: BoxFit.contain,
          ).ripple(
            () {
              Utility.launchURL(url);
            },
            borderRadius: BorderRadius.circular(10),
          );
        }
        final WebInfo webInfo = info;

        if (!WebAnalyzer.isNotEmpty(webInfo.title)) return const SizedBox();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.extraLightGrey),
              color: webInfo.image != null
                  ? Theme.of(context).colorScheme.onPrimary
                  : const Color(0xFFFAFAFA),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (webInfo.image != null && webInfo.image.isNotEmpty)
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10)),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context).dividerColor, width: 1),
                        ),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: webInfo.image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                if (WebAnalyzer.isNotEmpty(webInfo.title))
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      webInfo.title.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.titleStyle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(bottom: 5, left: 8, right: 8),
                  child: Text(
                    Uri.tryParse(url).authority,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.subtitleStyle.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize:
                            WebAnalyzer.isNotEmpty(webInfo.title) ? 14 : 16),
                  ),
                ),
              ],
            ),
          ).ripple(
            () {
              Utility.launchURL(url);
            },
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}

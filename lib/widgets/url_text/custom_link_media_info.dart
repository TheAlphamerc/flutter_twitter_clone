import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_twitter_clone/model/link_media_info.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/url_text/link_preview.dart';
import 'package:flutter_twitter_clone/helper/shared_prefrence_helper.dart';

class CustomLinkMediaInfo extends StatelessWidget {
  const CustomLinkMediaInfo({Key key, this.url, this.text}) : super(key: key);
  final String url;
  final String text;

  String getUrl() {
    if (text == null) {
      return null;
    }
    RegExp reg = RegExp(
        r"([#])\w+| [@]\w+|(https?|ftp|file|#)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]*");
    Iterable<Match> _matches = reg.allMatches(text);
    if (_matches.isNotEmpty) {
      return _matches.first.group(0);
      // return "https://vimeo.com/498010744";
    }
    return null;
  }

  Future<Either<Exception, LinkMediaInfo>> fetchLinkMediaInfoFromApi(
      String url) async {
    try {
      var response = await http.Client()
          .get("https://noembed.com/embed?url=" + url)
          .then((result) => result.body)
          .then(json.decode)
          .then((json) => LinkMediaInfo.fromJson(json));
      return Right(response);
    } catch (error) {
      return Left(error);
    }
  }

  Future<Either<String, LinkMediaInfo>> fetchLinkMediaInfo(String url) async {
    final pref = SharedPreferenceHelper();
    var map = await pref.getLinkMediaInfo(url);

    /// If url metadata is not available in local storage
    /// then fetch url from api
    if (map == null) {
      var response = await fetchLinkMediaInfoFromApi(url);

      return response.fold((l) => Left("Not found"), (r) async {
        await pref.saveLinkMediaInfo(url, r);
        return Right(r);
      });
    }

    /// If meta is available in local storage then no need to call api
    else {
      if (map.title == null) {
        return Left("Not found");
      }
      return Right(map);
    }
  }

  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var uri = url ?? getUrl();
    if (uri == null) {
      return SizedBox();
    }

    /// Only Youtube thumbnail is displayed in `CustomLinkMediaInfo` widget
    /// Other url preview is displayed on `LinkPreview` widget.
    /// `LinkPreview` uses [flutter_link_preview] package to fetch url metadata.
    /// It is seen that `flutter_link_preview` package is unable to fetch youtube metadata
    if (!uri.contains("youtu")) {
      return LinkPreview(
        url: uri,
      );
    }
    return FutureBuilder(
      future: fetchLinkMediaInfo(uri),
      builder:
          (context, AsyncSnapshot<Either<String, LinkMediaInfo>> snapshot) {
        if (snapshot.hasData) {
          var response = snapshot.data;
          return response.fold(
            (l) => SizedBox.shrink(),
            (model) => customInkWell(
              radius: BorderRadius.circular(10),
              context: context,
              onPressed: () {
                Utility.launchURL(uri);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: model.thumbnailUrl != null
                      ? Colors.transparent
                      : const Color(0xFFF0F1F2),
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (model.thumbnailUrl != null)
                      ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10)),
                        child: Container(
                          height: 140,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                model.thumbnailUrl,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding:
                          EdgeInsets.only(bottom: 5, left: 8, right: 8, top: 4),
                      child: Column(
                        children: [
                          if (model.title != null)
                            Text(
                              model.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyles.titleStyle,
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Text(
                                model.providerUrl,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.subtitleStyle,
                              ))
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
        return SizedBox();
      },
    );
  }
}

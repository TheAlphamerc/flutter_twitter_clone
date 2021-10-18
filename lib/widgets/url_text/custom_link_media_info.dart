import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/shared_prefrence_helper.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/model/link_media_info.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/url_text/link_preview.dart';
import 'package:http/http.dart' as http;

class CustomLinkMediaInfo extends StatelessWidget {
  const CustomLinkMediaInfo({Key? key, this.url, this.text}) : super(key: key);
  final String? url;
  final String? text;

  String? getUrl() {
    if (text == null) {
      return null;
    }
    RegExp reg = RegExp(
        r"(https?|http)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]*");
    Iterable<Match> _matches = reg.allMatches(text!);
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
          .get(Uri.tryParse("https://noembed.com/embed?url=" + url)!)
          .then((result) => result.body)
          .then(json.decode)
          .then((json) => LinkMediaInfo.fromJson(json));
      return Right(response);
    } catch (error) {
      return Left(error as Exception);
    }
  }

  Future<Either<String, LinkMediaInfo>> fetchLinkMediaInfo(String url) async {
    final pref = SharedPreferenceHelper();
    var map = await pref.getLinkMediaInfo(url);

    /// If url metadata is not available in local storage
    /// then fetch url from api
    if (map == null) {
      var response = await fetchLinkMediaInfoFromApi(url);

      return response.fold((l) => const Left("Not found"), (r) async {
        await pref.saveLinkMediaInfo(url, r);
        return Right(r);
      });
    }

    /// If meta is available in local storage then no need to call api
    else {
      if (map.title == null) {
        return const Left("Not found");
      }
      return Right(map);
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var uri = url ?? getUrl();
    if (uri == null) {
      return const SizedBox();
    }

    /// Only Youtube thumbnail is displayed in `CustomLinkMediaInfo` widget
    /// Other url preview is displayed on `LinkPreview` widget.
    /// `LinkPreview` uses [flutter_link_preview] package to fetch url metadata.
    /// It is seen that `flutter_link_preview` package is unable to fetch youtube metadata
    if (!uri.contains("youtu")) {
      return LinkPreviewer(
        url: uri,
      );
    }

    /// Youtube thumbnail preview builder
    return FutureBuilder(
      future: fetchLinkMediaInfo(uri),
      builder:
          (context, AsyncSnapshot<Either<String, LinkMediaInfo>> snapshot) {
        if (snapshot.hasData) {
          var response = snapshot.data;
          return response!.fold(
            (l) => const SizedBox.shrink(),
            (model) => Padding(
              padding: const EdgeInsets.only(top: 8.0),
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
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10)),
                        child: Container(
                          height: 140,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                model.thumbnailUrl!,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: model.thumbnailUrl != null
                            ? Theme.of(context).colorScheme.onPrimary
                            : const Color(0xFFF0F1F2),
                      ),
                      padding: const EdgeInsets.only(
                          bottom: 5, left: 8, right: 8, top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (model.title != null)
                            Text(
                              model.title!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  TextStyles.titleStyle.copyWith(fontSize: 14),
                            ),
                          if (model.providerUrl != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Text(
                                  Uri.tryParse(model.providerUrl!)!.authority,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyles.subtitleStyle.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ))
                              ],
                            )
                        ],
                      ),
                    )
                  ],
                ),
              ).ripple(
                () {
                  Utility.launchURL(uri);
                },
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}

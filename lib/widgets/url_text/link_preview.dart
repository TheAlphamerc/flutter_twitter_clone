import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';

import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:provider/provider.dart';

class LinkPreviewer extends StatelessWidget {
  const LinkPreviewer({Key? key, this.url, this.text}) : super(key: key);
  final String? url;
  final String? text;

  /// Extract the url from text
  /// If text contains multiple weburl then only first url will be returned to fetch the url meta
  String? getUrl() {
    if (text == null) {
      return null;
    }

    RegExp reg = RegExp(
        r"(https?|http)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]*");
    Iterable<Match> _matches = reg.allMatches(text!);
    if (_matches.isNotEmpty) {
      return _matches.first.group(0);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<FeedState>(context, listen: false);
    var uri = url ?? getUrl();
    if (uri == null) {
      return const SizedBox.shrink();
    } else if (uri.contains("page.link/")) {
      /// `flutter_link_preview` package is unable to fetch firebase dynamic link meta data
      return const SizedBox.shrink();
    }
    final style = TextStyle(
      fontSize: 0,
    );

    return LinkPreview(
      enableAnimation: false,
      onPreviewDataFetched: (data) {
        state.addPreviewData(uri, data);
      },
      imageBuilder: (image) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: CachedNetworkImage(
            imageUrl: image,
          ),
        ).ripple(() {
          Utility.launchURL(uri);
        });
      },
      linkStyle: style,
      previewData:
          state.linkDataPreviews[uri], // Pass the preview data from the state
      text: uri,
      width: MediaQuery.of(context).size.width,
    );
  }
}

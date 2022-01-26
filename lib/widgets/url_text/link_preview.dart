import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
// ignore: implementation_imports
import 'package:link_preview_generator/src/utils/analyzer.dart'
    show LinkPreviewAnalyzer;
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
    }
    if (state.linkWebInfos.containsKey(uri))
      return _buildLinkPreview(
          state.linkWebInfos[uri]!, uri, Theme.of(context));
    return FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot<InfoBase?> snapshot) {
          if (snapshot.hasData) {
            state.addWebInfo(uri, snapshot.data! as WebInfo);
            return _buildLinkPreview(
                snapshot.data! as WebInfo, uri, Theme.of(context));
          }
          if (snapshot.hasError) {
            return SizedBox.shrink();
          }
          return Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color.fromRGBO(248, 248, 248, 1.0),
            ),
            alignment: Alignment.center,
            child: const Text('Fetching data...'),
          );
        },
        future: LinkPreviewAnalyzer.getInfo(uri,
            cacheDuration: Duration(hours: 24), multimedia: true));
  }

  Widget _buildLinkPreview(WebInfo info, String uri, ThemeData theme) {
    var image = LinkPreviewAnalyzer.isNotEmpty(info.image)
        ? info.image
        : LinkPreviewAnalyzer.isNotEmpty(info.icon)
            ? info.icon
            : ""; //TODO Placeholder/error image
    if (!LinkPreviewAnalyzer.isNotEmpty(info.title) &&
        LinkPreviewAnalyzer.isNotEmpty(info.image)) {
      return CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.contain,
      ).ripple(
        () {
          Utility.launchURL(uri);
        },
        borderRadius: BorderRadius.circular(10),
      );
    }
    if (!LinkPreviewAnalyzer.isNotEmpty(info.title)) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColor.extraLightGrey),
            color: theme.colorScheme.onPrimary),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (LinkPreviewAnalyzer.isNotEmpty(image))
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: theme.dividerColor, width: 1),
                    ),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            if (LinkPreviewAnalyzer.isNotEmpty(info.title))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  info.title.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.titleStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
            if (LinkPreviewAnalyzer.isNotEmpty(info.description))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  info.description.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.subtitleStyle.copyWith(fontSize: 12),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(bottom: 5, left: 8, right: 8),
              child: Text(
                Uri.tryParse(uri)!.authority,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.subtitleStyle.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: info.title.isNotEmpty ? 14 : 16),
              ),
            ),
          ],
        ),
      ).ripple(
        () {
          Utility.launchURL(uri);
        },
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

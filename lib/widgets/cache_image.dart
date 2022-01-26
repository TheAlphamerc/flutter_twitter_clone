import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';

class CacheImage extends StatelessWidget {
  const CacheImage({
    Key? key,
    this.path,
    this.fit = BoxFit.contain,
    this.errorWidget,
  }) : super(key: key);
  final String? path;
  final BoxFit fit;
  final Widget? errorWidget;

  Widget customNetworkImage(String? path, {BoxFit fit = BoxFit.contain}) {
    return CachedNetworkImage(
      fit: fit,
      imageUrl: path ?? Constants.dummyProfilePic,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: fit,
          ),
        ),
      ),
      placeholderFadeInDuration: const Duration(milliseconds: 500),
      placeholder: (context, url) => Container(
        color: const Color(0xffeeeeee),
      ),
      cacheKey: path,
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            color: const Color(0xffeeeeee),
            child: Icon(
              Icons.error,
              color: Colors.grey[700],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return customNetworkImage(path, fit: fit);
  }
}

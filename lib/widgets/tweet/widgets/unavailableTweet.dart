import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';

class UnavailableTweet extends StatelessWidget {
  const UnavailableTweet({Key? key, required this.snapshot, required this.type})
      : super(key: key);

  final AsyncSnapshot<FeedModel?> snapshot;
  final TweetType type;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: EdgeInsets.only(
          right: 16,
          top: 5,
          left: type == TweetType.Tweet || type == TweetType.ParentTweet
              ? 70
              : 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppColor.extraLightGrey.withOpacity(.3),
        border: Border.all(color: AppColor.extraLightGrey, width: .5),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: snapshot.connectionState == ConnectionState.waiting
          ? SizedBox(
              height: 2,
              child: LinearProgressIndicator(
                backgroundColor: AppColor.extraLightGrey,
                valueColor: AlwaysStoppedAnimation(
                  AppColor.darkGrey.withOpacity(.3),
                ),
              ),
            )
          : Text('This Tweet is unavailable', style: TextStyles.userNameStyle),
    );
  }
}

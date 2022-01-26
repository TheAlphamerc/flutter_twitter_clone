import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/ui/theme/theme.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/title_text.dart';

class EmptyList extends StatelessWidget {
  const EmptyList(this.title, {Key? key, required this.subTitle});

  final String? subTitle;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: context.height - 135,
        color: TwitterColor.mystic,
        child: NotifyText(
          title: title,
          subTitle: subTitle,
        ));
  }
}

class NotifyText extends StatelessWidget {
  final String? subTitle;
  final String? title;
  const NotifyText({Key? key, this.subTitle, this.title})
      : assert(title != null || subTitle != null,
            'title and subTitle must not be null'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (title != null)
          TitleText(title!, fontSize: 20, textAlign: TextAlign.center),
        if (subTitle != null) ...[
          const SizedBox(height: 20),
          TitleText(
            subTitle!,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColor.darkGrey,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';

class ComposeTweetImage extends StatelessWidget {
  final File image;
  final Function onCrossIconPressed;
  const ComposeTweetImage({Key key, this.image, this.onCrossIconPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: image == null
          ? Container()
          : Stack(
              children: <Widget>[
                Container(
                  alignment: Alignment.topRight,
                  child: Container(
                    height: 220,
                    width: fullWidth(context) * .8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      image: DecorationImage(
                          image: FileImage(image), fit: BoxFit.cover),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.black54),
                    child: IconButton(
                      padding: EdgeInsets.all(0),
                      iconSize: 20,
                      onPressed: onCrossIconPressed,
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}

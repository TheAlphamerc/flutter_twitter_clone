import 'dart:convert';

import 'package:equatable/equatable.dart';

class LinkMediaInfo extends Equatable {
  final String? title;
  final String? html;
  final int? height;
  final String? version;
  final int? thumbnailHeight;
  final String? providerUrl;
  final int? width;
  final String? providerName;
  final String? url;
  final String? type;
  final String? authorUrl;
  final String? thumbnailUrl;
  final int? thumbnailWidth;
  final String? authorName;

  const LinkMediaInfo({
    this.type,
    this.providerUrl,
    this.thumbnailHeight,
    this.authorUrl,
    this.thumbnailWidth,
    this.height,
    this.thumbnailUrl,
    this.providerName,
    this.width,
    this.title,
    this.url,
    this.authorName,
    this.html,
    this.version,
  });

  factory LinkMediaInfo.fromRawJson(String str) =>
      LinkMediaInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LinkMediaInfo.fromJson(Map<String, dynamic> json) => LinkMediaInfo(
        type: json["type"],
        providerUrl: json["provider_url"],
        thumbnailHeight:
            json["thumbnail_height"],
        authorUrl: json["author_url"],
        thumbnailWidth:
            json["thumbnail_width"],
        height: json["height"],
        thumbnailUrl:
            json["thumbnail_url"],
        providerName:
            json["provider_name"],
        width: json["width"],
        title: json["title"],
        url: json["url"],
        authorName: json["author_name"],
        html: json["html"],
        version: json["version"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "provider_url": providerUrl,
        "thumbnail_height": thumbnailHeight,
        "author_url": authorUrl,
        "thumbnail_width": thumbnailWidth,
        "height": height,
        "thumbnail_url": thumbnailUrl,
        "provider_name": providerName,
        "width": width,
        "title": title,
        "url": url,
        "author_name": authorName,
        "html": html,
        "version": version,
      };

  @override
  List<Object?> get props => [
        type,
        url,
        providerName,
        width,
        title,
        thumbnailHeight,
        height
      ];
}

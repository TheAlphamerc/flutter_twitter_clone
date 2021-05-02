import 'dart:convert';

import 'package:equatable/equatable.dart';

class LinkMediaInfo extends Equatable {
  final String title;
  final String html;
  final int height;
  final String version;
  final int thumbnailHeight;
  final String providerUrl;
  final int width;
  final String providerName;
  final String url;
  final String type;
  final String authorUrl;
  final String thumbnailUrl;
  final int thumbnailWidth;
  final String authorName;

  LinkMediaInfo({
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
        type: json["type"] == null ? null : json["type"],
        providerUrl: json["provider_url"] == null ? null : json["provider_url"],
        thumbnailHeight:
            json["thumbnail_height"] == null ? null : json["thumbnail_height"],
        authorUrl: json["author_url"] == null ? null : json["author_url"],
        thumbnailWidth:
            json["thumbnail_width"] == null ? null : json["thumbnail_width"],
        height: json["height"] == null ? null : json["height"],
        thumbnailUrl:
            json["thumbnail_url"] == null ? null : json["thumbnail_url"],
        providerName:
            json["provider_name"] == null ? null : json["provider_name"],
        width: json["width"] == null ? null : json["width"],
        title: json["title"] == null ? null : json["title"],
        url: json["url"] == null ? null : json["url"],
        authorName: json["author_name"] == null ? null : json["author_name"],
        html: json["html"] == null ? null : json["html"],
        version: json["version"] == null ? null : json["version"],
      );

  Map<String, dynamic> toJson() => {
        "type": type == null ? null : type,
        "provider_url": providerUrl == null ? null : providerUrl,
        "thumbnail_height": thumbnailHeight == null ? null : thumbnailHeight,
        "author_url": authorUrl == null ? null : authorUrl,
        "thumbnail_width": thumbnailWidth == null ? null : thumbnailWidth,
        "height": height == null ? null : height,
        "thumbnail_url": thumbnailUrl == null ? null : thumbnailUrl,
        "provider_name": providerName == null ? null : providerName,
        "width": width == null ? null : width,
        "title": title == null ? null : title,
        "url": url == null ? null : url,
        "author_name": authorName == null ? null : authorName,
        "html": html == null ? null : html,
        "version": version == null ? null : version,
      };

  @override
  List<Object> get props => [
        this.type,
        this.url,
        this.providerName,
        this.width,
        this.title,
        this.thumbnailHeight,
        this.height
      ];
}

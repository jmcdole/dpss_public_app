/*
 * UM DPSS Public App
 *
 * Jeffrey T McDole <jmcdole@umich.edu>
 *
 * University of Michigan
 * Division of Public Safety and Security
 *
 * Copyright 2018  Regents of the University of Michigan. All Rights Reserved.
 */

//object to hold latest news
class News {
  final int postingId;
  final String postingType;
  final int postingTypeId;
  final String heading;
  final String url;
  final String wpKey;
  final String datePosted;
  final String thumbnailUrl;
  final String imageUrl;

  News(
      {required this.postingId,
      required this.postingType,
      required this.postingTypeId,
      required this.heading,
      required this.url,
      required this.wpKey,
      required this.datePosted,
      required this.thumbnailUrl,
      required this.imageUrl});

  factory News.fromJson(Map<String, dynamic> json) {
    int id = int.tryParse(json['posting_id']) ?? 0;
    int typeId = int.tryParse(json['posting_type_id']) ?? 0;

    var image = "";

    if (json['thumbnail_url'] == null) {
      image = "https://www.dpss.umich.edu/img/icons/Icon-App-512x512@2x.png";
    } else if (json['thumbnail_url'] == "") {
      image = "https://www.dpss.umich.edu/img/icons/Icon-App-512x512@2x.png";
    } else {
      image = json['thumbnail_url'];
    }

    return News(
        postingId: id,
        postingType: json['posting_type'] as String,
        postingTypeId: typeId,
        heading: json['heading'] as String,
        url: json['url'] as String,
        datePosted: json['date_posted'] as String,
        wpKey: json['wp_key'] as String,
        thumbnailUrl: image,
        imageUrl: json['image_url'] as String);
  }
}

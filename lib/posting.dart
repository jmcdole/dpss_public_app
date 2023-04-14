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
class Post {
  final String postingId;
  final String postingType;
  final String heading;
  final String url;
  final String wpKey;
  final String datePosted;
  final String thumbnailUrl;
  final String imageUrl;

  Post(
      {required this.postingId,
      required this.postingType,
      required this.heading,
      required this.url,
      required this.wpKey,
      required this.datePosted,
      required this.thumbnailUrl,
      required this.imageUrl});

  factory Post.fromJson(Map<String, dynamic> json) {
    //format posting date
    DateTime postingDateFormatted = DateTime.parse(json['date_posted']);

    String month = "";
    switch (postingDateFormatted.month) {
      case 1:
        month = "January";
        break;
      case 2:
        month = "February";
        break;
      case 3:
        month = "March";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "June";
        break;
      case 7:
        month = "July";
        break;
      case 8:
        month = "August";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "October";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "December";
        break;
    }

    String dateSlug = "$month, "
        "${postingDateFormatted.day.toString().padLeft(2, '0')}"
        " ${postingDateFormatted.year.toString().padLeft(2, '0')}";

    return Post(
        postingId: json['posting_id'],
        postingType: json['posting_type'],
        heading: json['heading'],
        url: json['url'],
        wpKey: json['wp_key'],
        datePosted: dateSlug,
        thumbnailUrl: json['thumbnail_url'],
        imageUrl: json['image_url']);
  }
}

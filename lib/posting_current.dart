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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'posting.dart';
import 'news_view.dart';

class CurrentPosting extends StatefulWidget {
  const CurrentPosting({super.key});

  @override
  CurrentPostingState createState() {
    return CurrentPostingState();
  }
}

//widget to display most recent news posting
class CurrentPostingState extends State<CurrentPosting> {
  String url = "";

  @override
  Widget build(context) {
    return FutureBuilder<Post>(
      future: fetchPost(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          //print(snapshot.data.url);
          //print(snapshot.data.postingType);

          String? image = "";
          if (snapshot.data?.thumbnailUrl == null) {
            image =
                "https://www.dpss.umich.edu/img/icons/Icon-App-512x512@2x.png";
          } else if (snapshot.data?.thumbnailUrl == "") {
            image =
                "https://www.dpss.umich.edu/img/icons/Icon-App-512x512@2x.png";
          } else {
            image = snapshot.data?.thumbnailUrl;
          }

          var card = Card(
              elevation: 2.0,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 6.0),
                      child: Text(
                        snapshot.data!.datePosted,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey)),
                          child: Image.network(
                            image!,
                            height: 80.0,
                          ),
                        ),
                      ),
                      title: Text(
                        snapshot.data!.postingType,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      subtitle: Text(snapshot.data!.heading,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w300,
                          )),
                      contentPadding: const EdgeInsets.all(10.0),
                      trailing: const Icon(Icons.keyboard_arrow_right,
                          color: Colors.black12, size: 30.0),
                      onTap: () {
                        url =
                            'https://www.dpss.umich.edu/news/?id=${snapshot.data!.postingId}';

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebViewScreen(
                              url: url,
                              key: UniqueKey(),
                            ),
                          ),
                        );
                      },
                    ),
                  ]));

          return card;
        } else if (snapshot.hasError) {
          if (kDebugMode) {
            print("there was an error...");
            print(snapshot.error);
          }

          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner
        return const CircularProgressIndicator();
      },
    );
  }

  Future<Post> fetchPost() async {
    var url = Uri.https('dpss-public-api.appspot.com', 'api/GetPostings',{'limit': "1"});

    final response = await http
        .get(url);

    final responseJsonArray = json.decode(response.body);
    final responseJson = responseJsonArray[0];

    return Post.fromJson(responseJson);
  }
}

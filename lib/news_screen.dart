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

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'news.dart';
import 'news_list.dart';
import 'navigationbarnew.dart';

Future<List<News>> fetchNews(http.Client client) async {

  var url = Uri.https('dpss-public-api.appspot.com', 'api/GetPostings',{'limit': "15"});
  final response = await client
      .get(url);
  return compute(parseNews, response.body);
}

List<News> parseNews(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<News>((json) => News.fromJson(json)).toList();
}

class NewsScreen extends StatelessWidget {
  final String heading;
  final int currentIndex = -1; // keep track of bottom navigation bar

  const NewsScreen({required Key key, required this.heading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DPSS Current News")),
      body: FutureBuilder<List<News>>(
        future: fetchNews(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            if (kDebugMode) {
              print(snapshot.error);
            }
          }
          return snapshot.hasData
              ? ListNews(
                  posts: snapshot.data,
                  key: UniqueKey(),
                )
              : const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: NavigationBarNew(
        selectedIndex: currentIndex,
        destinations: const [], key: UniqueKey(), referringPage: 1,
      ),
    );
  }
}

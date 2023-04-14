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
import 'news.dart';
import 'news_view.dart';

String url ="";

class ListNews extends StatelessWidget {
  final List<News>? posts;
  const ListNews({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: ListView.builder(

          itemCount: posts?.length,
          itemBuilder: (context, position) {

            return Card (
              elevation: 2.0,
              child: Column(
                children: <Widget>[


                  Padding(
                    padding: const EdgeInsets.only(bottom: 25.0, top: 15.0),
                    child: ListTile(
                      title: Text(
                        posts![position].postingType,
                        style: TextStyle(
                          fontSize: 20.0,

                          color: getColor( posts![position].postingTypeId ),
                          //color: Colors.deepOrangeAccent,
                        ),
                      ),


                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(

                            posts![position].datePosted,

                            style: const TextStyle(
                              fontSize: 12.0,

                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              posts![position].heading,
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),

                        ],
                      ),


                      isThreeLine: true,

                      trailing:
                      const Icon(Icons.keyboard_arrow_right, color: Colors.black12, size: 30.0),

                      leading: Image.network(  posts![position].thumbnailUrl    ,
                        height: 90.0,
                      ),

                      onTap: () => _onTapItem(context, posts![position]),
                    ),
                  ),
                ],
              ),
            );
          }),
    );

  }

  void _onTapItem(BuildContext context, News post) {

    url = 'https://www.dpss.umich.edu/news/?id=${post.postingId}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(url: url, key: UniqueKey(),),
      ),
    );

  }

  Color getColor(int selector) {
    if (selector % 2 == 0) {
      return Colors.blue;
    } else if (selector % 1 == 0) {
      return Colors.redAccent;

    } else {
      return Colors.blueGrey;
    }
  }

}

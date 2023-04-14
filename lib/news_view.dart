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
import 'package:webview_flutter/webview_flutter.dart';
import 'navigationbarnew.dart';

class WebViewScreen extends StatelessWidget {

  final String url;
  final int currentIndex = 1; // keep track of bottom navigation bar
  const WebViewScreen({required Key key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('News Item'),
      ),

      body: WebView(

        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),

      bottomNavigationBar: NavigationBarNew(
        selectedIndex: currentIndex,
        destinations: const [], key: UniqueKey(), referringPage: 1,
      ),

    );
  }
}
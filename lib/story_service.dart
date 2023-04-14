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
import 'package:http/http.dart' as http;
import 'dart:async';

Future<String> send(payload) async {
  var message = 'We were not able to process your message, please try again.';
  var url = "https://secure.dpss.umich.edu/agency/api/PostStory";

  var response = await http.post(
    url as Uri,
    body: payload,
  );

  if (response.statusCode == 200) {
    message = 'Your story has been shared.';
  } else {
    if (kDebugMode) {
      print("error: ${response.statusCode}");
    }
  }
  return message;
}

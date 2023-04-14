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

class CompanyColors {
  CompanyColors._(); // this basically makes it so you can instantiate this class

  static const _bluePrimaryValue = 0xFF00274C;
  static const _maizePrimaryValue = 0xFFffcb05;

  static const MaterialColor maize = MaterialColor(
    _maizePrimaryValue,
    <int, Color>{
      //50: const Color(0xFF0e5ea),
      //100: const Color(0xFFb3bec9),
      //200: const Color(0xFF8093a6),
      //300: const Color(0xFF4d6882),
      //400: const Color(0xFF264767),
      500: Color(_maizePrimaryValue),
      //600: const Color(0xFF002345),
      //700: const Color(0xFF001d3c),
      //800: const Color(0xFF001733),
      //900: const Color(0xFF00e24),
    },
  );

  static const MaterialColor blue = MaterialColor(
    _bluePrimaryValue,
    <int, Color>{
      50: Color(0x0ff0e5ea),
      100: Color(0xFFb3bec9),
      200: Color(0xFF8093a6),
      300: Color(0xFF4d6882),
      400: Color(0xFF264767),
      500: Color(_bluePrimaryValue),
      600: Color(0xFF002345),
      700: Color(0xFF001d3c),
      800: Color(0xFF001733),
      900: Color(0x0ff00e24),
    },
  );
}

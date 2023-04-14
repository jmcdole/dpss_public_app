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

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme.dart' as app_theme;

import 'package:torch_light/torch_light.dart';

import 'dart:io';
import 'contact_us.dart';

class NavigationBarNew extends StatefulWidget {

  //hold value for referring page
  final int referringPage;
  const NavigationBarNew({required Key key, required this.referringPage, required List destinations, required int selectedIndex}) : super(key: key);

  @override
  NavigationBarState createState() => NavigationBarState();
}

class NavigationBarState extends State<NavigationBarNew> {

  @override
  Widget build(context) {

      return Theme(
        data: Theme.of(context).copyWith(
            canvasColor: app_theme.CompanyColors.blue,
            primaryColor: app_theme.CompanyColors.maize,
            textTheme: Theme
                .of(context)
                .textTheme
                .copyWith(
                bodySmall: const TextStyle(color: app_theme.CompanyColors.maize))),
        // sets the inactive color of the `BottomNavigationBar`

        child: BottomNavigationBar(
            fixedColor: app_theme.CompanyColors.maize,
            unselectedItemColor: app_theme.CompanyColors.maize,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.call),
                label: 'Contact Us'),

              BottomNavigationBarItem(
                icon: Icon(Icons.flash_on),
                label: 'Flashlight',)

            ],

            onTap: (int index) async {
              //push to Contact Us Screen
              if (widget.referringPage == 1 && index == 0) {
                log('contact us');
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const ContactUsScreen()),
                );
              } else if (index == 1) {
                try {
                  await TorchLight.enableTorch();
                } on Exception catch (_) {
                 log('Could not enable torch');
                }
            }
            } //currentIndex: page
        ),
      );
    }


  }

  //launch DPSS facebook
  void launchURL(String url) async {
    if (kDebugMode) {
      print('external call...$url');
    }
    if (await canLaunchUrl(url as Uri)) {
      //await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }







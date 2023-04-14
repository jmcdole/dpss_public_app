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
import 'package:url_launcher/url_launcher.dart';

import 'navigationbarnew.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  ContactUsScreenState createState() {
    return ContactUsScreenState();
  }
}

class ContactUsScreenState extends State<ContactUsScreen> {
  int currentIndex = 1; // keep track of bottom navigation bar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact Us")),
      body: Center(
        child: Column(
          children: [
            Flexible(
                child: ListView(
              children: <Widget>[
                //DPSS Numbers
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "UM Division of Public Safety and Security (DPSS)",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),

                Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: Column(
                    children: <Widget>[
                      InkWell(
                        child: const ListTile(
                          leading: Icon(
                            Icons.phone,
                            color: Colors.red,
                          ),
                          title: Text("Emergency"),
                          subtitle: Text('Dial 911'),
                        ),
                        onTap: () {
                          launchCaller("tel:911");
                        },
                      ),
                      InkWell(
                        child: const ListTile(
                          leading: Icon(
                            Icons.phone,
                            color: Colors.blue,
                          ),
                          title: Text("Non-emergency Dispatch"),
                          subtitle: Text('(734) 763-1131'),
                        ),
                        onTap: () {
                          launchCaller("tel:7347631131");
                        },
                      ),
                      InkWell(
                        child: const ListTile(
                          leading: Icon(
                            Icons.phone,
                            color: Colors.grey,
                          ),
                          title: Text("Anonymous Tip Line"),
                          subtitle: Text('(800) 863-1355'),
                        ),
                        onTap: () {
                          launchCaller("tel:8008631355");
                        },
                      ),
                      InkWell(
                        child: const ListTile(
                          leading: Icon(
                            Icons.mail,
                            color: Colors.grey,
                          ),
                          title: Text("Email Us"),
                          subtitle: Text('dpss-safety-secuity@umich.edu'),
                        ),
                        onTap: () {
                          launchCaller("mailto:dpss-safety-secuity@umich.edu");
                        },
                      ),
                      const ListTile(
                        leading: Icon(
                          Icons.share,
                          color: Colors.blue,
                        ),
                        title: Text("Follow us on Twitter"),
                        subtitle: Text('@umichdpss'),
                      ),
                      const ListTile(
                        leading: Icon(
                          Icons.home,
                          color: Colors.blue,
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text('Campus Safety Services Building\n'
                              '1239 Kipke Drive\n'
                              'Ann Arbor, MI 48109-2036\n\n'
                              'Mon-Fri 8am-4:30pm'),
                        ),
                      )
                    ],
                  ),
                ),

                //AAPD Numbers
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Off Campus - Ann Arbor Police (AAPD)",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),

                Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: Column(
                    children: <Widget>[
                      InkWell(
                        child: const ListTile(
                          leading: Icon(
                            Icons.phone,
                            color: Colors.red,
                          ),
                          title: Text("Emergency"),
                          subtitle: Text('Dial 911'),
                        ),
                        onTap: () {
                          launchCaller("tel:911");
                        },
                      ),
                      InkWell(
                        child: const ListTile(
                          leading: Icon(
                            Icons.phone,
                            color: Colors.blue,
                          ),
                          title: Text("Non-emergency Dispatch"),
                          subtitle: Text('(734) 994-2911'),
                        ),
                        onTap: () {
                          launchCaller("tel:7349942911");
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBarNew(
        selectedIndex: currentIndex,
        destinations: const [], key: UniqueKey(), referringPage: 1,
      ),
    );
  }

  // launch url
  void launchCaller(String url) async {
    if (kDebugMode) {
      print('external call...$url');
    }
    if (await canLaunchUrl(url as Uri)) {
      await launchUrl(url as Uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}

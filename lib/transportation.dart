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
import 'theme.dart' as theme;
import 'package:url_launcher/url_launcher.dart';
import 'navigationbarnew.dart';

class TransportationScreen extends StatefulWidget {
  const TransportationScreen({super.key});

  @override
  TransportationScreenState createState() {
    return TransportationScreenState();
  }
}

class TransportationScreenState extends State<TransportationScreen> {
  int currentIndex = 1; // keep track of bottom navigation bar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("After Hours Transportation")),
      body: Center(
        child: Column(
          children: [
            Flexible(
                child: ListView(
              children: <Widget>[
                Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Emergency Ride Home',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                                color: Colors.red),
                          ),
                        ),
                      ),
                      InkWell(
                        child: ListTile(
                          leading: const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                          ),
                          title: const Text(
                              'Free taxi rides can be provided in emergency '
                              'situations for faculty, staff and students to return '
                              'to their vehicle parked in remote lots or to any location '
                              '(home, school, daycare provider, etc.). \n\n'
                              'Eligible '
                              'types of emergencies covered by the program include '
                              'personal or family illness or injury, unscheduled '
                              'overtime or other mandatory work-related holdover, or '
                              'stranded carpool or van pool riders.\n\n'
                              'The service is available 24 hours a day, 7 days a '
                              'week. Use of the program is limited to six times '
                              'per permit year.'),
                          subtitle: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                                child: const Text(
                                    'To request a ride, call the Division of '
                                    'Public Safety and Security directly at (734) 763-1131.'),
                                onTap: () {
                                  launchCaller("tel:7347631131");
                                }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //Ride Home
                Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'After Hours Ride Home',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                                color: theme.CompanyColors.blue),
                          ),
                        ),
                      ),
                      InkWell(
                        child: ListTile(
                          leading: const Icon(
                            Icons.directions_bus,
                            color: Colors.blue,
                          ),
                          title: const Text('Free shared-ride taxis service '
                              'for students, faculty and staff to their '
                              'residence halls, vehicles parked in U-M '
                              'operated lots or structures, or '
                              'local residence (within a one-mile '
                              'radius of Central and North Campuses). '
                              'This service is available after '
                              'U-M transit buses have concluded '
                              'daily service, seven days a week:\n\n'
                              'September through April, 2:00 a.m. - 7:00 a.m. '
                              'May through August, 1:00 a.m. - 7:00 a.m. '
                              'North Campus - rides are available from the Duderstadt Center. \n\n'
                              'Medical Campus - rides are available '
                              'from 1:00 a.m. through 7:00 a.m. from the '
                              'UH South Employee Entrance.\n\n '
                              'Central Campus - rides are available from '
                              'the Shapiro Undergraduate Library.'),
                          subtitle: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              child: const Text(
                                  'To schedule a ride, call 734.647.8000 and '
                                  'select option #2'),
                              onTap: () {
                                launchCaller("tel:7346478000");
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Safe Ride
                Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'After Hours SafeRide',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                                color: theme.CompanyColors.blue),
                          ),
                        ),
                      ),
                      InkWell(
                        child: ListTile(
                          leading: const Icon(
                            Icons.directions_bus,
                            color: Colors.blue,
                          ),
                          title: const Text(
                              'Rides for Students, Faculty, and Staff to '
                              'their residence or parked car within a one '
                              'mile radius of campus.'),
                          subtitle: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: InkWell(
                                    child: const Text('To schedule a ride: '
                                        'call 734.647.8000 and select option #1'),
                                    onTap: () {
                                      launchCaller("tel:7346478000");
                                    },
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                      'OR choose “University of Michigan” in '
                                      'the TapRide mobile app'),
                                ),
                                InkWell(
                                  child: const Text('OR your may visit '
                                      'http://tapride-umich.herokuapp.com/ride '),
                                  onTap: () {
                                    launchCaller(
                                        "http://tapride-umich.herokuapp.com/ride");
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //Night Ride
                Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'After Hours Night Ride Home',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                              color: theme.CompanyColors.blue),
                        ),
                      ),
                      InkWell(
                        child: ListTile(
                          leading: const Icon(
                            Icons.phone,
                            color: Colors.blue,
                          ),
                          title: const Text(
                              'Shared cab ride service. Origination and '
                              'destination must be within a defined area '
                              'that includes Ann Arbor and a small section '
                              'of Ypsilanti.'),
                          subtitle: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              child: const Text(
                                  'To schedule a ride, call 734.647.8000 and'
                                  'select option #3"'),
                              onTap: () {
                                launchCaller("tel:7346478000");
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //Night Ride
                Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'State Street Ride',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                              color: theme.CompanyColors.blue),
                        ),
                      ),
                      InkWell(
                        child: ListTile(
                          leading: const Icon(
                            Icons.phone,
                            color: Colors.blue,
                          ),
                          title: const Text(
                              'Ride from any campus building to the State '
                              'Street commuter lot.'),
                          subtitle: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              child: const Text(
                                  'Call Blue Cab directly 734.547.2222'),
                              onTap: () {
                                launchCaller("tel:7345472222");
                              },
                            ),
                          ),
                        ),
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

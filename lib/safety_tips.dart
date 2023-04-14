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
import 'safety_view.dart';
import 'navigationbarnew.dart';

class SafetyTipsScreen extends StatefulWidget {
  const SafetyTipsScreen({super.key});

  @override
  SafetyTipsScreenState createState() {
    return SafetyTipsScreenState();
  }
}

class SafetyTipsScreenState extends State<SafetyTipsScreen> {
  int currentIndex = 1; // keep track of bottom navigation bar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Safety Tips")),
      body: Center(
          child: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20.0),
        crossAxisSpacing: 10.0,
        crossAxisCount: 2,
        children: <Widget>[
          InkWell(
            onTap: () {
              var url = 'https://dpss.umich.edu/app/active-attacker.html';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SafetyViewScreen(
                    url: url,
                    key: UniqueKey(),
                  ),
                ),
              );
            },
            child: Card(
              elevation: 2.0,
              child:
                  Image.asset('assets/Active-Attacker.png', fit: BoxFit.fill),
            ),
          ),
          InkWell(
            onTap: () {
              var url = 'https://dpss.umich.edu/app/alcohol-drugs.html';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SafetyViewScreen(
                    url: url,
                    key: UniqueKey(),
                  ),
                ),
              );
            },
            child: Card(
              elevation: 2.0,
              child:
                  Image.asset('assets/Alcohol-and-Drugs.png', fit: BoxFit.fill),
            ),
          ),
          InkWell(
            onTap: () {
              var url = 'https://dpss.umich.edu/app/domestic-violence.html';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SafetyViewScreen(
                    url: url,
                    key: UniqueKey(),
                  ),
                ),
              );
            },
            child: Card(
              elevation: 2.0,
              child:
                  Image.asset('assets/Domestic-Violence.png', fit: BoxFit.fill),
            ),
          ),
          InkWell(
            onTap: () {
              var url = 'https://dpss.umich.edu/app/medical-emergencies.html';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SafetyViewScreen(
                    url: url,
                    key: UniqueKey(),
                  ),
                ),
              );
            },
            child: Card(
              elevation: 2.0,
              child:
                  Image.asset('assets/Medical-Emergency.png', fit: BoxFit.fill),
            ),
          ),
          InkWell(
            onTap: () {
              var url = 'https://dpss.umich.edu/app/sexual-assault.html';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SafetyViewScreen(
                    url: url,
                    key: UniqueKey(),
                  ),
                ),
              );
            },
            child: Card(
              elevation: 2.0,
              child: Image.asset('assets/Sexual-Assault-Awareness.png',
                  fit: BoxFit.fill),
            ),
          ),
          InkWell(
            onTap: () {
              var url = 'https://dpss.umich.edu/app/suicide-threats.html';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SafetyViewScreen(
                    url: url,
                    key: UniqueKey(),
                  ),
                ),
              );
            },
            child: Card(
              elevation: 2.0,
              child: Image.asset('assets/Suicide-Threats-or-Attempts-1.png',
                  fit: BoxFit.fill),
            ),
          ),
        ],
      )),
      bottomNavigationBar: NavigationBarNew(
        selectedIndex: currentIndex,
        destinations: const [], key: UniqueKey(), referringPage: 1,
      ),
    );
  }
}

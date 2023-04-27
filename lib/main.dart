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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dpss_public_app/news_screen.dart';
import 'package:dpss_public_app/story_screen.dart';
import 'package:dpss_public_app/contact_screen.dart';
import 'package:dpss_public_app/safety_tips.dart';
import 'package:dpss_public_app/transportation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LocationPage.dart';
import 'theme.dart' as theme;
import 'posting_current.dart';
import 'navigationbarnew.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

String targetOs = "";
String url = "";
String token = "";

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
  await setupFlutterNotifications();
  showFlutterNotification(message);
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: 'ic_stat_name',
        ),
      ),
    );
  }
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;


//app entry point
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );

  await FirebaseMessaging.instance.requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const DPSSApp());
}

class DPSSApp extends StatelessWidget {
  const DPSSApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UM Public Safety',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: theme.CompanyColors.blue,
      ),
      navigatorObservers: <NavigatorObserver>[observer],
      home: MainPage(
        title: 'UM Public Safety',
        analytics: analytics,
        observer: observer,
        key: UniqueKey(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  const MainPage({
    required Key key,
    required this.title,
    required this.analytics,
    required this.observer,
  }) : super(key: key);
  final String title;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  late final FirebaseMessaging _messaging;

  bool pushCrimeTopic = false;
  bool pushNewsTopic = false;
  bool pushTestTopic = false;

  int currentIndex = -1; // keep track of bottom navigation bar
  final _firstNameController =
      TextEditingController(); //used to retrieve settings
  final _lastNameController =
      TextEditingController(); //used to retrieve settings
  final _phoneController = TextEditingController(); //used to retrieve settings
  final _emailController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        backgroundColor: theme.CompanyColors.blue,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Image.asset('assets/logov2.png', fit: BoxFit.fill),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            //show single news item
            const CurrentPosting(),

            //call buttons
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Column(
                      children: <Widget>[
                        InkWell(
                            child: Image.asset(
                              'assets/phone-90.png',
                            ),
                            onTap: () {
                              _launchCaller("tel:7347631131");
                            }),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Call DPSS Dispatch'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Column(
                      children: <Widget>[
                        InkWell(
                            child: Image.asset(
                              'assets/clipboard-90.png',
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ContactScreen(
                                          //token: token,
                                          key: UniqueKey(), token: '',
                                        )),
                              );
                            }),

                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Report Online '),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // main menu options
            Flexible(
                child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20.0),
              children: <Widget>[
                Container(
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide())),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
                      child: InkWell(
                          child: ListTile(
                            title: const Text('NEWS and ALERTS'),
                            subtitle: const Text(
                                'The current list of DPSS News, Crime Alerts, '
                                'Emergency Alerts and other important '
                                'safety bulletins.'),
                            leading: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Image.asset('assets/information-64.png',
                                  fit: BoxFit.cover),
                            ),
                            trailing: const Icon(Icons.keyboard_arrow_right,
                                color: Colors.black12, size: 30.0),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewsScreen(
                                        key: UniqueKey(),
                                        heading: '',
                                      )),
                            );
                          }),
                    )),
                Container(
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide())),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
                      child: InkWell(
                          child: ListTile(
                            title: const Text('SAFETY TIPS'),
                            subtitle: const Text('Choose from various topics '
                                'for guidance to help you protect '
                                'yourself in the event of an emergency.   '),
                            leading: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Image.asset('assets/tick-64.png',
                                  fit: BoxFit.cover),
                            ),
                            trailing: const Icon(Icons.keyboard_arrow_right,
                                color: Colors.black12, size: 30.0),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SafetyTipsScreen()),
                            );
                          }),
                    )),
                Container(
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide())),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
                      child: InkWell(
                          child: ListTile(
                            title: const Text('TRANSPORTATION OPTIONS'),
                            subtitle: const Text('UM offers transit '
                                'services designed to meet special '
                                'needs and to fill in the gaps between '
                                'regular busing service hours. '),
                            leading: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Image.asset('assets/car-64.png',
                                  fit: BoxFit.cover),
                            ),
                            trailing: const Icon(Icons.keyboard_arrow_right,
                                color: Colors.black12, size: 30.0),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const TransportationScreen()),
                            );
                          }),
                    )),
                Container(
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide())),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
                      child: InkWell(
                          child: ListTile(
                            title: const Text('START a CONVERSATION'),
                            subtitle: const Text(
                                'We would like to hear your stories '
                                'about interactions with Police and Public Safety '
                                'officers and organizations. Let us start '
                                'a conversation.'),
                            leading: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Image.asset('assets/speech-balloon-50.png',
                                  fit: BoxFit.cover),
                            ),
                            trailing: const Icon(Icons.keyboard_arrow_right,
                                color: Colors.black12, size: 30.0),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => StoryScreen(
                                        token: token,
                                        key: UniqueKey(),
                                      )),
                            );
                          }),
                    )),
              ],
            ))
          ],
        ),
      ),
      bottomNavigationBar: NavigationBarNew(
        selectedIndex: currentIndex,
        destinations: const [],
        key: UniqueKey(),
        referringPage: 1,
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,

          children: <Widget>[
            Container(
              height: 130.0,
              color: theme.CompanyColors.blue.shade700,
              padding: EdgeInsets.only(top: mediaQuery.padding.top + 20.0),
              child: ListTile(
                leading: Image.asset('assets/dpss-logo-square-75.png',
                    fit: BoxFit.cover),
                title: const Text(' Contact Us',
                    style: TextStyle(
                        fontSize: 21.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70)),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 10.0, top: 15.0),
              child: Text('Add your Contact Information',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.CompanyColors.blue)),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 15.0, right: 14.0),
              child: Text(
                  'Enter your contact information to save time when using the '
                  'On-line Reporting feature.',
                  style: TextStyle(
                      fontSize: 12.0, color: theme.CompanyColors.blue)),
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: TextField(
                controller: _firstNameController,
                onChanged: (value) {
                  _setFirstName(value);
                },
                decoration: const InputDecoration(
                  hintText: "First Name",
                ),
              ),
            ),

            ListTile(
              leading: const Icon(null),
              title: TextField(
                controller: _lastNameController,
                onChanged: (value) {
                  _setLastName(value);
                },
                decoration: const InputDecoration(
                  hintText: "Last Name",
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.phone),
              title: TextField(
                keyboardType: TextInputType.phone,
                controller: _phoneController,
                onChanged: (value) {
                  _setPhone(value);
                },
                decoration: const InputDecoration(
                  hintText: "Phone",
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.email),
              title: TextField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                onChanged: (value) {
                  _setEmail(value);
                },
                decoration: const InputDecoration(
                  hintText: "Email",
                ),
              ),
            ),

            // Push Notification Options (see: https://codingwithjoe.com/flutter-how-to-build-a-modal-progress-indicator/)
            const Padding(
              padding: EdgeInsets.only(left: 10.0, top: 15.0),
              child: Text('Push Notification Options',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.CompanyColors.blue)),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 15.0, right: 10.0),
              child: Text(
                  'You may select to receive notifications from DPSS for the '
                  'following topics.  Your device is automatically enrolled in '
                  'UM Emergency Alerts.',
                  style: TextStyle(
                      fontSize: 12.0, color: theme.CompanyColors.blue)),
            ),

            SwitchListTile(
              value: pushCrimeTopic,
              onChanged: (bool value) {
                setState(() {
                  pushCrimeTopic = value;
                  _setPushCrimeTopic(value);
                });
              },
              title: const Text('Crime Alerts',
                  style: TextStyle(color: theme.CompanyColors.blue)),
            ),

            SwitchListTile(
              value: pushNewsTopic,
              onChanged: (bool value) {
                setState(() {
                  pushNewsTopic = value;
                  _setPushNewsTopic(value);
                });
              },
              title: const Text('DPSS News',
                  style: TextStyle(color: theme.CompanyColors.blue)),
            ),

            SwitchListTile(
              value: pushTestTopic,
              onChanged: (bool value) {
                setState(() {
                  pushTestTopic = value;
                  _setPushTestTopic(value);
                });
              },
              title: const Text('Test Messages',
                  style: TextStyle(color: theme.CompanyColors.blue)),
            ),

            const Divider(),

            const Padding(
              padding: EdgeInsets.only(left: 10.0, top: 15.0),
              child: Text('Send us your App Feedback',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.CompanyColors.blue)),
            ),

            InkWell(
              child: const ListTile(
                leading: Icon(
                  Icons.web,
                  color: Colors.blue,
                ),
                title: Text("Survey"),
                subtitle: Text('DPSS App Feedback Form'),
              ),
              onTap: () {
                _launchCaller(
                    "https://docs.google.com/forms/d/e/1FAIpQLSefhFH84ssZAxT27ywNbls5zpLSWVmC5RSfOHXCZWUq1_P6Vw/viewform?usp=sf_link");
              },
            ),

            const Padding(
              padding: EdgeInsets.only(left: 10.0, top: 15.0),
              child: Text('App Roadmap',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.CompanyColors.blue)),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 15.0, right: 10.0, bottom: 8.0),
              child: Text('Current Version 2.0.1',
                  style: TextStyle(
                      fontSize: 12.0, color: theme.CompanyColors.blue)),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 15.0, right: 10.0),
              child: Text('Upcoming features for Version 2.1.0',
                  style: TextStyle(
                      fontSize: 12.0, color: theme.CompanyColors.blue)),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 22.0, right: 10.0),
              child: Text('- Send pictures to DPSS',
                  style: TextStyle(
                      fontSize: 12.0, color: theme.CompanyColors.blue)),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 22.0, right: 10.0, bottom: 10.0),
              child: Text('- Campus Crime Map',
                  style: TextStyle(
                      fontSize: 12.0, color: theme.CompanyColors.blue)),
            ),
          ],
        ),
      ),
    );
  }

  _setPushCrimeTopic(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('crimeTopicSubscribed', value);

    if (value) {
      _messaging.subscribeToTopic('crime-alert');
      if (kDebugMode) {
        print('Subscribe crime topic...');
      }
    } else {
      _messaging.unsubscribeFromTopic('crime-alert');
      if (kDebugMode) {
        print('Unsubscribe crime topic...');
      }
    }
  }

  _setPushNewsTopic(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('newsTopicSubscribed', value);

    if (value) {
      _messaging.subscribeToTopic('general-news');
      if (kDebugMode) {
        print('Subscribe news topic...');
      }
    } else {
      _messaging.unsubscribeFromTopic('general-news');
      if (kDebugMode) {
        print('Unsubscribe news topic...');
      }
    }
  }

  _setPushTestTopic(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('testTopicSubscribed', value);

    if (value) {
      _messaging.subscribeToTopic('development-test');
      await widget.analytics.logEvent(
        name: 'push_test_topic',
        parameters: <String, dynamic>{
          'subscribed': 'yes',
        },
      );
      print('Subscribe test topic...');
    } else {
      _messaging.unsubscribeFromTopic('development-test');
      await widget.analytics.logEvent(
        name: 'push_test_topic',
        parameters: <String, dynamic>{
          'subscribed': 'no',
        },
      );

      print('Unsubscribe test topic...');
    }
  }

  //store on-line form values
  _setFirstName(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', value);
  }

  _setLastName(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastName', value);
  }

  _setPhone(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone', value);
  }

  _setEmail(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', value);
  }

  //Loading counter value on start
  _loadPushCrimeTopicSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pushCrimeTopic = (prefs.getBool('crimeTopicSubscribed') ?? false);
      if (kDebugMode) {
        print('setting push notification crime value to $pushCrimeTopic');
      }
    });
  }

  _loadPushNewsTopicSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pushNewsTopic = (prefs.getBool('newsTopicSubscribed') ?? false);
      if (kDebugMode) {
        print('setting push notification news value to $pushNewsTopic');
      }
    });
  }

  _loadPushTestTopicSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pushTestTopic = (prefs.getBool('testTopicSubscribed') ?? false);
      if (kDebugMode) {
        print('setting push notification test value to $pushTestTopic');
      }
    });
  }

  _loadFirstNameSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstNameController.text = (prefs.getString('firstName') ?? "");
    });
  }

  _loadLastNameSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastNameController.text = (prefs.getString('lastName') ?? "");
    });
  }

  _loadPhoneSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneController.text = (prefs.getString('phone') ?? "");
    });
  }

  _loadEmailSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = (prefs.getString('email') ?? "");
    });
  }



  Future<void> _showAlertDialog(title, body) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog( // <-- SEE HERE
          title:  Text("$title"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("$body"),
              ],
            ),
          ),
          actions: <Widget>[

            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();

    String? initialMessage;
    bool _resolved = false;

    _messaging = FirebaseMessaging.instance;
    //firebase messaging
    _messaging.getToken().then((value) {
      if (kDebugMode) {
        print(value);
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then(
          (value) => setState(
            () {
          _resolved = true;
          initialMessage = value?.data.toString();
          print(initialMessage);
        },
      ),
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message received:");
      print(event);

      print("message title:");
      print(event.notification!.title);

      _showAlertDialog(event.notification!.title, event.notification!.body);

      print("message body:");
      print(event.notification!.body);

    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });


    //load notification preferences
    _loadPushCrimeTopicSetting();
    _loadPushNewsTopicSetting();
    _loadPushTestTopicSetting();

    //load on-line report preferences
    _loadFirstNameSetting();
    _loadLastNameSetting();
    _loadEmailSetting();
    _loadPhoneSetting();
  }
}

// launch url
void _launchCaller(String url) async {
  if (kDebugMode) {
    print('external call...$url');
  }
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

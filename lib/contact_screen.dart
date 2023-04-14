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
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'message.dart';
import 'navigationbarnew.dart';

class ContactScreen extends StatefulWidget {
  final String token;
  const ContactScreen({required Key key, required this.token})
      : super(key: key);

  @override
  ContactScreenState createState() => ContactScreenState();
}

class ContactScreenState extends State<ContactScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final int currentIndex = -1; // keep track of bottom navigation bar

  String targetOs = "";

  late Map<String, double> startLocation;
  late Map<String, double> currentLocation;

  late StreamSubscription<Map<String, double>> locationSubscription;

  final Location _location = Location();
  bool permission = false;
  String error = "";

  bool currentWidget = true;

  //set up firebase realtime database store
  //https://console.firebase.google.com/u/1/project/dpss-public-api/database/dpss-public-api/data
  final database = FirebaseDatabase.instance.ref();

  Message message = Message();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final locationController = TextEditingController();
  final cityController = TextEditingController();
  final messageController = TextEditingController();
  
  bool formWasEdited = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    locationController.dispose();
    cityController.dispose();
    messageController.dispose();
    locationSubscription.cancel();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    //load on-line report preferences
    loadFirstNameSetting();
    loadLastNameSetting();
    loadEmailSetting();
    loadPhoneSetting();

    if (kDebugMode) {
      print(widget.token);
    }

    //set up location permissions
    initPlatformState();

    //start retrieving location
    locationSubscription =
        _location.onLocationChanged.listen((Map<String, double> result) {
      //setState(() {
      currentLocation = result;
      //});
    } as void Function(LocationData event)?) as StreamSubscription<Map<String, double>>;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    Map<String, double>? location;
    // Platform messages may fail, so we use a try/catch PlatformException.

    try {
      permission = (await _location.hasPermission()) as bool;
      location = (await _location.getLocation()) as Map<String, double>?;
      error = "";
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error =
            'Permission denied - please ask the user to enable it from the app settings';
      }

      location = null;
    }

    if (mounted) {
      startLocation = location!;
    }
  }

  getLocation() async {
    if (kDebugMode) {
      print('currentLocation: $currentLocation\n');
    }
    if (kDebugMode) {
      print('startLocation: $startLocation\n');
    }

    //TODO FIXME
    /*
    final coordinates =
        Coordinates(currentLocation["latitude"], currentLocation["longitude"]);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    var address =
        first.addressLine.substring(0, first.addressLine.indexOf(','));

    locationController.text = address;
    cityController.text =
        "${first.locality}, ${first.adminArea}  ${first.postalCode}";


     */
  }

  void _handleSubmitted() {
    final FormState? form = _formKey.currentState;
    if (!form!.validate()) {
      //TODO Check for replacement
      //autoValidate = true; // Start validating on every change.

      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      //determine platform for parsing push notifications
      if (Platform.isIOS) {
        if (kDebugMode) {
          print('is an iOS..registering ios topic');
        }
        targetOs = "IOS";
      } else if (Platform.isAndroid) {
        if (kDebugMode) {
          print('is a Android..registering android topic');
        }
        targetOs = "ANDROID";
      } else {
        targetOs = "ANDROID";
      }

      //populate report
      form.save();

      Message report = Message();

      var now = DateTime.now();
      report.messageDate = now.toString();
      report.messageType = "ONLINE";
      report.messageSubType = "REPORT";

      report.firstName = firstNameController.text;
      report.lastName = lastNameController.text;
      report.middleName = "";
      report.pushToken = widget.token;

      report.location = "";
      report.address = locationController.text;
      report.city = cityController.text;
      report.state = "MI";

      report.floor = "";
      report.room = "";

      report.phone = phoneController.text;
      report.email = emailController.text;
      report.comment = messageController.text;
      report.status = "N";

      //if (currentLocation != null) {
        report.yCoord = currentLocation["latitude"].toString() ?? " ";
        report.xCoord = currentLocation["longitude"].toString() ?? " ";
     // } else {
       // report.yCoord = " ";
       // report.xCoord = " ";
     // }

      report.device = targetOs;

      //debug
      if (kDebugMode) {
        print(report.toMap());
      }

      //send to firebase database
      var uuid = const Uuid().toString();
      database.child("inbound").child(uuid).set(report.toJson());
      showInSnackBar('Your report has been sent to DPSS Dispatch Services.');

      //navigate back to main screen
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          Navigator.pop(context);
        });
      });
    }
  }

  void showInSnackBar(String value) {
    //TODO  fixme
    //_scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  void loadFirstNameSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstNameController.text = (prefs.getString('firstName') ?? "");
    });
  }

  void loadLastNameSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lastNameController.text = (prefs.getString('lastName') ?? "");
    });
  }

  void loadPhoneSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      phoneController.text = (prefs.getString('phone') ?? "");
    });
  }

  void loadEmailSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = (prefs.getString('email') ?? "");
    });
  }

  Future<bool> _warnUserAboutInvalidData() async {
    final FormState? form = _formKey.currentState;
    if (form == null || !formWasEdited || form.validate()) {
      return true;
    }

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('This form has errors'),
              content: const Text('Really leave this form?'),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('YES'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                ElevatedButton(
                  child: const Text('NO'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Report Online'),
        //actions: <Widget>[MaterialDemoDocumentationButton(TextFormFieldDemo.routeName)],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          onWillPop: _warnUserAboutInvalidData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15.0, right: 10.0, top: 20.0),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18.0),
                        child: Column(
                          children: <Widget>[
                            const Text('For Emergencies and Urgent Issues:',
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.red)),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    color: Colors.red,
                                    child: const Padding(
                                      padding: EdgeInsets.only(
                                          top: 8.0,
                                          bottom: 8.0,
                                          left: 24.0,
                                          right: 24.0),
                                      child: Text('Dial 911',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  _launchCaller("tel:911");
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                            'If not urgent, you can send DPSS concerns, '
                            'tips or reports online. '
                            'If you provide your email and/or phone, we may follow-up '
                            'with additional questions or information.\n\n'
                            'Reports are sent directly to DPSS Dispatch Services.',
                            style: TextStyle(
                              fontSize: 14.0,
                            )),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextFormField(
                    controller: firstNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      icon: Icon(Icons.person),
                      labelText: 'First Name',
                    ),
                    //TODO  fixme
                    //onSaved: (String value) {
                    //  message.firstName = value;
                    //},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextFormField(
                    controller: lastNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      icon: Icon(null),
                      labelText: 'Last Name',
                    ),
                    //TODO  fixme
                    //onSaved: (String value) {
                    //  message.lastName = value;
                    //},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      icon: Icon(Icons.phone),
                      hintText: 'Where can we call you back?',
                      labelText: 'Phone Number',
                    ),
                    keyboardType: TextInputType.phone,

                    //TODO  fixme
                    //onSaved: (String value) {
                    //  message.phone = value;
                    //},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      icon: Icon(Icons.email),
                      labelText: 'E-mail',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    //TODO  fixme
                    //onSaved: (String value) {
                    //  message.email = value;
                    //},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Stack(
                      alignment: const Alignment(1.0, 1.0),
                      children: <Widget>[
                        TextFormField(
                          controller: locationController,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            icon: Icon(Icons.home),
                            labelText: 'Location (optional)',
                          ),
                          keyboardType: TextInputType.text,
                          //TODO  fixme
                          //onSaved: (String value) {
                          //  message.address = value;
                          //},
                        ),
                        ElevatedButton(
                            onPressed: () {
                              getLocation();
                            },
                            child: const Icon(Icons.gps_fixed))
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      icon: Icon(null),
                      labelText: 'City',
                    ),
                    keyboardType: TextInputType.text,
                    //TODO  fixme
                    //onSaved: (String value) {
                    //  message.city = value;
                    //},
                  ),
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Describe the event or issue:',
                    //helperText: 'Keep it short, this is just a demo.',
                    labelText: '',
                  ),
                  maxLines: 9,
                  //TODO  fixme
                  //onSaved: (String value) {
                  //  message.comment = value;
                  //},
                ),
                const SizedBox(height: 24.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _handleSubmitted,
                    child: const Text('SUBMIT'),
                  ),
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBarNew(
        selectedIndex: currentIndex,
        destinations: const [], key: UniqueKey(), referringPage: 1,
      ),
    );
  }

  // launch url
  void _launchCaller(String url) async {
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

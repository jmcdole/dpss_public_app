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

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'message.dart';
import 'navigationbarnew.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class ContactScreen extends StatefulWidget {
  final String token;
  const ContactScreen({required Key key, required this.token})
      : super(key: key);

  @override
  State<ContactScreen> createState() => ContactScreenState();
}

class ContactScreenState extends State<ContactScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final int currentIndex = -1; // keep track of bottom navigation bar

  String targetOs = "";

  //location services
  String? _currentAddress;
  String? _currentCity;

  Position? _currentPosition;

  //check for permissions
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  //get position
  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  //get address
  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
        _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
        '${place.street}';
        _locationController.text = _currentAddress!;
        _currentCity = '${place.subLocality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.postalCode}';
        _cityController.text = _currentCity!;

      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  String error = "";
  bool currentWidget = true;

  //set up firebase realtime database store
  //https://console.firebase.google.com/u/1/project/dpss-public-api/database/dpss-public-api/data
  final database = FirebaseDatabase.instance.ref();

  Message message = Message();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _cityController = TextEditingController();
  final _messageController = TextEditingController();

  bool formWasEdited = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _messageController.dispose();
    //locationSubscription.cancel();

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

  }

  void _handleSubmitted() {
    final FormState? form = _formKey.currentState;
    if (!form!.validate()) {
      //TODO Check for replacement
      //autoValidate = true; // Start validating on every change.

      //TODO  showInSnackBar('Please fix the errors in red before submitting.');
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

      report.firstName = _firstNameController.text;
      report.lastName = _lastNameController.text;
      report.middleName = "";
      report.pushToken = widget.token;

      report.location = "";
      report.address = _locationController.text;
      report.city = _cityController.text;
      report.state = "MI";

      report.floor = "";
      report.room = "";

      report.phone = _phoneController.text;
      report.email = _emailController.text;
      report.comment = _messageController.text;
      report.status = "N";

      //if (currentLocation != null) {


      //report.yCoord = currentLocation["latitude"].toString() ?? " ";
      //report.xCoord = currentLocation["longitude"].toString() ?? " ";

      //Text('LAT: ${_currentPosition?.latitude ?? ""}'),
      //Text('LNG: ${_currentPosition?.longitude ?? ""}'),
      //Text('ADDRESS: ${_currentAddress ?? ""}'),

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
      //TODO showInSnackBar('Your report has been sent to DPSS Dispatch Services.');

      //navigate back to main screen
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          Navigator.pop(context);
        });
      });
    }
  }

  void loadFirstNameSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstNameController.text = (prefs.getString('firstName') ?? "");
    });
  }

  void loadLastNameSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastNameController.text = (prefs.getString('lastName') ?? "");
    });
  }

  void loadPhoneSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _phoneController.text = (prefs.getString('phone') ?? "");
    });
  }

  void loadEmailSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = (prefs.getString('email') ?? "");
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
                    controller: _firstNameController,
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
                    controller: _lastNameController,
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
                    controller: _phoneController,
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
                    controller: _emailController,
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
                          controller: _locationController,
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
                            onPressed:_getCurrentPosition,
                            child: const Icon(Icons.gps_fixed))
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: TextFormField(
                    controller: _cityController,
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
                  controller: _messageController,
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
        destinations: const [],
        key: UniqueKey(),
        referringPage: 1,
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

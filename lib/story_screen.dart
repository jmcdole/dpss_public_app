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

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'story_service.dart';
import 'story.dart';

class StoryScreen extends StatefulWidget {
  final String token;

  const StoryScreen({required Key key, required this.token}) : super(key: key);
  static const String routeName = '/material/text-form-field';

  @override
  StoryScreenState createState() => StoryScreenState();
}

class StoryScreenState extends State<StoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Story content = Story();

  void showInSnackBar(String value) {
    //TODO fixme
    //_scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  bool formWasEdited = false;

  bool enabled = false;
  bool expanded = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    //load on-line report preferences
    loadNameSetting();
    loadEmailSetting();
  }

  void _handleSubmitted() {
    final FormState? form = formKey.currentState;
    if (!form!.validate()) {
      var autoValidate = true; // Start validating on every change.
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();

      //add push notification token
      content.token = widget.token;

      var payload = content.toMap();
      var payloadJson = jsonEncode(payload);

      send(payloadJson).then((result) {
        if (result == 'Your story has been shared.') {
          showInSnackBar(result);

          Future.delayed(const Duration(seconds: 3), () {
            setState(() {
              Navigator.pop(context);
            });
          });
        } else {
          showInSnackBar(result);
        }
      });
    }
  }

  void loadNameSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var firstName = prefs.getString('firstName') ?? "";
    var lastName = prefs.getString('lastName') ?? "";
    setState(() {
      nameController.text = ('$firstName $lastName');
    });
  }

  void loadEmailSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = (prefs.getString('email') ?? "");
    });
  }

  String? _validateStory(String value) {
    formWasEdited = true;
    if (value.isEmpty) {
      return 'Please tell us something.';
    }
    //final RegExp nameExp = RegExp(r'^[A-Za-z ]+$');
    //if (!nameExp.hasMatch(value))
    //  return 'Please enter only alphabetical characters.';
    return null;
  }

  Future<bool> _warnUserAboutInvalidData() async {
    final FormState? form = formKey.currentState;
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
        title: const Text('Start a Conversation'),
        //actions: <Widget>[MaterialDemoDocumentationButton(TextFormFieldDemo.routeName)],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.disabled,
          onWillPop: _warnUserAboutInvalidData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 10.0, top: 20.0),
                  child: Text(
                      'Please share with us your experiences '
                      'interacting with Police and Public Safety employees. Your '
                      'stories will remain anonymous, unless you indicate otherwise, '
                      'and will help us provide better training, procedures '
                      'and understanding for our officers and staff. ',
                      style: TextStyle(
                        fontSize: 12.0,
                      )),
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Tell us about your experience.',
                    helperText:
                        'You may provide as much or as little detail as '
                        'you would like.',
                    labelText: 'Start the Conversation *',
                  ),
                  maxLines: 15,

                  //todo fixme
                  //onSaved: (String value) {
                  //  content.message = value;
                  //},
                  //TODO fixme
                  //validator: _validateStory,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: ExpansionPanelList(
                    expansionCallback: (i, bool val) {
                      setState(() {
                        expanded = !val;
                      });
                    },
                    children: [
                      ExpansionPanel(
                        body: Container(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(children: <Widget>[
                            const Text(
                                'Your name and e-mail will only be used '
                                'if you would like us to reach out to you '
                                'for follow-up or more questions.',
                                style: TextStyle(
                                  fontSize: 12.0,
                                )),
                            const SizedBox(height: 24.0),
                            TextFormField(
                              textCapitalization: TextCapitalization.words,
                              controller: nameController,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                filled: true,
                                icon: Icon(Icons.person),
                                hintText: 'Your name',
                                labelText: 'Name',
                              ),
                              //TODO fixme
                              //onSaved: (String value) {
                              //  content.name = value;
                              //},
                            ),
                            const SizedBox(height: 24.0),
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                filled: true,
                                icon: Icon(Icons.email),
                                hintText: 'Your email address',
                                labelText: 'E-mail',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              //TODO fixme
                              //onSaved: (String value) {
                              //  content.email = value;
                              //},
                            ),
                          ]),
                        ),
                        headerBuilder: (BuildContext context, bool val) {
                          return Container(
                              padding:
                                  const EdgeInsets.only(left: 8.0, top: 14.0),
                              child: const Text('Optional Information',
                                  style: TextStyle(fontSize: 14.0),
                                  textAlign: TextAlign.left));
                        },
                        isExpanded: expanded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _handleSubmitted,
                    child: const Text('SEND'),
                  ),
                ),
                const SizedBox(height: 24.0),
                Text('* indicates required field',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

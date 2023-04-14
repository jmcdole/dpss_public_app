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

class Message {
  String messageDate = ' ';
  String messageType = ' ';
  String messageSubType = ' ';
  String firstName = ' ';
  String lastName = ' ';
  String middleName = ' ';
  String pushToken = ' ';
  String location = ' ';
  String address = ' ';
  String city = ' ';
  String state = ' ';
  String floor = ' ';
  String room = ' ';
  String areaCode = ' ';
  String phone = ' ';
  String email = ' ';
  String comment = ' ';
  String status = ' ';
  String xCoord = ' ';
  String yCoord = ' ';
  String device = ' ';

  toJson() {
    return {
      "message_date": messageDate,
      "message_type": messageType,
      "message_subtype": messageSubType,
      "first_name": firstName,
      "last_name": lastName,
      "middle_name": middleName,
      "push_token": pushToken,
      "location": location,
      "address": address,
      "city": city,
      "state": state,
      "floor": floor,
      "room": room,
      "area_code": areaCode,
      "phone": phone,
      "email": email,
      "comment": comment,
      "status": status,
      "x_coord": xCoord,
      "y_coord": yCoord,
      "device": device
    };
  }

  Map<String, dynamic> toMap() {
    return {
      "message_date": messageDate,
      "message_type": messageType,
      "message_subtype": messageSubType,
      "first_name": firstName,
      "last_name": lastName,
      "middle_name": middleName,
      "push_token": pushToken,
      "location": location,
      "address": address,
      "city": city,
      "state": state,
      "floor": floor,
      "room": room,
      "area_code": areaCode,
      "phone": phone,
      "email": email,
      "comment": comment,
      "status": status,
      "x_coord": xCoord,
      "y_coord": yCoord,
      "device": device
    };
  }
}

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

class Location {
  int id;
  String name;
  String lat;
  String long;
  String address1;
  String address2;
  String city;
  String state;
  String zip;
  String phone;
  String imageUrl;
  Location(
      {required this.id,
      required this.name,
      required this.lat,
      required this.long,
      required this.address1,
      required this.address2,
      required this.city,
      required this.state,
      required this.zip,
      required this.phone,
      required this.imageUrl});
}

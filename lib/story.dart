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

class Story {
  String message = '';
  String name = '';
  String email = '';
  String token = '';

  Map<String, dynamic> toMap() {
    return {"message": message, "name": name, "email": email, "token": token};
  }
}

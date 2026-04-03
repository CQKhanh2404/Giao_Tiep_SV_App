import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Groupmember {
  final String group_id;
  final DateTime joined_at;
  final int role;
  final int status_id;
  final String user_id;

  Groupmember({required this.group_id, required this.joined_at, required this.role, required this.status_id, required this.user_id});

    Map<String, dynamic> toMap() {
    return {
      'group_id': group_id, 
      "joined_at": joined_at ?? FieldValue.serverTimestamp(),
      "role": role,
      'status_id': status_id,
      "user_id": user_id,
    };


    //doc du lieu 
  }

}
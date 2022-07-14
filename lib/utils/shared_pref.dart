// import 'package:flutter/material.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Map<String, dynamic> DRAWER_DATA = {};

class SharedPref {
  Future<void> logout() async {
    final pref = await SharedPreferences.getInstance();
    // pref.remove('user_credential');
    // pref.clear(); // clear everything in in shared pref
    pref.remove('token');
    pref.remove('dashboard_brief');
    DRAWER_DATA = {};
  }

  Future<Map<String, dynamic>> dashboardBrief() async {
    try {
      final pref = await SharedPreferences.getInstance();
      if (!pref.containsKey('dashboard_brief')) {
        return {};
      }
      final extractedDashBrief =
          json.decode(pref.getString('dashboard_brief')!) as Map<String, dynamic>;
      print(extractedDashBrief['full_name']);
      return extractedDashBrief;
    } catch (error) {
      return {};
    }
  }

  Future<void> dashboardBriefSetter(Map<String, dynamic> theMap) async {
    print('value of the profieslt statu in setttererererere');
    print(theMap['is_profile_completed']);
    try {
      final pref = await SharedPreferences.getInstance();
      if (pref.containsKey('dashboard_brief')) {
        pref.remove('dashboard_brief');
        // pref.clear();
      }
      final organizedMap = json.encode({
        "id": theMap['id'].toString(),
        "full_name": theMap['full_name'],
        "rtl_full_name": theMap['rtl_full_name'],
        "is_profile_completed": theMap['is_profile_completed'],
        "is_profile_on_progress": theMap['is_profile_on_progress'],
        "is_unseen_note": theMap['is_unseen_note'],
        "avatar": theMap['avatar'],
        "phone": theMap['phone'],
        "title": theMap['title'],
        "farsi_title": theMap['farsi_title'],
        "pashto_title": theMap['pashto_title'],
        "average_star": theMap['average_star'],
        "patient_no": theMap['patient_no'].toString(),
        "booked_appt_no": theMap['booked_appt_no'].toString(),
        "feedback_no": theMap['feedback_no'].toString(),
      });
      pref.setString('dashboard_brief', organizedMap);
      initialize();
    } catch (error) {
      print('erorr on catch dashboard_brief');
      print(error);
    }
  }

  void initialize() async {
    print('initialize is running ----======');
    await dashboardBrief().then((value) {
      DRAWER_DATA['id'] = value['id'];
      DRAWER_DATA['avatar'] = value['avatar'];
      DRAWER_DATA['full_name'] = value['full_name'];
      DRAWER_DATA['is_unseen_note'] = value['is_unseen_note'];
      DRAWER_DATA['is_profile_completed'] = value['is_profile_completed'];
      DRAWER_DATA['is_profile_on_progress'] = value['is_profile_on_progress'];
      DRAWER_DATA['average_star'] = value['average_star'];
      DRAWER_DATA['patient_no'] = value['patient_no'];
      DRAWER_DATA['feedback_no'] = value['feedback_no'];
      DRAWER_DATA['booked_appt_no'] = value['booked_appt_no'];
    });
  }

  Future<String?> getToken() async {
    print('iside the getToken');
    // return '';
    try {
      final pref = await SharedPreferences.getInstance();
      if (!pref.containsKey('token')) {
        return '';
      }
      final extractedToken = pref.getString('token');
      return extractedToken;
    } catch (error) {
      //
      print('on catch error ========');
      print(error);
      return '';
    }
  }

  Future<void> setToken(String token) async {
    print('insdie the setAutoLogin=======');
    try {
      final pref = await SharedPreferences.getInstance();
      if (pref.containsKey('token')) {
        pref.remove('token');
      }
      pref.setString('token', token);
      print('holly shit we set the sting ');
    } catch (error) {
      //
      print('on catch error ========');
      print(error);
    }
  }
}

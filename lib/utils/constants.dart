import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: constant_identifier_names/
//const String BASE_URL = "http://206.81.5.26:3500/api"; // live ip
const String BASE_URL = "http://192.168.1.6:3500/api"; // local ip

// http://206.81.5.26/inventory
// ignore: constant_identifier_names

const String CANNOT_BE_EMPTY = "Field cannot be empty.";

const String NO_REC_FOUND = "No Record Found";

// ignore: constant_identifier_names
const String BL_USER_LOGGED_IN = "UserLoggedIn";
const String BL_USER_TOKEN = "UserToken";
const String BL_USER_ID = "UserId";
const String BL_USER_FULL_NAME = "UserFullName";

const String BL_USER_FNAME = "UserFirstName";
const String BL_USER_LNAME = "UserLastName";
const String BL_USER_EMAIL = "UserEmail";
const String BL_FCM_TOKEN = "FCMToken";
const String BL_USER_ROLES = "UserRoles";
const String BL_USER_PERMISSIONS = "UserPermissions";
const String BL_REJECTED_REASON = "RejectedReason";

const String US_DATE_FORMAT = 'MMMM dd yyyy';
const String NOTIFICATION_DATE_FORMAT = 'MMMM dd, yyyy - hh:mm aa';

const List<String> LS_PERMISSIONS = [
  'view_job',
  'view_task',
  'view_profile',
  'view_past_cars',
  'view_notifications',
  'add_car',
  'edit_profile',
  'view_inventory_list',
  'view_inventory_detail',
  'collaborate_on_microsoft_whiteboard',
  /////////////////  new permissions added
  'view_task_detail',
  // 'create_sequence'    // changed to add-sequeunce
  'add_sequence',
  'view_dashboard_with_graphs',
  'view_inventory',
  'add_inventory',
  'view_rejected_tasks',
  'view_car',
  'approved_car',
  'share_car',
  'export_tasks_in_pdf',
  'approved_task',
  'add_job',
  'export_job',
  'edit_job',
  'delete_job',
  'add_task',
  'edit_task', 'delete_task', 'export_task', 'delete_inventory',
  'export_inventory',
  'add_user',
  'view_user', 'edit_user', 'delete_user', 'export_user',
  'add_role', 'view_role', 'edit_role', 'delete_role', 'export_role',
  'add_permision', 'view_permision',

  /////////////////////////////////
  'edit_permision',
  'delete_permision',
  'export_permision',
  'rejected_car',
  'rejected_task',
  'review_tasks',
  'view_contact',
  'add_contact',
  'delete_contact',
  'edit_contact',
  'add_purchase',
  'edit_purchase',
  'delete_purchase',
  'view_purchasedetails',
  'add_purchaseitem',
  'add_vendor',
  'edit_vendor',
  'delete_vendor',
  'detail_job',
  'add_fabricateditems',
  'add_company',
  'delete_company',
  'edit_company',
  'add_sequence',
  'delete_sequence',
  'view_sequence',
  'edit_sequence',
  'update_fabricateditems',
  'make_call',
  'download_diagram',
  'View Task Detail',
];

InputDecoration textFieldDecoration(String title, bool ifPassword) {
  var outlineInputBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.circular(10.0),
  );
  return InputDecoration(
      filled: true,
      fillColor: const Color(0xffF8F9FD),
      hintText: title,
      suffixIcon: !ifPassword
          ? null
          : const Icon(
              Icons.remove_red_eye,
              color: Colors.grey,
            ),
      enabledBorder: outlineInputBorder,
      focusedBorder: outlineInputBorder,
      border: outlineInputBorder);
}

void showSnackbar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

double calculatePercentage(int numerator, int denominator) {
  if (denominator == 0) {
    return 0.0; // Handle division by zero
  }

  double mTaskPercent = (numerator / denominator) * 100.0;
  return mTaskPercent;
}

Future<void> saveBoolToSP(bool value, String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}

Future<bool> getBoolFromSF(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool(key) ?? false;
  return isLoggedIn;
}

Future<void> saveStringListToSP(List<String> value, String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(key, value);
}

Future<List<String>> getStringListFromSF(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> value = prefs.getStringList(key) ?? [];
  return value;
}

Future<void> saveStringToSP(String value, String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<String> getStringFromSF(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String value = prefs.getString(key) ?? "";
  return value;
}

Future<void> saveIntToSP(int? value, String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt(key, value!);
}

Future<int?> getIntFromSF(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int value = prefs.getInt(key) ?? 0;
  return value;
}

Color setCardBorderColor(String value) {
  if (value == "in_process" || value == "pending" || value == "to_inspect") {
    return const Color(0xfff3bd59);
  } else if (value == "rejected") {
    return const Color(0xFFe86c63);
  } else {
    return const Color(0xFF67c35c);
  }
}

String setStatusText(String value) {
  if (value == "in_process") {
    return 'In Process';
  } else if (value == "pending") {
    return 'Pending';
  } else if (value == "rejected") {
    return 'Rejected';
  } else if (value == "approved") {
    return 'Approved';
  } else {
    return 'To Inspect';
  }
}

Color setCardColor(String value) {
  if (value == "in_process" || value == "pending" || value == "to_inspect") {
    return const Color(0xfffcebcc);
  } else if (value == "rejected") {
    return const Color(0xFFf8d3d0);
  } else {
    return const Color(0xFFd1edcd);
  }
}

Future<List<String>> getPermissionsFromSF(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? permissionsJson = prefs.getString(key);

  if (permissionsJson != null && permissionsJson.isNotEmpty) {
    List<String> permissions = List<String>.from(json.decode(permissionsJson));
    return permissions;
  } else {
    return [];
  }
}

Future<bool> hasPermission(String permission) async {
  List<String> permissions = await getPermissionsFromSF(BL_USER_PERMISSIONS);
  return permissions.contains(permission);
}

Future<bool> checkPermissionFromSP() async {
  bool hasViewProfilePermission = await hasPermission("view_profile");
  if (hasViewProfilePermission) {
    return true;
  } else {
    return false;
  }
}

Future<String> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString(BL_USER_TOKEN) ?? "";
  return token;
}

void showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER, // Position where the toast will appear
    backgroundColor: Colors.white, // Background color of the toast
    textColor: Colors.blue, // Text color of the toast
    fontSize: 16.0, // Font size of the toast text
  );
}

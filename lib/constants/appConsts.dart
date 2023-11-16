import 'package:collabDocs/constants/appColors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppConstants {
  static dynamic DateFormatter(String date) {
    return DateFormat("dd MMM yyyy '${"at"}' hh:mm a")
        .format(DateTime.tryParse(date)!.toLocal());
  }

  static bool kIsEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(p);
    return regExp.hasMatch(em);
  }

  static SnackBar kSnackbarMsg({required String msg}) {
    return SnackBar(
      content: Text(msg),
      backgroundColor: kPrimaryColor(),
      behavior: SnackBarBehavior.floating,
      shape: StadiumBorder(),
    );
  }
}

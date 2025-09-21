import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ex: today:- 09:10 AM
// ex: yesterday:- yesterday
// ex: yesterday before:- 22 april
// ex: year before:- 22 april 2023
class CommonWidget {
  static Widget errorText = const Text('Something went wrong');

  static String? convertDateForm(String utcTimeString) {
    DateTime tm = DateTime.parse(utcTimeString).toLocal();
    DateTime today = DateTime.now();
    Duration oneDay = const Duration(days: 1);
    Duration twoDay = const Duration(days: 2);
    Duration oneWeek = const Duration(days: 7);
    String? month;
    switch (tm.month) {
      case 1:
        month = "January";
        break;
      case 2:
        month = "February";
        break;
      case 3:
        month = "March";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "June";
        break;
      case 7:
        month = "July";
        break;
      case 8:
        month = "August";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "October";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "December";
        break;
    }

    Duration difference = today.difference(tm);
    if (difference.compareTo(const Duration(minutes: 1)) < 1) {
      return 'Now';
    } else if (difference.compareTo(const Duration(hours: 1)) < 1) {
      return DateFormat.jm().format(tm);
    } else if (difference.compareTo(oneDay) < 1) {
      return DateFormat.jm().format(tm);
    } else if (difference.compareTo(twoDay) < 1) {
      return "Yesterday";
    } else if (difference.compareTo(oneWeek) < 1) {
      switch (tm.weekday) {
        case 1:
          return "Monday";
        case 2:
          return "Tuesday";
        case 3:
          return "Wednesday";
        case 4:
          return "Thursday";
        case 5:
          return "Friday";
        case 6:
          return "Saturday";
        case 7:
          return "Sunday";
      }
    } else if (tm.year == today.year) {
      return '${tm.day} $month';
    } else {
      return '${tm.day} $month ${tm.year}';
    }
    return null;
  }
}

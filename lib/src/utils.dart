import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Returns the default week days as strings (using intl).
List<String> defaultWeekDays() =>
    DateFormat.E().dateSymbols.WEEKDAYS.map((e) => e.substring(0, 3)).toList();

class DateFormatter extends TextInputFormatter {
  late int maxYear;

  DateFormatter({int? maxYear}) {
    this.maxYear = maxYear ?? DateTime.now().year;
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue prevText, TextEditingValue currText) {
    int selectionIndex;

    // Get the previous and current input strings
    String pText = prevText.text;
    String cText = currText.text;

    // Abbreviate lengths
    int cLen = cText.length;
    int pLen = pText.length;

    if (cLen == 1) {
      if (cText == "/" || int.parse(cText) != 2) {
        cText = '';
      }
    } else if (cLen == 2) {
      if (cText.substring(0, 2) != "20") {
        cText = cText.substring(0, 1);
      }
    } else if (cLen == 3) {
      if (cText.substring(2, 3) == "/" ||
          int.parse(cText.substring(0, 3)) >
              int.parse(maxYear.toString().substring(0, 3))) {
        cText = cText.substring(0, 2);
      }
    } else if (cLen == 4 && pLen == 3) {
      if (cText.substring(3, 4) == "/" ||
          int.parse(cText.substring(0, 4)) > maxYear) {
        cText = cText.substring(0, 3);
      } else {
        cText += "/";
      }
    } else if ((cLen == 4 && pLen == 5) || (cLen == 7 && pLen == 8)) {
      // Remove / char
      cText = cText.substring(0, cText.length - 1);
    } else if (cLen == 6) {
      /// after entering a valid date and programmatic insertion of '/', now User has entered
      /// the first digit of the Month. But, it
      // Can only be 0 or 1
      /// (and, not  '/' either)
      if (cText.substring(5, 6) == "/") {
        // Remove char
        cText = cText.substring(0, 5);
      } else if (int.parse(cText.substring(5, 6)) > 1) {
        cText = "${cText.substring(0, 5)}0${cText.substring(5, 6)}/";
      }
    } else if (cLen == 7 && pLen == 6) {
      if (cText.substring(6, 7) == "/") {
        if (cText.substring(5, 6) == "0") {
          cText = "${cText.substring(0, 5)}01/";
        } else {
          cText = "${cText.substring(0, 5)}0${cText.substring(5, 6)}/";
        }
        //cText = cText.substring(0, 6);
      } else {
        int mm = int.parse(cText.substring(5, 7));

        /// User has entered the second digit of the Month, but the
        // Month cannot be greater than 12
        /// Also, that entry cannot be '/'
        if (mm == 0 || mm > 12 || cText.substring(6, 7) == "/") {
          // Remove char
          cText = cText.substring(0, 6);
        } else {
          cText += "/";
        }
      }
      // Entering Day
    } else if (cLen == 9) {
      if (cText.substring(8, 9) == "/") {
        cText = cText.substring(0, 8);
      } else {
        int mm = int.parse(cText.substring(5, 7));
        int d1 = int.parse(cText.substring(8, 9));
        if ((mm == 2 && d1 > 2) || d1 > 3) {
          cText = "${cText.substring(0, 8)}0${cText.substring(8, 9)}";
        }
      }
    } else if (cLen == 10) {
      if (cText.substring(9, 10) == "/") {
        cText = cText.substring(0, 9);
      } else {
        int yyyy = int.parse(cText.substring(0, 4));
        int mm = int.parse(cText.substring(5, 7));
        int dd = int.parse(cText.substring(8, 10));
        bool isNotLeapYear =
            !((yyyy % 4 == 0) && (yyyy % 100 != 0) || (yyyy % 400 == 0));
        if ((dd == 31 &&
                (mm == 02 || mm == 04 || mm == 06 || mm == 09 || mm == 11)) ||

            /// If the date is greater than 29, the month cannot be Feb
            /// (Leap years will be dealt with, when user enters the Year)
            (dd > 28 && (mm == 02) && isNotLeapYear) ||
            dd == 0) {
          // Remove char
          cText = cText.substring(0, 9);
        }
      }
    }

    selectionIndex = cText.length;
    return TextEditingValue(
      text: cText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class TimeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue prevText, TextEditingValue currText) {
    int selectionIndex;

    // Get the previous and current input strings
    String pText = prevText.text;
    String cText = currText.text;

    // Abbreviate lengths
    int cLen = cText.length;
    int pLen = pText.length;

    // HOURS
    if (cLen == 1) {
      if (cText == ":") {
        cText = '';
      } else {
        int h = int.parse(cText);
        if (h > 2) {
          cText = "0$h:";
        }
      }
    } else if (cLen == 2 && pLen == 1) {
      if (cText.substring(1, 2) == ":") {
        cText = "0${cText.substring(0, 1)}:";
      } else {
        int h = int.parse(cText.substring(0, 1));
        int hh = int.parse(cText.substring(1, 2));
        if (h > 1 && hh > 3) {
          cText = "${cText.substring(0, 1)}3:";
        } else {
          cText += ":";
        }
      }
      // MINUTES
    } else if (cLen == 4) {
      if (cText.substring(3, 4) == ":") {
        cText = cText.substring(0, 3);
      } else {
        int m = int.parse(cText.substring(3, 4));
        if (m > 6) {
          cText = "${cText.substring(0, 3)}0$m:";
        }
      }
    } else if (cLen == 5 && pLen == 4) {
      if (cText.substring(4, 5) == ":") {
        cText = "${cText.substring(0, 3)}0${cText.substring(3, 4)}:";
      } else {
        cText += ":";
      }
    } else if ((cLen == 2 && pLen == 3) || (cLen == 5 && pLen == 6)) {
      // Remove / char
      cText = cText.substring(0, cText.length - 1);
      // SECONDS
    } else if (cLen == 6 && pLen == 5) {
      if (cText.substring(5, 6) == ":") {
        cText = cText.substring(0, 5);
      } else {
        int s = int.parse(cText.substring(5, 6));
        if (s > 6) {
          cText = "${cText.substring(0, 3)}0$s:";
        }
      }
    } else if (cLen == 7 && pLen == 6) {
      if (cText.substring(6, 7) == ":") {
        cText = cText.substring(0, 6);
      } else {
        int s = int.parse(cText.substring(6, 7));
        if (s > 6) {
          cText = "${cText.substring(0, 6)}0$s:";
        }
      }
    } else if (cLen == 8) {
      if (cText.substring(7, 8) == ":") {
        cText = cText.substring(0, 7);
      }
    }
    selectionIndex = cText.length;
    return TextEditingValue(
      text: cText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

Duration parseDuration(String s) {
  List<String> parts = s.split(':');
  return Duration(
    hours: int.parse(parts[0]),
    minutes: int.parse(parts[1]),
    seconds: int.parse(parts[2]),
  );
}

String durationToString(Duration duration) {
  return "${duration.inHours.toString().padLeft(2, '0')}"
      ":${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}"
      ":${(duration.inSeconds.remainder(60).toString().padLeft(2, '0'))}";
}

DateTime dateOnly(DateTime dateTime, [bool utc = true]) {
  if (utc) {
    return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
  } else {
    return DateUtils.dateOnly(dateTime);
  }
}

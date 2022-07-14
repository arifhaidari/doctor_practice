import 'dart:math';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../pages/screens.dart';
import '../providers/provider_list.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'package:flutter/material.dart';

final randomNum = Random().nextInt(1000000);

int calculateAge(DateTime birthDate) {
  DateTime currentDate = DateTime.now();
  int age = currentDate.year - birthDate.year;
  int currentMonth = currentDate.month;
  int birthMonth = birthDate.month;
  if (birthMonth > currentMonth) {
    age--;
  } else if (currentMonth == birthMonth) {
    int currentDay = currentDate.day;
    int birthDay = birthDate.day;
    if (birthDay > currentDay) {
      age--;
    }
  }
  return age;
}

String timeAgoConverter(DateTime input) {
  try {
    Duration diff = DateTime.now().difference(input);
    if (diff.inDays >= 1) {
      return '${diff.inDays} day(s) ago';
    } else if ((diff.inDays / 7).floor() >= 1) {
      return 'Last week';
    } else if (diff.inDays >= 1) {
      return 'Yesterday';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} hour(s) ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} minute(s) ago';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} second(s) ago';
    } else {
      return 'just now';
    }
  } catch (e) {
    return 'Just Now';
  }
}

String timeExtractor(String timestamp) {
  try {
    return DateFormat.jm().format(DateTime.parse(timestamp)).toString();
  } catch (e) {
    return 'just now';
  }
}

bool isPdf(String text) {
  final result = text.substring(text.length - 4, text.length);
  if (result == '.pdf') {
    return true;
  }
  return false;
}

void showPdf(String url, BuildContext context) async {
  final pdfFile = await PDFMixin.loadNetwork(url);

  if (url != '') {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PDFViewerPage(file: pdfFile);
    }));
  }
}

Future<void> createOTP(BuildContext context, String phoneOTP, String operation) async {
  FormData body = FormData.fromMap({
    'phone_otp': phoneOTP,
    'the_round': 'create_round',
    'operation': operation,
  });
  var otpResponse =
      await HttpService().postRequest(data: body, endPoint: OPT_VERIFICATION, isAuth: false);

  try {
    if (!otpResponse.error) {
      if (otpResponse.data['message'] == 'success') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => VerifyOtp(
                      phone: phoneOTP,
                      operation: operation,
                    )));
      } else {
        if (otpResponse.data['message'] == 'field_error') {
          infoNoOkDialogue(context, 'Enter your data properly and try again', 'Data Entry Error');
        } else if (otpResponse.data['message'] == 'no_account') {
          infoNoOkDialogue(
              context,
              'There is no account registered by this phone number. Please Enter your registered number',
              'Account Unavailable');
        } else {
          infoNoOkDialogue(
              context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
        }
      }
    } else {
      infoNoOkDialogue(
          context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
    }
  } catch (e) {
    infoNoOkDialogue(
        context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS, GlobalVariable.ERROR_MESSAGE_TITLE);
  }
  //
}

import 'package:auto_size_text/auto_size_text.dart';
import '../models/model_list.dart';
import '../pages/screens.dart';
import '../providers/provider_list.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:intl/intl.dart';
import 'utils.dart';

Widget circularLoading() {
  return Container(
      height: 40,
      width: 40,
      child: Center(
          child: CircularProgressIndicator(
        backgroundColor: Colors.white,
      )));
}

Column tileText(String title, String operation) {
  return Column(
    children: [
      AutoSizeText(
        title,
        maxLines: 1,
        minFontSize: operation == 'other' ? 13 : 15,
        overflow: TextOverflow.ellipsis,
        style: operation == 'other'
            ? TextStyle(fontSize: 15, fontWeight: FontWeight.w500)
            : TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue[900]),
      ),
      SizedBox(
        height: 2.0,
      ),
    ],
  );
}

InputDecoration searchFieldDecoation(
    BuildContext context, String theHintText, TextEditingController theController) {
  return InputDecoration(
    fillColor: Colors.white,
    contentPadding: EdgeInsets.all(10),
    filled: true,
    suffixIcon: IconButton(
      icon: Icon(Icons.cancel),
      onPressed: () {
        theController.clear();
        FocusScope.of(context).unfocus();
      },
    ),
    hintText: theHintText,
    hintStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.grey[500]),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: BorderSide.none,
    ),
  );
}

InputDecoration textFieldDesign(BuildContext context, String label,
    {bool isIcon = false, TextEditingController? theTextController}) {
  return InputDecoration(
    labelText: label,
    suffixIcon: isIcon
        ? IconButton(
            icon: Icon(
              Icons.cancel,
              color: Palette.imageBackground,
            ),
            onPressed: () {
              theTextController!.clear();
              // FocusScope.of(context).hasFocus;
              // FocusScope.of(context).dispose();
              FocusScope.of(context).unfocus();
            },
          )
        : null,
    labelStyle: TextStyle(fontSize: 16, color: Palette.imageBackground),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide(color: Palette.imageBackground, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide(
        color: Palette.blueAppBar,
        width: 1.5,
      ),
    ),
  );
}

void traditionalSnackBar(String text, context, {int duration = 2}) {
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(SnackBar(
      duration: Duration(seconds: duration),
      content: Text(text),
    ));
}

ElevatedButton customElevatedButton(BuildContext context, Function? function, String title) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
        elevation: 7.0,
        minimumSize: Size(280, 43),
        onPrimary: Colors.white,
        primary: Palette.blueAppBar,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
    onPressed: () {
      FocusScope.of(context).unfocus();
      function!();
    },
    child: Text(
      title,
      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
    ),
  );
}

void toastSnackBar(String text,
    {bool note = true, bool positionCenter = true, bool lenghtShort = true}) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
      msg: text,
      toastLength: lenghtShort ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG,
      gravity: positionCenter ? ToastGravity.CENTER : ToastGravity.BOTTOM,
      timeInSecForIosWeb: lenghtShort ? 2 : 4,
      backgroundColor: note ? Palette.imageBackground : Colors.red.withOpacity(0.8),
      textColor: Colors.white,
      fontSize: 16.0);
}

Widget cardDetailItem(String text, IconData icon, {int maxLine = 1}) {
  return Padding(
    padding: const EdgeInsets.all(3.0),
    child: Row(children: [
      Icon(
        icon,
        size: 22.0,
        color: Colors.blue[900],
      ),
      SizedBox(
        width: 3.0,
      ),
      Expanded(
        child: AutoSizeText(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16.0,
          ),
          minFontSize: 13,
          maxLines: maxLine,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]),
  );
}

DottedLine dashedLine(Color color, {bool isHorizontal = true}) {
  return DottedLine(
    direction: isHorizontal ? Axis.horizontal : Axis.horizontal,
    lineLength: double.infinity,
    lineThickness: 1.0,
    dashLength: 4.0,
    dashColor: color,
    dashRadius: 0.0,
    dashGapLength: 5.0,
    dashGapColor: Colors.transparent,
    dashGapRadius: 0.0,
  );
}

Future<void> getPatientUserDetail(int patientId, BuildContext context) async {
  var patientModelResponse =
      await HttpService().getRequest(endPoint: PATIENT_USER_DEATAIL + "$patientId/");

  if (!patientModelResponse.error) {
    try {
      PatientModel patientModelObj = PatientModel.fromJson(patientModelResponse.data);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => PatientProfile(patientModel: patientModelObj)));
    } catch (e) {
      print('value fo e in the erororo section');
      print(e);
      infoNoOkDialogue(
          context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS, GlobalVariable.ERROR_MESSAGE_TITLE);
    }
  } else {
    infoNoOkDialogue(context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
  }
}

AppBar myAppBar(String title,
    {IconData icon = Icons.notifications, VoidCallback? function, bool isAction = false}) {
  return AppBar(
    title: Text(
      title,
      style: TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
    ),
    backgroundColor: Palette.blueAppBar,
    actions: [
      if (isAction)
        IconButton(
          icon: Icon(
            icon,
          ),
          onPressed: function,
        ),
    ],
  );
}

Tab patientProfileTab(String text, BuildContext context) {
  // FocusScope.of(context).unfocus();
  return Tab(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        border: Border.all(width: 2, color: Palette.heavyYellow),
      ),
      child: Align(
        alignment: Alignment.center,
        child: AutoSizeText(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          minFontSize: 13,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );
}

import 'package:doctor_panel/pages/nav_screen.dart';
import 'package:flutter/material.dart';

class ErrorPlaceHolder extends StatelessWidget {
  final String errorDetail;
  final String errorTitle;
  final bool isStartPage;
  const ErrorPlaceHolder(
      {Key? key, required this.errorDetail, required this.errorTitle, this.isStartPage = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 120,
          ),
        ),
        Center(
            child: Container(
          width: mQuery.width * 0.75,
          child: Column(
            children: [
              Text(
                errorTitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Text(
                errorDetail,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        )),
        Center(
          child: IconButton(
              icon: Icon(
                Icons.refresh,
                size: 35,
                color: Colors.blue[900],
              ),
              onPressed: () {
                if (isStartPage) {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => NavScreen()));
                }
              }
              // onPressed: () => Navigator.pushReplacementNamed(context, '/'), // this for refresh the whole app
              ),
        ),
        SizedBox(height: 50),
      ],
    );
  }
}

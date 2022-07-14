import 'package:doctor_panel/utils/utils.dart';
import 'package:flutter/material.dart';

class ViewEducation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // _columnItem(mQuery, String degreeName, String startTime, String endTime, String university)
            _columnItem(
              mQuery,
              'Degree Name One',
              'March 2014',
              'January 2019',
              'Comsats University Islamabad',
            ),
            _columnItem(
              mQuery,
              'Degree Name Two',
              'March 2018',
              'January 2021',
              'Eve Sena Balkh',
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Card _columnItem(mQuery, String degreeName, String startTime, String endTime, String university) {
    return Card(
      margin: EdgeInsets.only(top: 10),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 10),
        width: mQuery.width * 0.90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              degreeName,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            SizedBox(
              height: 3,
            ),
            Row(
              children: [
                Icon(Icons.check),
                Expanded(
                  child: Text(
                    university,
                    style: TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 16, color: Palette.blueAppBar),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 25,
                ),
                Expanded(
                  child: Text(
                    '$startTime - $endTime',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:doctor_panel/utils/utils.dart';
import 'package:flutter/material.dart';

class ViewCareService extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _careServiceItem(
              mQuery,
              'Specializations',
              ['Speciality One', 'Speciality Two', 'Speciality Three'],
            ),
            _careServiceItem(
              mQuery,
              'Services',
              ['Service One', 'Service Two', 'Service Three'],
            ),
            _careServiceItem(
              mQuery,
              'Conditions',
              ['Conditions One', 'Conditions Two', 'Conditions Three'],
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Card _careServiceItem(mQuery, String title, List<String> itemList) {
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
              title,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            SizedBox(
              height: 3,
            ),
            ...itemList.map(
              (e) => Row(children: [
                Icon(
                  Icons.check,
                  color: Palette.blueAppBar,
                ),
                Text(
                  e,
                  style: TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 16.0, color: Palette.blueAppBar),
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}

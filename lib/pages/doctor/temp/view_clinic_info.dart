import 'package:doctor_panel/utils/utils.dart';
import 'package:flutter/material.dart';

class ViewClinicInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // String clinicName, String workingTime, String slotDuration, String address)
            _columnItem(
              mQuery,
              'Afghan German Hospital',
              '08:30 AM - 02:00 PM',
              '30',
              'St - 1, Sherpor, Shahr Now, Kabul',
            ),
            _columnItem(
              mQuery,
              'Maulana Medical Complex',
              '08:30 AM - 02:00 PM',
              '30',
              'St - 1, Sherpor, Shahr Now, Kabul',
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Card _columnItem(
      mQuery, String clinicName, String workingTime, String slotDuration, String address) {
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
              clinicName,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            SizedBox(
              height: 3,
            ),
            Row(
              children: [
                Icon(Icons.business_center_outlined),
                Expanded(
                  child: Text(
                    'Working Hours: $workingTime',
                    style: TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 16, color: Palette.blueAppBar),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.access_time),
                Expanded(
                  child: Text(
                    'Slot Duration: $slotDuration Mins',
                    style: TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 16, color: Palette.blueAppBar),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.location_on_outlined),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 15, color: Palette.blueAppBar),
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

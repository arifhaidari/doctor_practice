import 'package:doctor_panel/utils/utils.dart';
import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Palette.imageBackground,
      appBar: AppBar(
        title: Text(
          'About Us',
          style:
              TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Palette.imageBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: mQuery.width * 0.80,
              child: Center(
                child: Text(
                  'Doctor Plus',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Center(
              child: Container(
                width: mQuery.width * 0.85,
                child: Text(
                  'Plaintiffs alleged that Defendants have unreasonably delayed the adjudication of SIV applications submitted by certain Iraqi and Afghan nationals under the Refugee Crisis in Iraq Act of 2007 (“RCIA”) and the Afghan Allies Protection Act of 2009 (“AAPA”).  Defendants deny many of these allegations.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              width: mQuery.width * 0.80,
              child: Center(
                child: Text(
                  'Doctor Practice',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Center(
              child: Container(
                width: mQuery.width * 0.85,
                child: Text(
                  'Plaintiffs alleged that Defendants have unreasonably delayed the adjudication of SIV applications submitted by certain Iraqi and Afghan nationals under the Refugee Crisis in Iraq Act of 2007 (“RCIA”) and the Afghan Allies Protection Act of 2009 (“AAPA”).  Defendants deny many of these allegations.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              width: mQuery.width * 0.80,
              child: Center(
                child: Text(
                  'Doctor Plus Partnership With Health Ministry Of Afghanistan',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Center(
              child: Container(
                width: mQuery.width * 0.85,
                child: Text(
                  'Plaintiffs alleged that Defendants have unreasonably delayed the adjudication of SIV applications submitted by certain Iraqi and Afghan nationals under the Refugee Crisis in Iraq Act of 2007 (“RCIA”) and the Afghan Allies Protection Act of 2009 (“AAPA”).  Defendants deny many of these allegations.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              width: mQuery.width * 0.80,
              child: Center(
                child: Text(
                  'Our Long Term Goal',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Center(
              child: Container(
                width: mQuery.width * 0.85,
                child: Text(
                  'Plaintiffs alleged that Defendants have unreasonably delayed the adjudication of SIV applications submitted by certain Iraqi and Afghan nationals under the Refugee Crisis in Iraq Act of 2007 (“RCIA”) and the Afghan Allies Protection Act of 2009 (“AAPA”).  Defendants deny many of these allegations.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              width: mQuery.width * 0.80,
              child: Center(
                child: Text(
                  'Contact Us',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Center(
              child: Container(
                width: mQuery.width * 0.85,
                child: Text(
                  'Plaintiffs alleged that Defendants have unreasonably delayed the adjudication of SIV applications submitted by certain Iraqi and Afghan nationals under the Refugee Crisis in Iraq Act of 2007 (“RCIA”) and the Afghan Allies Protection Act of 2009 (“AAPA”).  Defendants deny many of these allegations.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

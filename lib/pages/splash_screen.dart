import 'package:flutter/material.dart';
import '../utils/utils.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Container(
        height: mQuery.height,
        width: mQuery.width,
        color: Palette.darkPurple,
        // backgroundColor: Palette.darkPurple,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Center(
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  child: Container(
                    height: 170,
                    width: 170,
                    decoration: BoxDecoration(
                      // shape: BoxShape.circle,
                      color: Palette.darkPurple,
                    ),
                    child: Container(
                      height: 150,
                      // width: mQuery.width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/icons/login_background.png'),
                            fit: BoxFit.fitHeight),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Center(
                child: Container(
              width: mQuery.width * 0.75,
              child: Column(
                children: [
                  Text(
                    'DOCTOR PRACTICE',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Best Doctor, Best Treatment',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )),
            Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.blue,
              semanticsLabel: 'Semantic Lable',
              semanticsValue: 'Semantic Value',
              // value: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ))
          ],
        ));
  }
}

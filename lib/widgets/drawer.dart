import 'package:auto_size_text/auto_size_text.dart';
import 'package:doctor_panel/providers/end_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../utils/utils.dart';
import '../pages/screens.dart';
import 'widgets.dart';

// Widget customDrawer(mQuery, context) {
//   return CustomDrawer();
// }

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({
    Key? key,
  }) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  // Map<String, dynamic> drawerData = {};
  // @override
  // void initState() {
  //   FocusScope.of(widget.ctx).unfocus();
  //   super.initState();
  //   // _theImage
  //   // _initialize();
  // }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Drawer(
        child: Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 300,
              // height: mQuery.height * 0.32,
              color: Palette.blueAppBar,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 45.0,
                  ),
                  ProfileAvatarCircle(
                    imageUrl: (DRAWER_DATA['avatar'] != null && DRAWER_DATA['avatar'] != '')
                        ? MEDIA_LINK_NO_SLASH + DRAWER_DATA['avatar']
                        : null,
                    isActive: true,
                    radius: 90,
                    onlinePosition: 6,
                    borderWidth: 2.5,
                    circleColor: Palette.heavyYellow,
                    male: DRAWER_DATA['gender'] == 'Male' ? true : false,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  RatingBarIndicator(
                    rating: DRAWER_DATA['average_star'],
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Colors.amberAccent,
                    ),
                    itemCount: 5,
                    itemSize: 21.0,
                    unratedColor: Colors.white,
                    direction: Axis.horizontal,
                  ),
                  SizedBox(
                    height: 3.0,
                  ),
                  AutoSizeText(
                    DRAWER_DATA['full_name'],
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 18.0, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    minFontSize: 14,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _profileAnalytics("Patients", DRAWER_DATA['patient_no']),
                      _profileAnalytics("Feedbacks", DRAWER_DATA['feedback_no']),
                      _profileAnalytics("Appts", DRAWER_DATA['booked_appt_no']),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        //second child of stack
        Column(
          children: [
            Container(
              height: 250,
              // height: mQuery.height * 0.28,
              color: Colors.transparent,
            ),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 15.0),
              elevation: 3.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  // height: 470,
                  height: mQuery.height * 0.52,
                  width: mQuery.width * 0.95,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5.0,
                        ),
                        _drawerItem("View Profile", Icons.person, context, ViewDoctorProfile()),
                        _drawerItem("Reviews", Icons.star, context, DoctorReview()),
                        _drawerItem(
                            "Notifications", Icons.notifications, context, NotificationView()),
                        _drawerItem(
                            "Profile Settings", Icons.person_add, context, ProfileSetting()),
                        _drawerItem("Languages", Icons.language, context, null),
                        _drawerItem("About Us", Icons.info, context, AboutUs()),
                        _drawerItem("Settings", Icons.settings, context, Settings()),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, left: 25.0),
                          child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  elevation: 8.0,
                                  primary: Palette.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  )),
                              onPressed: () async {
                                questionDialogue(context, 'Do you really want to logout?', 'Logout',
                                    () async {
                                  await SharedPref().logout();
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) => SignupLogin()));
                                });
                              },
                              icon: Icon(Icons.logout),
                              label: Text(
                                'Logout',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              )),
                        ),
                      ],
                    ),
                  )),
            )
          ],
        )
      ],
    ));
  }

  Column _profileAnalytics(String item, String value) {
    return Column(
      children: [
        Text(
          item,
          style: TextStyle(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.w400),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _drawerItem(String text, IconData icon, BuildContext context, page) {
    return InkWell(
      splashColor: Colors.black,
      onTap: () {
        print('the inkwell got taped');
        if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        } else {
          simpleDialogueBox(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 28,
              width: 28,
              child: Icon(
                icon,
                color: Colors.yellow,
              ),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue[900]),
            ),
            TextButton(
              onPressed: () {
                print('text button');
                if (page != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
                } else {
                  simpleDialogueBox(context);
                }

                print('//////////');
              },
              child: Text(
                text,
                style:
                    TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500, color: Colors.blue[900]),
              ),
            ),
            if (page == null)
              Text(
                '(EN)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                textAlign: TextAlign.end,
              ),
            if (text == 'Notifications' && DRAWER_DATA['is_unseen_note'])
              Text(
                'New',
                style: TextStyle(color: Colors.red[900]),
              )
          ],
        ),
      ),
    );
  }
}

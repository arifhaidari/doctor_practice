// import 'package:flutter/material.dart';
// import '../../../utils/utils.dart';
// import '../../screens.dart';

// class ViewDoctorProfileTemp extends StatefulWidget {
//   @override
//   _ViewDoctorProfileTempState createState() => _ViewDoctorProfileTempState();
// }

// class _ViewDoctorProfileTempState extends State<ViewDoctorProfileTemp> {
//   DateTime pickedDate = DateTime.now();
//   int tabIndex = 0;
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 6,
//       child: Scaffold(
//         backgroundColor: Palette.scaffoldBackground,
//         appBar: AppBar(
//           title: Text(
//             "Doctor Profile",
//             style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
//           ),
//           backgroundColor: Palette.blueAppBar,
//           actions: [],
//           bottom: TabBar(
//             isScrollable: true,
//             onTap: (value) => _activeTab(value),
//             // isScrollable: true,
//             unselectedLabelColor: Colors.yellowAccent,
//             labelColor: Palette.blueAppBar,
//             indicatorSize: TabBarIndicatorSize.label,
//             indicator: BoxDecoration(
//               borderRadius: BorderRadius.circular(30),
//               gradient: Palette.tabGradient,
//               color: Palette.scaffoldBackground,
//             ),
//             tabs: [
//               patientProfileTab('Overview'),
//               patientProfileTab('Care Services'),
//               patientProfileTab('Clinic Info'),
//               patientProfileTab('Education'),
//               patientProfileTab('Experience'),
//               patientProfileTab('Address'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             // BasicInfoSetting(),
//             // ViewCareService(),
//             // ViewClinicInfo(),
//             // ViewEducation(),
//             // ViewExperience(),
//             // ViewExperience(),
//           ],
//         ),
//       ),
//     );
//   }

//   void _activeTab(int index) {
//     setState(() {
//       tabIndex = index;
//     });
//   }
// }

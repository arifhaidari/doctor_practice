
// import 'package:doctor_panel/models/doctor_model.dart';
// import 'package:doctor_panel/models/model_list.dart';
// import 'package:doctor_panel/providers/provider_list.dart';
// import 'package:flutter/material.dart';
// import '../../utils/utils.dart';
// import '../screens.dart';

// class ProfileSetting extends StatefulWidget {
//   @override
//   _ProfileSettingState createState() => _ProfileSettingState();
// }

// class _ProfileSettingState extends State<ProfileSetting> {
//   // DateTime pickedDate = DateTime.now();

//   late DoctorModel doctorModel;

//   List<DoctorTitleModel> _doctorTitleList = <DoctorTitleModel>[];
//   @override
//   void initState() {
//     super.initState();
//     _getTitle();
//   }

//   Future<void> _getTitle() async {
//     var progressObject = await progressDialogue(context: context);
//     await progressObject.show();

//     var doctorTitleResponse =
//         await HttpService().getRequest(endPoint: DOCTOR_TITLE_URL, isAuth: false);

//     if (!doctorTitleResponse.error) {
//       if (doctorTitleResponse.data is List) {
//         setState(() {
//           doctorTitleResponse.data.forEach((response) {
//             final titleObject = DoctorTitleModel.fromJson(response);
//             _doctorTitleList.add(titleObject);
//           });
//         });
//       }
//     }

//     await progressObject.hide();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: SharedPref().dashboardBrief(),
//       builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return StartSplashScreen();
//         }
//         if (snapshot.connectionState == ConnectionState.done) {
//           if (snapshot.hasData && snapshot.data!.isEmpty) {
//             return SignupLogin();
//           }
//         }
//         return FutureBuilder(
//             future: HttpService()
//                 .getRequest(endPoint: VIEW_DOCTOR_PROFILE_PLUS + "${snapshot.data!['id']}/"),
//             builder: (context, AsyncSnapshot<APIResponse> snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return StartSplashScreen();
//               }
//               if (snapshot.hasError) {
//                 return ErrorPage();
//               }
//               if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
//                 if (snapshot.data!.error) {
//                   if (snapshot.data!.errorMessage == NO_INTERNET_CONNECTION) {
//                     return ErrorPage(errorMessage: 'No Internet Connection. Please Try Again');
//                   }
//                   return ErrorPage(
//                     errorMessage: snapshot.data!.errorMessage.toString(),
//                   );
//                 }
//                 // model all the data here
//                 if (snapshot.data!.data == null) {
//                   return ErrorPage();
//                 }

//                 doctorModel = DoctorModel.fromJson(snapshot.data!.data);

//                 return DefaultTabController(
//                   length: 7,
//                   child: Scaffold(
//                     backgroundColor: Palette.scaffoldBackground,
//                     appBar: AppBar(
//                       title: Text(
//                         "Profile Settings",
//                         style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
//                       ),
//                       backgroundColor: Palette.blueAppBar,
//                       actions: [],
//                       bottom: TabBar(
//                         isScrollable: true,
//                         // onTap: (value) => _activeTab(value),
//                         // isScrollable: true,
//                         unselectedLabelColor: Colors.yellowAccent,
//                         labelColor: Palette.blueAppBar,
//                         indicatorSize: TabBarIndicatorSize.label,
//                         indicator: BoxDecoration(
//                           borderRadius: BorderRadius.circular(30),
//                           gradient: Palette.tabGradient,
//                           // color: Colors.white,
//                           color: Palette.scaffoldBackground,
//                         ),
//                         tabs: [
//                           patientProfileTab('Basic Info'),
//                           patientProfileTab('Care Services'),
//                           patientProfileTab('Clinic Info'),
//                           patientProfileTab('Education'),
//                           patientProfileTab('Experience'),
//                           patientProfileTab('About Me'),
//                           patientProfileTab('Award'),
//                         ],
//                       ),
//                     ),
//                     body: TabBarView(
//                       children: [
//                         // send a numebr to every page and if it was the same request server for getting the data
//                         // but if it was different then do not request becuase in the first request we get all data and then we  change it
//                         // or we should recieve all the data at first pass to every one of them
//                         BasicInfoSetting(
//                             userId: doctorModel.user!.id ?? 0, doctorTitleList: _doctorTitleList),
//                         CareServiceSetting(doctorModel: doctorModel),
//                         ClinicInfoSetting(
//                             doctorId: doctorModel.user!.id ?? 0,
//                             existingClinic: doctorModel.clinicList ?? <ClinicModel>[]),
//                         EducationSetting(
//                             educationList: doctorModel.educationList ?? <EducationModel>[]),
//                         ExperienceSetting(
//                           experienceList: doctorModel.experienceList ?? <ExperienceModel>[],
//                         ),
//                         AboutMeSetting(
//                           englishBio: doctorModel.bio!,
//                           farsiBio: doctorModel.bioFarsi!,
//                           pashtoBio: doctorModel.bioPashto!,
//                         ),
//                         AwardSetting(
//                           awardList: doctorModel.awardList ?? <AwardModel>[],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }
//               return ErrorPage();
//             });
//       },
//     );
//   }
// }

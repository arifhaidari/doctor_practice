// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import '../../providers/provider_list.dart';
// // ignore: import_of_legacy_library_into_null_safe
// import 'package:sliverbar_with_card/sliverbar_with_card.dart';
// import '../../providers/end_point.dart';
// import '../../utils/utils.dart';
// import '../../widgets/widgets.dart';
// import '../screens.dart';
// import '../../models/model_list.dart';

// class ViewDoctorProfile extends StatefulWidget {
//   @override
//   _ViewDoctorProfileState createState() => _ViewDoctorProfileState();
// }

// class _ViewDoctorProfileState extends State<ViewDoctorProfile> {
//   bool favorito = false;

//   bool _isUnknownError = false;
//   bool _isConnectionError = false;
//   bool _isLoading = false;
//   String _errorMessage = '';

//   late DoctorModel doctorModel;
//   late FeedbackDataModel _feedbackDataModel;

//   late ImageProvider theImage;

//   final borderRad =
//       BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10));

//   // List<Map<String, double>> _mapList = [
//   //   {'lat': 34.53401150373386, 'lng': 69.1728845254006},
//   //   {'lat': 34.53696709035473, 'lng': 69.19056250241701}
//   // ];

//   @override
//   void initState() {
//     super.initState();
//     print('value of DRAWER_DATA');
//     print(DRAWER_DATA['id']);
//     _getData();
//   }

//   Future<void> _getData() async {
//     setState(() {
//       _isLoading = true;
//     });
//     //
//     final _doctorProfileResponse = await HttpService()
//         .getRequest(endPoint: VIEW_DOCTOR_PROFILE_PLUS + "${DRAWER_DATA['id']}/");

//     if (!_doctorProfileResponse.error) {
//       try {
//         setState(() {
//           doctorModel = DoctorModel.fromJson(_doctorProfileResponse.data['doctor_dataset']);
//           _feedbackDataModel =
//               FeedbackDataModel.fromJson(_doctorProfileResponse.data['feedback_dataset']);
//           theImage = (doctorModel.user!.avatar != null
//               ? NetworkImage(doctorModel.user!.avatar!)
//               : AssetImage(doctorModel.user!.gender == 'Male'
//                   ? GlobalVariable.DOCTOR_MALE
//                   : GlobalVariable.DOCOTOR_FEMALE) as ImageProvider);

//           _isLoading = false;
//         });
//       } catch (e) {
//         print('value rof erororororor909099');
//         print(e);
//         setState(() {
//           _isLoading = false;
//           _isUnknownError = true;
//           _errorMessage = GlobalVariable.UNEXPECTED_ERROR;
//         });
//       }
//     } else {
//       infoNoOkDialogue(
//           context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
//       setState(() {
//         _isLoading = false;
//         if (_doctorProfileResponse.errorMessage == NO_INTERNET_CONNECTION) {
//           _isConnectionError = true;
//         } else {
//           _isUnknownError = true;
//           _errorMessage = _doctorProfileResponse.errorMessage!;
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mQuery = MediaQuery.of(context).size;
//     return Builder(builder: (BuildContext ctx) {
//       if (_isLoading) {
//         return LoadingPlaceHolder();
//       }
//       if (_isUnknownError || _isConnectionError) {
//         if (_isConnectionError) {
//           return ErrorPlaceHolder(
//               isStartPage: true,
//               errorTitle: GlobalVariable.INTERNET_ISSUE_TITLE,
//               errorDetail: GlobalVariable.INTERNET_ISSUE_CONTENT);
//         } else {
//           return ErrorPlaceHolder(
//             isStartPage: true,
//             errorTitle: GlobalVariable.UNEXPECTED_ERROR,
//             errorDetail: _errorMessage,
//           );
//         }
//       }
//       return Material(
//           color: Palette.blueAppBar,
//           child: CardSliverAppBar(
//             height: mQuery.height * 0.20,
//             // height: 180,
//             background: Image.asset(GlobalVariable.DOCTOR_PROFILE_BACKGROUND, fit: BoxFit.cover),
//             title: Text(
//               doctorModel.user!.name!,
//               style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
//               maxLines: 1,
//             ),
//             titleDescription: Text(
//               doctorModel.specialityList![0].name!,
//               style: TextStyle(color: Colors.black, fontSize: 14),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             card: theImage,
//             backButton: true,
//             backButtonColors: [Colors.white, Colors.black],
//             action: IconButton(
//               onPressed: () => Navigator.push(
//                   context, MaterialPageRoute(builder: (context) => ProfileSetting())),
//               icon: Icon(CupertinoIcons.settings_solid),
//               color: Palette.blueAppBar,
//               iconSize: 35.0,
//             ),
//             body: Container(
//               // alignment: Alignment.topLeft,
//               color: Colors.white,
//               width: MediaQuery.of(context).size.width,
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: <Widget>[
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: Card(
//                         margin: EdgeInsets.only(top: 20),
//                         elevation: 8,
//                         shape: RoundedRectangleBorder(borderRadius: borderRad),
//                         child: Container(
//                           height: 65.0,
//                           width: mQuery.width * 0.63,
//                           decoration: BoxDecoration(
//                             borderRadius: borderRad,
//                             color: Palette.imageBackground,
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               RatingBarIndicator(
//                                 rating: 3.5,
//                                 itemBuilder: (context, index) => Icon(
//                                   Icons.star,
//                                   color: Colors.amberAccent,
//                                 ),
//                                 itemCount: 5,
//                                 itemSize: 25.0,
//                                 unratedColor: Colors.white,
//                                 direction: Axis.horizontal,
//                               ),
//                               SizedBox(
//                                 height: 3.0,
//                               ),
                              // Text(
                              //   '${DRAWER_DATA["feedback_no"]} Feedbacks, On Avg ${DRAWER_DATA["average_star"]}/5',
                              //   style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
                              //   maxLines: 1,
                              //   overflow: TextOverflow.ellipsis,
                              // )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(top: 10),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: <Widget>[
//                           theCircularIndicator(
//                             icon: Icons.star,
//                             text: "Overall\nExperience",
//                             thePercentage: _feedbackDataModel.overallExperience ?? 35.0,
//                           ),
//                           theCircularIndicator(
//                             icon: Icons.local_hospital,
//                             text: "Doctor\nCheckup",
//                             thePercentage: _feedbackDataModel.doctorCheckup ?? 35.0,
//                           ),
//                           theCircularIndicator(
//                             icon: Icons.people,
//                             text: "Staff\nBehavior",
//                             thePercentage: _feedbackDataModel.staffBehavior ?? 35.0,
//                           ),
//                           theCircularIndicator(
//                             icon: Icons.clean_hands,
//                             text: "Clinic\nEnvironment",
//                             thePercentage: _feedbackDataModel.clinicEnvironment ?? 35.0,
//                           ),
//                         ],
//                       ),
//                     ),
//                     Divider(),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Expanded(
//                             child: _rowAnalitics(_feedbackDataModel.patientNo ?? 0, 'Patients')),
//                         Container(
//                           height: 35,
//                           child: VerticalDivider(
//                             thickness: 1,
//                             color: Colors.black,
//                           ),
//                         ),
//                         Expanded(
//                             child: _rowAnalitics(_feedbackDataModel.completedApptNo ?? 0, 'Appts')),
//                         Container(
//                           height: 35,
//                           child: VerticalDivider(
//                             thickness: 1,
//                             color: Colors.black,
//                           ),
//                         ),
//                         Expanded(
//                             child: _rowAnalitics(
//                                 _feedbackDataModel.experienceYear ?? 1, 'Experience',
//                                 experience: true)),
//                       ],
//                     ),
//                     _customDivider(),
//                     BioGraphy(
//                       bio: doctorModel.bio!,
//                       farsiBio: doctorModel.bioFarsi ?? '',
//                       pashtoBio: doctorModel.bioPashto ?? '',
//                     ),
//                     _customDivider(),
//                     _mapAddress(doctorModel),
//                     _customDivider(),
//                     _careServiceItem(mQuery, 'Specialities', doctorModel),
//                     _customDivider(),
//                     _careServiceItem(mQuery, 'Services', doctorModel),
//                     _customDivider(),
//                     _careServiceItem(mQuery, 'Conditions', doctorModel),
//                     _customDivider(),
//                     DoctorMoreInfo(mQuery: mQuery, doctorModel: doctorModel),
//                     SizedBox(
//                       height: 20,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ));
//     });
//   }

//   Widget _mapAddress(DoctorModel modelObject) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 30),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.location_on_outlined,
//                 size: 22,
//               ),
//               Text(
//                 modelObject.clinicList![0].city != null
//                     ? '${modelObject.clinicList![0].district!.name ?? ""}, ${modelObject.clinicList![0].city!.name ?? ""}'
//                     : "Unknown District, Unknown City",
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//           SizedBox(
//             height: 5.0,
//           ),
//           Container(
//               height: 200,
//               decoration: BoxDecoration(
//                 color: Palette.imageBackground,
//                 border: Border.all(width: 3, color: Palette.imageBackground),
//               ),
//               child: GoogleMapWidget(
//                 mapType: 'view_doctor_profile',
//                 clinicObjectList: modelObject.clinicList ?? <ClinicModel>[],
//               )),
//         ],
//       ),
//     );
//   }

//   Container _careServiceItem(mQuery, String title, DoctorModel modelObject) {
//     final theList = modelObject.specialityList;
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 30),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
//           ),
//           SizedBox(
//             height: 3,
//           ),
//           if (theList == null || theList.length < 0)
//             Text(
//               "No Item",
//               style: TextStyle(
//                 fontWeight: FontWeight.w400,
//                 fontSize: 16.0,
//               ),
//             ),
//           if (theList != null && theList.length > 0)
//             ...theList.map(
//               (e) => Row(children: [
//                 Icon(
//                   Icons.check,
//                   color: Palette.blueAppBar,
//                 ),
//                 Text(
//                   e.name ?? "",
//                   style: TextStyle(
//                     fontWeight: FontWeight.w400,
//                     fontSize: 16.0,
//                   ),
//                 ),
//               ]),
//             )
//         ],
//       ),
//     );
//   }

//   Column _rowAnalitics(int theDigit, String theTitle, {bool experience = false}) {
//     return Column(
//       children: [
//         RichText(
//           text: TextSpan(
//               text: theDigit.toString(),
//               style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black),
//               children: [
//                 if (experience)
//                   TextSpan(
//                       text: ' Year(s)',
//                       style:
//                           TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.black))
//               ]),
//         ),
//         Text(
//           theTitle,
//           style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
//         ),
//       ],
//     );
//   }

//   Container _customDivider() {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
//       child: dashedLine(Colors.blue),
//     );
//   }
// }

// class BioGraphy extends StatefulWidget {
//   final String bio;
//   final String farsiBio;
//   final String pashtoBio;
//   const BioGraphy({
//     Key? key,
//     required this.bio,
//     required this.farsiBio,
//     required this.pashtoBio,
//   }) : super(key: key);

//   @override
//   _BioGraphyState createState() => _BioGraphyState();
// }

// class _BioGraphyState extends State<BioGraphy> {
//   bool expandText = true;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(
//         left: 30,
//         right: 30,
//       ),
//       child: InkWell(
//           onTap: () {
//             setState(() {
//               expandText = !expandText;
//             });
//           },
//           child: Column(
//             children: [
//               if (expandText)
//                 RichText(
//                   text: TextSpan(
//                     text: widget.bio,
//                     style:
//                         TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400, color: Colors.black),
//                     children: [
//                       TextSpan(
//                         text: ' ... Show More',
//                         style: TextStyle(
//                             color: Colors.blue[900], fontSize: 15.0, fontWeight: FontWeight.w500),
//                       ),
//                     ],
//                   ),
//                 ),
//               if (!expandText)
//                 Column(
//                   children: [
//                     Text(
//                       'Biography',
//                       style: TextStyle(
//                         fontSize: 18.0,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 4.0,
//                     ),
//                     RichText(
//                       textAlign: TextAlign.left,
//                       text: TextSpan(
//                           text: widget.bio,
//                           style: TextStyle(
//                             fontSize: 15.0,
//                             fontWeight: FontWeight.w400,
//                             color: Colors.black,
//                           ),
//                           children: [
//                             TextSpan(
//                               text: ' ... Show Less',
//                               style: TextStyle(
//                                   color: Colors.blue[900],
//                                   fontSize: 15.0,
//                                   fontWeight: FontWeight.w500),
//                             )
//                           ]),
//                     ),
//                     SizedBox(
//                       height: 5.0,
//                     ),
//                     Text(
//                       'زنده گی نامه',
//                       style: TextStyle(
//                         fontSize: 18.0,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 4.0,
//                     ),
//                     Text(
//                       widget.farsiBio,
//                       style: TextStyle(
//                         fontSize: 15.0,
//                         fontWeight: FontWeight.w400,
//                         color: Colors.black,
//                       ),
//                       textAlign: TextAlign.right,
//                     ),
//                     SizedBox(
//                       height: 5.0,
//                     ),
//                     Text(
//                       'بیوگرافی',
//                       style: TextStyle(
//                         fontSize: 18.0,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 4.0,
//                     ),
//                     Text(
//                       widget.pashtoBio,
//                       style: TextStyle(
//                         fontSize: 15.0,
//                         fontWeight: FontWeight.w400,
//                         color: Colors.black,
//                       ),
//                       textAlign: TextAlign.right,
//                     ),
//                   ],
//                 ),
//             ],
//           )),
//     );
//   }
// }

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import '../screens.dart';
// import 'package:auto_size_text/auto_size_text.dart';
// import '../../utils/utils.dart';

// // class ApptList extends StatelessWidget {
//   final isImage = true;
//   @override
//   Widget build(BuildContext context) {
//     final mQuery = MediaQuery.of(context).size;
//     return Expanded(
//       child: ListView.builder(
//         padding: EdgeInsets.all(10.0),
//         shrinkWrap: true,
//         scrollDirection: Axis.vertical,
//         physics: PageScrollPhysics(),
//         itemCount: 7,
//         itemBuilder: (context, index) {
//           return Card(
//             margin: EdgeInsets.only(top: 5, bottom: 10),
//             elevation: 3.0,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20.0),
//             ),
//             child: Container(
//               padding: EdgeInsets.all(8),
//               width: mQuery.width * 0.94,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20.0),
//                 color: Colors.white,
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(5.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Booking Date - 12 Jan 2021',
//                           style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
//                         ),
//                         Text(
//                           'Pending',
//                           style: TextStyle(
//                               fontSize: 15, fontWeight: FontWeight.w400, color: Palette.darkGreen),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     height: 3.0,
//                   ),
//                   dashedLine(Palette.lightGreen),
//                   SizedBox(
//                     height: 3.0,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         _userImage(),
//                         SizedBox(
//                           width: 10.0,
//                         ),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               AutoSizeText(
//                                 'Arif Khan',
//                                 maxLines: 1,
//                                 minFontSize: 16,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                               ),
//                               SizedBox(
//                                 height: 2.0,
//                               ),
//                               AutoSizeText(
//                                 'Duration: 01:30 PM - 02:30 PM',
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 minFontSize: 14,
//                                 style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w400,
//                                     color: Palette.darkGreen),
//                               ),
//                               SizedBox(
//                                 height: 2.0,
//                               ),
//                               AutoSizeText(
//                                 'Hospital: Maulana Jalaluding Hospital',
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                                 minFontSize: 13,
//                                 style: TextStyle(
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.w500,
//                                     color: Palette.blueAppBar),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(right: 5.0),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     ElevatedButton.icon(
//                                         style: ElevatedButton.styleFrom(
//                                             elevation: 5.0,
//                                             primary: Palette.red,
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius: BorderRadius.circular(15),
//                                             )),
//                                         onPressed: () {},
//                                         icon: Icon(Icons.clear),
//                                         label: Text(
//                                           'Cancel',
//                                           style:
//                                               TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//                                         )),
//                                     SizedBox(
//                                       width: 10.0,
//                                     ),
//                                     ElevatedButton.icon(
//                                         style: ElevatedButton.styleFrom(
//                                             elevation: 5.0,
//                                             primary: Palette.blueAppBar,
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius: BorderRadius.circular(15),
//                                             )),
//                                         onPressed: () async {
//                                           Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: (context) => PatientProfile(patientId: ,)));
//                                         },
//                                         icon: Icon(Icons.remove_red_eye),
//                                         label: Text(
//                                           'View',
//                                           style:
//                                               TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//                                         )),
//                                   ],
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Container _userImage() {
//     return Container(
//       height: 110,
//       width: 110,
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           color: Palette.imageBackground,
//           border: Border.all(
//             width: 3.0,
//             color: Palette.blueAppBar,
//           )),
//       child: 2 == 1
//           ? ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.asset(
//                 'male' == 'male'
//                     ? 'assets/icons/male_icon.jpeg'
//                     // ? 'assets/icons/male_icon.png'
//                     : 'assets/icons/female_icon.png',
//                 fit: BoxFit.cover,
//               ),
//             )
//           : CachedNetworkImage(
//               imageBuilder: (context, imageProvider) => Container(
//                 decoration: BoxDecoration(
//                   // borderRadius: BorderRadius.circular(8),
//                   image: DecorationImage(
//                     image: imageProvider,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               placeholder: (context, url) => circularLoading(),
//               errorWidget: (context, url, error) => ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.asset(
//                   'male' == 'male'
//                       ? 'assets/icons/male_icon.jpeg'
//                       // ? 'assets/icons/male_icon.png'
//                       : 'assets/icons/female_icon.png',
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               fit: BoxFit.cover,
//               imageUrl:
//                   'https://wwd.com/wp-content/uploads/2020/07/random-identities-mens-s21-1.jpg?w=800',
//             ),
//     );
//   }
// }

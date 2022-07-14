// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:doctor_panel/models/model_list.dart';
// import 'package:doctor_panel/providers/provider_list.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import '../../utils/utils.dart';

// class PatientApptSlot extends StatefulWidget {
//   final Future<List<ApptModel>> apptModel;

//   const PatientApptSlot({Key? key, required this.apptModel}) : super(key: key);
//   @override
//   _PatientApptSlotState createState() => _PatientApptSlotState();
// }

// class _PatientApptSlotState extends State<PatientApptSlot> {
//   List<ApptModel> _apptModelList = <ApptModel>[];
//   @override
//   void initState() {
//     super.initState();
//     // _getCompletedBookedAppt();
//     _getTheValue();
//   }

//   void _getTheValue() async {
//     _apptModelList = await widget.apptModel;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final mQuery = MediaQuery.of(context).size;
//     return _apptModelList.length == 0
//         ? Placeholder()
//         : SafeArea(
//             top: false,
//             child: StaggeredGridView.countBuilder(
//               shrinkWrap: true,
//               physics: ScrollPhysics(),
//               padding: const EdgeInsets.all(8.0),
//               staggeredTileBuilder: (index) => StaggeredTile.count(2, 1.2),
//               crossAxisCount: Responsive.isMobile(context) ? 4 : 8,
//               itemCount: _apptModelList.length,
//               mainAxisSpacing: 6,
//               crossAxisSpacing: 6,
//               itemBuilder: (context, index) => Card(
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
//                 elevation: 8.0,
//                 child: Container(
//                     height: 120,
//                     padding: const EdgeInsets.all(8.0),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(15),
//                       color: !_apptModelList[index].active
//                           ? Colors.red
//                           : (_apptModelList[index].status == 'Booked'
//                               ? Colors.brown
//                               : Palette.blueAppBar),
//                     ),
//                     child: Column(
//                       children: [
//                         _apptHeader(
//                           index: index,
//                           date: _apptModelList[index].apptDate ?? 'Unknown Date',
//                           status: _apptModelList[index].status ?? 'Unknow State',
//                         ),
//                         SizedBox(
//                           height: 3.0,
//                         ),
//                         dashedLine(Colors.white),
//                         SizedBox(
//                           height: 4.0,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                                 child: _fromToText(
//                                     'From', _apptModelList[index].startApptTime ?? 'Uknown Time')),
//                             Expanded(
//                                 child: _fromToText(
//                                     'To', _apptModelList[index].endApptTime ?? 'Uknown Time')),
//                           ],
//                         )
//                       ],
//                     )),
//               ),
//             ),
//           );
//   }
// }

// Column _fromToText(String title, String data) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       AutoSizeText(
//         title,
//         style: TextStyle(fontSize: 16, color: Colors.white),
//         maxLines: 1,
//         minFontSize: 13,
//         overflow: TextOverflow.ellipsis,
//       ),
//       SizedBox(
//         height: 4.0,
//       ),
//       Container(
//         padding: const EdgeInsets.all(5.0),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10.0),
//           color: Colors.white,
//         ),
//         child: AutoSizeText(
//           data,
//           style: TextStyle(fontSize: 16),
//           maxLines: 1,
//           minFontSize: 13,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//     ],
//   );
// }

// Row _apptHeader({
//   String status = 'Completed',
//   String date = 'Monday',
//   required int index,
// }) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Expanded(
//         child: AutoSizeText(
//           status,
//           style: TextStyle(fontSize: 14, color: Colors.white),
//           maxLines: 1,
//           minFontSize: 12,
//           overflow: TextOverflow.ellipsis,
//         ),
//       ),
//       Expanded(
//         child: AutoSizeText(
//           date,
//           style: TextStyle(fontSize: 14, color: Colors.white),
//           maxLines: 1,
//           minFontSize: 12,
//           overflow: TextOverflow.ellipsis,
//           textAlign: TextAlign.right,
//         ),
//       ),
//     ],
//   );
// }

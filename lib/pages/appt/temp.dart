// import 'dart:developer';
// import 'package:dio/dio.dart';
// import 'package:doctor_panel/models/model_list.dart';
// import 'package:doctor_panel/providers/provider_list.dart';
// import 'package:doctor_panel/utils/utils.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'dart:io';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

// class ApptQrScanner extends StatefulWidget {
//   final List<BookedApptModel> bookedApptList;
//   const ApptQrScanner({Key? key, required this.bookedApptList}) : super(key: key);

//   @override
//   _ApptQrScannerState createState() => _ApptQrScannerState();
// }

// class _ApptQrScannerState extends State<ApptQrScanner> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   Barcode? result;
//   QRViewController? controller;

//   String todayDate = 'Monday';

//   int _apptId = 0;

//   @override
//   void initState() {
//     super.initState();
//     print('initState got called');
//     final nowDate = DateTime.now();
//     todayDate = DateFormat.EEEE().format(nowDate);
//     print('value of todayDate');
//     print(todayDate);
//   }

//   // In order to get hot reload to work we need to pause the camera if the platform
//   // is android, or resume the camera if the platform is iOS.
//   @override
//   void reassemble() {
//     super.reassemble();
//     if (Platform.isAndroid) {
//       controller!.pauseCamera();
//     } else if (Platform.isIOS) {
//       controller!.resumeCamera();
//     }
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }

//   bool isFlushOn = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // or put the flush on in app bar
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           await controller?.toggleFlash();
//           setState(() {
//             isFlushOn = !isFlushOn;
//           });
//         },
//         backgroundColor: Palette.blueAppBar,
//         child: Icon(isFlushOn ? Icons.flash_off : Icons.flash_on),
//       ),
//       body: _buildQrView(context),
//     );
//   }

//   Widget _buildQrView(BuildContext context) {
//     // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
//     var scanArea =
//         (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400)
//             ? 150.0
//             : 300.0;
//     // To ensure the Scanner view is properly sizes after rotation
//     // we need to listen for Flutter SizeChanged notification and update controller
//     return QRView(
//       key: qrKey,
//       onQRViewCreated: _onQRViewCreated,
//       overlay: QrScannerOverlayShape(
//           borderColor: Colors.red,
//           borderRadius: 8,
//           borderLength: 30,
//           borderWidth: 5,
//           cutOutSize: scanArea),
//       onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
//     );
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     setState(() {
//       this.controller = controller;
//     });
//     controller.scannedDataStream.listen((scanData) {
//       setState(() {
//         result = scanData;
//       });
//     });

//     print('value of result');
//     print('Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}');

//     // call _decisionRouter from here
//   }

//   void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
//     log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
//     if (!p) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('no Permission')),
//       );
//     }
//   }

//   /////////////////////---------

//   void _decisionRouter(int theApptId, BuildContext context) async {
//     final theBookedAppt = widget.bookedApptList
//         .firstWhere((element) => element.id == theApptId, orElse: () => BookedApptModel(id: 0));

//     if (theBookedAppt.id == 0) {
//       Navigator.of(context).pop({'error': true, 'message': 'Appt not available'});
//       return;
//     } else {
//       _apptId = theApptId;
//       if (theBookedAppt.weekDay != todayDate) {
//         questionDialogue(
//             context,
//             'This Appt is not from today. Do you really want to mark it as visited?',
//             'Not Today',
//             _markApptComplete);
//       } else {
//         _markApptComplete();
//       }
//     }
//   }

//   Future<void> _markApptComplete() async {
//     final progressObject = await progressDialogue(context: context);
//     await progressObject.show();

//     FormData body = FormData.fromMap({
//       'booked_appt_id': _apptId.toString(),
//     });
//     var scheduleResponse = await HttpService().postRequest(
//       data: body,
//       endPoint: BOOKED_APPT_LIST,
//     );

//     await progressObject.hide();

//     if (!scheduleResponse.error) {
//       Navigator.of(context).pop({'error': false, 'message': 'Marked as completed successfully'});
//       return;
//     } else {
//       Navigator.of(context).pop({'error': true, 'message': scheduleResponse.errorMessage});
//       return;
//     }
//   }
// }






// patient cart in appt

// // Card(
//                         margin: EdgeInsets.only(top: 5, bottom: 10),
//                         elevation: 3.0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20.0),
//                         ),
//                         child: Container(
//                           padding: EdgeInsets.all(8),
//                           width: widget.mQuery.width * 0.94,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(20.0),
//                             color: Colors.white,
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(5.0),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       'Booking Date - ${selectedBookedAppt[index].bookedAt}',
//                                       style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
//                                     ),
//                                     Text(
//                                       'Booked',
//                                       style: TextStyle(
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.w400,
//                                           color: Palette.darkGreen),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 3.0,
//                               ),
//                               dashedLine(Palette.lightGreen),
//                               SizedBox(
//                                 height: 3.0,
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     _userImage(selectedBookedAppt[index].avatar,
//                                         selectedBookedAppt[index].gender),
//                                     SizedBox(
//                                       width: 10.0,
//                                     ),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           AutoSizeText(
//                                             selectedBookedAppt[index].patientName ?? "Unknown Name",
//                                             maxLines: 1,
//                                             minFontSize: 16,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: TextStyle(
//                                                 fontSize: 18, fontWeight: FontWeight.w600),
//                                           ),
//                                           SizedBox(
//                                             height: 2.0,
//                                           ),
//                                           AutoSizeText(
//                                             'Duration: ${selectedBookedAppt[index].startApptTime!.substring(0, 5)} - ${selectedBookedAppt[index].endApptTime!.substring(0, 5)}',
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                             minFontSize: 14,
//                                             style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w400,
//                                                 color: Palette.darkGreen),
//                                           ),
//                                           SizedBox(
//                                             height: 2.0,
//                                           ),
//                                           AutoSizeText(
//                                             '${selectedBookedAppt[index].clinicName ?? "Unknown Clinic"}',
//                                             maxLines: 2,
//                                             overflow: TextOverflow.ellipsis,
//                                             minFontSize: 12,
//                                             style: TextStyle(
//                                                 fontSize: 15,
//                                                 fontWeight: FontWeight.w500,
//                                                 color: Colors.black87),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.only(right: 5.0),
//                                             child: Row(
//                                               mainAxisAlignment: MainAxisAlignment.end,
//                                               children: [
//                                                 ElevatedButton.icon(
//                                                     style: ElevatedButton.styleFrom(
//                                                         elevation: 5.0,
//                                                         primary: Palette.red,
//                                                         shape: RoundedRectangleBorder(
//                                                           borderRadius: BorderRadius.circular(15),
//                                                         )),
//                                                     onPressed: () {},
//                                                     icon: Icon(
//                                                       Icons.clear,
//                                                       size: 18,
//                                                     ),
//                                                     label: Text(
//                                                       'Cancel',
//                                                       style: TextStyle(
//                                                           fontSize: 13,
//                                                           fontWeight: FontWeight.w500),
//                                                     )),
//                                                 SizedBox(
//                                                   width: 10.0,
//                                                 ),
//                                                 ElevatedButton.icon(
//                                                     style: ElevatedButton.styleFrom(
//                                                         elevation: 5.0,
//                                                         primary: Palette.blueAppBar,
//                                                         shape: RoundedRectangleBorder(
//                                                           borderRadius: BorderRadius.circular(15),
//                                                         )),
                                                    // onPressed: () => _getPatientUserDetail(
                                                    //     selectedBookedAppt[index].patientId ?? 0,
                                                    //     context),
//                                                     icon: Icon(
//                                                       Icons.remove_red_eye,
//                                                       size: 18,
//                                                     ),
//                                                     label: Text(
//                                                       'View',
//                                                       style: TextStyle(
//                                                           fontSize: 13,
//                                                           fontWeight: FontWeight.w500),
//                                                     )),
//                                               ],
//                                             ),
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );


// Card(
                //   margin: EdgeInsets.only(top: 5, bottom: 10),
                //   elevation: 5.0,
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(20.0),
                //   ),
                //   child: Container(
                //     padding: EdgeInsets.all(8),
                //     width: mQuery.width * 0.94,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(20.0),
                //       color: Colors.white,
                //     ),
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.start,
                //       children: [
                //         Padding(
                //           padding: const EdgeInsets.all(5.0),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               Text(
                //                 'Booking Date - ${bookedApptList[index].bookedAt}',
                //                 style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                //               ),
                //               Text(
                //                 'Booked',
                //                 style: TextStyle(
                //                     fontSize: 15,
                //                     fontWeight: FontWeight.w400,
                //                     color: Palette.darkGreen),
                //               ),
                //             ],
                //           ),
                //         ),
                //         SizedBox(
                //           height: 3.0,
                //         ),
                //         dashedLine(Palette.lightGreen),
                //         SizedBox(
                //           height: 3.0,
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
                //           child: Row(
                //             crossAxisAlignment: CrossAxisAlignment.center,
                //             children: [
                //               _userImage(bookedApptList[index]),
                //               SizedBox(
                //                 width: 10.0,
                //               ),
                //               Expanded(
                //                 child: Column(
                //                   crossAxisAlignment: CrossAxisAlignment.start,
                //                   children: [
                //                     AutoSizeText(
                //                       bookedApptList[index].patientName ?? 'Unknown Patient',
                //                       maxLines: 1,
                //                       minFontSize: 16,
                //                       overflow: TextOverflow.ellipsis,
                //                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                //                     ),
                //                     SizedBox(
                //                       height: 2.0,
                //                     ),
                //                     AutoSizeText(
                //                       '${parsedDate != null ? calculateAge(DateTime.parse(parsedDate)) : "Unknown Age"} Years, ${bookedApptList[index].gender}',
                //                       maxLines: 1,
                //                       overflow: TextOverflow.ellipsis,
                //                       minFontSize: 14,
                //                       style: TextStyle(
                //                           fontSize: 15,
                //                           fontWeight: FontWeight.w400,
                //                           color: Palette.darkGreen),
                //                     ),
                //                     SizedBox(
                //                       height: 2.0,
                //                     ),
                //                     AutoSizeText(
                //                       'Slot: ${bookedApptList[index].startApptTime} - ${bookedApptList[index].endApptTime}',
                //                       maxLines: 1,
                //                       overflow: TextOverflow.ellipsis,
                //                       minFontSize: 14,
                //                       style: TextStyle(
                //                           fontSize: 16,
                //                           fontWeight: FontWeight.w400,
                //                           color: Palette.blueAppBar),
                //                     ),
                //                     SizedBox(
                //                       height: 2.0,
                //                     ),
                //                     Row(
                //                       mainAxisAlignment: MainAxisAlignment.start,
                //                       children: [
                //                         Card(
                //                           elevation: 8.0,
                //                           shape: RoundedRectangleBorder(
                //                               borderRadius: BorderRadius.circular(100)),
                //                           color: Palette.lighterBlue,
                //                           child: Container(
                //                             height: 30,
                //                             width: 30,
                //                             decoration: BoxDecoration(shape: BoxShape.circle),
                //                             child: Center(
                //                               child: Icon(
                //                                 Icons.phone_enabled,
                //                                 size: 22,
                //                                 color: Colors.blue[900],
                //                               ),
                //                             ),
                //                           ),
                //                         ),
                //                         Expanded(
                //                           child: AutoSizeText(
                //                             bookedApptList[index].phone ?? 'Phone Unavailable',
                //                             style: TextStyle(
                //                               fontSize: 17,
                //                               fontWeight: FontWeight.w500,
                //                             ),
                //                             maxLines: 1,
                //                             minFontSize: 15,
                //                             overflow: TextOverflow.ellipsis,
                //                           ),
                //                         )
                //                       ],
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(right: 8.0),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.end,
                //             children: [
                //               SizedBox(
                //                 width: 10.0,
                //               ),
                //               ElevatedButton.icon(
                //                   style: ElevatedButton.styleFrom(
                //                       elevation: 5.0,
                //                       primary: Palette.blueAppBar,
                //                       shape: RoundedRectangleBorder(
                //                         borderRadius: BorderRadius.circular(15),
                //                       )),
                //                   onPressed: () async {
                //                     _showMyDialog(context, bookedApptList[index].id.toString());
                //                   },
                //                   icon: Icon(Icons.qr_code),
                //                   label: Text(
                //                     'QR',
                //                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                //                   )),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // );

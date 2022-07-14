import 'package:dio/dio.dart';
import 'package:doctor_panel/providers/end_point.dart';
import 'package:doctor_panel/providers/provider_list.dart';
import 'package:doctor_panel/widgets/widgets.dart';
import 'package:flutter/material.dart';
import '../../utils/utils.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/model_list.dart';
import '../screens.dart';

class ClinicBookedApptList extends StatefulWidget {
  final List<BookedApptModel> bookedApptList;
  ClinicBookedApptList({required this.bookedApptList});

  @override
  _ClinicBookedApptListState createState() => _ClinicBookedApptListState();
}

class _ClinicBookedApptListState extends State<ClinicBookedApptList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: widget.bookedApptList.length <= 0
          ? PlaceHolder(
              title: 'No Booked Appt',
              body: 'Booked appts will be listed here',
            )
          : ListView.builder(
              padding: EdgeInsets.all(10.0),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: PageScrollPhysics(),
              itemCount: widget.bookedApptList.length,
              itemBuilder: (context, index) {
                // final parsedDate = bookedApptList[index].age;
                return BookedApptPatientTile(
                  bookedApptModel: widget.bookedApptList[index],
                  buttonWidget: _cancelQrButton(widget.bookedApptList[index], context),
                  isAppt: false,
                );
              },
            ),
    );
  }

  Row _cancelQrButton(BookedApptModel _bookedApptObject, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton.icon(
            style: TextButton.styleFrom(
              minimumSize: Size(140, 35),
            ),
            onPressed: () => questionDialogue(
                context,
                'Do you really want to cancel this appointment?',
                'Cancel Appointment',
                () => _cancelAppt(_bookedApptObject.id ?? 0, context)),
            icon: Icon(
              Icons.clear,
              color: Colors.red,
              size: 20,
            ),
            label: Text(
              'Cancel Appt',
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700, color: Colors.red),
            )),
        Text(
          '|',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        TextButton.icon(
            style: TextButton.styleFrom(
              minimumSize: Size(140, 35),
            ),
            onPressed: () => _showMyDialog(context, _bookedApptObject.id.toString()),
            icon: Icon(
              Icons.qr_code_rounded,
              size: 19,
              color: Colors.blue[900],
            ),
            label: Text(
              'Create QR',
              style:
                  TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700, color: Colors.blue[900]),
            )),
      ],
    );
  }

  void _cancelAppt(int _bookedId, BuildContext ctx) async {
    bool _isDialogRunning = false;
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) {
          _isDialogRunning = true;
          return const ProgressPopupDialog();
        });

    try {
      FormData body = FormData.fromMap({
        'booked_appt_id': _bookedId,
      });

      var awardResponse = await HttpService().postRequest(
        data: body,
        endPoint: BOOKED_APPT_LIST,
      );
      Navigator.of(ctx).pop();
      _isDialogRunning = false;

      if (!awardResponse.error) {
        setState(() {
          widget.bookedApptList.removeWhere((element) => element.id == _bookedId);
        });
        toastSnackBar('Appointment canceled successfully');
      } else {
        infoNoOkDialogue(
            context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    } catch (e) {
      _isDialogRunning ? Navigator.of(ctx).pop() : null;
      infoNoOkDialogue(
          context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS, GlobalVariable.ERROR_MESSAGE_TITLE);
    }
  }

  Future<void> _showMyDialog(BuildContext context, String qrText) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.only(top: 0),
          titlePadding: EdgeInsets.all(0),
          elevation: 8,
          // title: Text('AlertDialog Title'),
          children: [
            SingleChildScrollView(
                child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        icon: Icon(Icons.clear), onPressed: () => Navigator.of(context).pop())
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(right: 10, left: 10, bottom: 20),
                  height: 230.0,
                  width: 230,
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Palette.blueAppBar),
                    // color: Palette.imageBackground,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: QrImage(
                    padding: EdgeInsets.all(8),
                    data: qrText,
                    version: QrVersions.auto,
                    // size: 320,
                    gapless: false,
                  ),
                ),
              ],
            )),
          ],
        );
      },
    );
  }
}

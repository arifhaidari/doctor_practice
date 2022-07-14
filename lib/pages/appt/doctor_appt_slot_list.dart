import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:doctor_panel/models/model_list.dart';
import 'package:doctor_panel/pages/place_holder.dart';
import 'package:doctor_panel/providers/provider_list.dart';
import 'package:doctor_panel/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_switch/flutter_switch.dart';
import '../../utils/utils.dart';

class ClinicDayApptList extends StatefulWidget {
  final List<ApptModel> weekDayApptList;
  final ClinicBriefModel clinicObject;
  final String currentDay;

  const ClinicDayApptList(
      {Key? key,
      required this.weekDayApptList,
      required this.clinicObject,
      required this.currentDay})
      : super(key: key);
  @override
  _ClinicDayApptListState createState() => _ClinicDayApptListState();
}

class _ClinicDayApptListState extends State<ClinicDayApptList> {
  // bool status = false;
  @override
  Widget build(BuildContext context) {
    // final mQuery = MediaQuery.of(context).size;
    return widget.weekDayApptList.length == 0
        ? PlaceHolder(title: 'No Appt Available', body: 'Your time slot will be listed here')
        : SafeArea(
            top: false,
            child: StaggeredGridView.countBuilder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                padding: const EdgeInsets.all(8.0),
                staggeredTileBuilder: (index) => StaggeredTile.count(2, 1.2),
                crossAxisCount: Responsive.isMobile(context) ? 4 : 8,
                itemCount: widget.weekDayApptList.length,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                    elevation: 8.0,
                    child: Container(
                        height: 140,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: !widget.weekDayApptList[index].active
                              ? Colors.red
                              : (widget.weekDayApptList[index].status == 'Booked'
                                  ? Colors.brown
                                  : Palette.blueAppBar),
                        ),
                        child: Column(
                          children: [
                            _apptHeader(widget.weekDayApptList[index]),
                            SizedBox(
                              height: 3.0,
                            ),
                            dashedLine(Colors.white),
                            SizedBox(
                              height: 3.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _fromToText('From',
                                    widget.weekDayApptList[index].startApptTime ?? "Unknown"),
                                _fromToText(
                                    'To', widget.weekDayApptList[index].endApptTime ?? "Unknown"),
                              ],
                            )
                          ],
                        )),
                  );
                })
            // child: StandardGridView(),
            );
  }

  Row _apptHeader(ApptModel apptModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: AutoSizeText(
            !apptModel.active ? "Deactivated" : apptModel.status!,
            style: TextStyle(fontSize: 14, color: Colors.white),
            maxLines: 1,
            minFontSize: 12,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        FlutterSwitch(
          width: 48.0,
          height: 21.0,
          value: apptModel.active,
          onToggle: (val) {
            // call server for particualr appt to active or deactive
            if (apptModel.status == 'Booked' && apptModel.active) {
              questionDialogue(
                  context,
                  'This time slot is booked by a patient. If you deactive it, the appointment will be canceled!',
                  'Time Slot Deactivation', () {
                scheduleClinicAppt(
                  ctx: context,
                  apptModel: apptModel,
                );
              });
            } else {
              scheduleClinicAppt(
                ctx: context,
                apptModel: apptModel,
              );
            }
          },
        )
      ],
    );
  }

  Future<void> scheduleClinicAppt({required BuildContext ctx, required ApptModel apptModel}) async {
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
        'appt_id': apptModel.id,
        'clinic_id': widget.clinicObject.id,
        'week_day': widget.currentDay,
        'operation': 'toggle_slot',
      });

      var scheduleResponse = await HttpService().postRequest(
        data: body,
        endPoint: CLINIC_ALL_APPT,
      );

      Navigator.of(ctx).pop();
      _isDialogRunning = false;

      if (!scheduleResponse.error) {
        apptModel.active = !apptModel.active;
        setState(() {
          widget.weekDayApptList[widget.weekDayApptList
              .indexWhere((element) => element.id == apptModel.id)] = apptModel;
        });

        toastSnackBar('Scheduled Successfully');
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

  Column _fromToText(String title, String data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          title,
          style: TextStyle(fontSize: 16, color: Colors.white),
          maxLines: 1,
          minFontSize: 13,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(
          height: 4.0,
        ),
        Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
          ),
          child: AutoSizeText(
            data,
            style: TextStyle(fontSize: 16),
            maxLines: 1,
            minFontSize: 13,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

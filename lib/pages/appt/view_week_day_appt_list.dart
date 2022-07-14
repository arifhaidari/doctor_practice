import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:doctor_panel/models/model_list.dart';
import 'package:doctor_panel/providers/provider_list.dart';
import 'package:doctor_panel/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:path/path.dart';
import '../../utils/utils.dart';
import '../screens.dart';
// import '../../widgets/widgets.dart';

import '../../models/dummy_data.dart';

class WeekDayAppt extends StatefulWidget {
  const WeekDayAppt({
    Key? key,
    required this.clinicApptList,
    required this.mQuery,
    required this.dayPicker,
    required this.clinicObject,
  }) : super(key: key);

  final List<ApptModel> clinicApptList;
  final Size mQuery;
  final List<String> dayPicker;
  final ClinicBriefModel clinicObject;

  @override
  _WeekDayApptState createState() => _WeekDayApptState();
}

class _WeekDayApptState extends State<WeekDayAppt> {
  // while activating or deactiving a day, do it online and local as well in list clinicApptList
  //  and do not request from server the new data because it is expensive
  String currentDay = "Saturday";
  bool dayStatus = false;
  List<ApptModel> clinicApptFormatedList = <ApptModel>[];
  List<ApptModel> weekDayApptList = <ApptModel>[];

  @override
  void initState() {
    super.initState();
    clinicApptFormatedList = widget.clinicApptList;
    final todayDate = DateTime.now();
    final formatedDay = DateFormat.EEEE().format(todayDate);
    _selectTheList(formatedDay);
  }

  void _selectTheList(String selectedDay) {
    var apptModelSample = clinicApptFormatedList.firstWhere(
        (element) => element.dayPattern?.weekDay?.weekDay == selectedDay,
        orElse: () => ApptModel(dayPattern: DaySchedulePatternModel(active: false)));

    if (apptModelSample.dayPattern?.active == false) {
      setState(() {
        dayStatus = false;
        weekDayApptList = <ApptModel>[];
        currentDay = selectedDay;
      });
    } else {
      final theList = clinicApptFormatedList.length <= 0
          ? <ApptModel>[]
          : clinicApptFormatedList
              .where((element) => element.dayPattern?.weekDay?.weekDay == selectedDay)
              .toList();
      setState(() {
        dayStatus = true;
        weekDayApptList = theList;
        currentDay = selectedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Card(
          elevation: 8.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            padding: EdgeInsets.all(5),
            width: mQuery.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText(
                  widget.clinicObject.clinicName ?? "Unknown Clinic",
                  style: TextStyle(
                    fontSize: 17,
                    color: Palette.black,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 15,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: widget.dayPicker
                      .map(
                        (e) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [_selectedDay(e.toString())],
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () async {
                  // final finalResult =
                  await showAsBottomSheet(mQuery, currentDay, context, widget.clinicObject.id!);
                },
                icon: Icon(
                  Icons.hourglass_bottom,
                  color: Palette.blueAppBar,
                  size: 21,
                ),
                label: Text(
                  currentDay,
                  style: TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w600, color: Palette.blueAppBar),
                ),
              ),
              FlutterSwitch(
                width: 63.0,
                height: 25.0,
                activeColor: Palette.blueAppBar,
                value: dayStatus,
                showOnOff: true,
                onToggle: (val) {
                  questionDialogue(context, 'Do you really want to toggle this day?',
                      !val ? 'Deactivate Day' : 'Activate Day', () {
                    scheduleClinicAppt(
                        ctx: context,
                        clinicId: widget.clinicObject.id!,
                        weekDay: currentDay,
                        operation: 'toggle_day');
                  });
                },
              ),
            ],
          ),
        ),
        if (dayStatus)
          Expanded(
              child: ClinicDayApptList(
            weekDayApptList: weekDayApptList,
            clinicObject: widget.clinicObject,
            currentDay: currentDay,
          )),
        if (!dayStatus)
          Expanded(
              child: PlaceHolder(
            title: 'No Appt Scheduled',
            body:
                'There is no appointment scheduled for today. Active the day if you want schedule it for appointment',
          )),
      ],
    );
  }

  GestureDetector _selectedDay(String day) {
    return GestureDetector(
      onTap: () {
        _selectTheList(day);
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: day.toString() == currentDay
            ? BoxDecoration(color: Palette.blueAppBar, shape: BoxShape.circle)
            : null,
        child: AutoSizeText(
          GlobalDummyData.DAY_PICKER_ABBREVIATION[day]!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          minFontSize: 13,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: day.toString() == currentDay ? Colors.white : Colors.blue[900],
          ),
        ),
      ),
    );
  }

  Future<void> showAsBottomSheet(mQuery, String day, BuildContext ctx, int clinicId) async {
    showMaterialModalBottomSheet(
      context: context,
      bounce: true,
      isDismissible: true,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.horizontal(right: Radius.circular(10), left: Radius.circular(10))),

      // barrierColor: Colors.yellow.withOpacity(0.5),
      // expand: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalState) {
            return SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                // height: mQuery.height * 0.60,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10.0,
                      ),
                      height: 4,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2), color: Colors.black45),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Time Slot ($day)',
                            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                              icon: Icon(
                                CupertinoIcons.clear_circled_solid,
                                size: 30.0,
                              ),
                              onPressed: () => Navigator.of(context).pop()),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Palette.blueAppBar,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    slotTitle('Slot Duration', mQuery),
                    SizedBox(
                      height: 5.0,
                    ),
                    timeSlottingDropDown(modalState, mQuery, GlobalDummyData.timeInMins,
                        slotDurationDefault, 'duration'),
                    SizedBox(
                      height: 10.0,
                    ),
                    slotTitle('Start Time', mQuery),
                    SizedBox(
                      height: 5.0,
                    ),
                    timeSlottingDropDown(modalState, mQuery, GlobalDummyData.startEndDayTime,
                        startTimeDefault, 'start'),
                    SizedBox(
                      height: 10.0,
                    ),
                    slotTitle('End Time', mQuery),
                    SizedBox(
                      height: 5.0,
                    ),
                    timeSlottingDropDown(
                        modalState, mQuery, GlobalDummyData.startEndDayTime, endTimeDefault, 'end'),
                    SizedBox(
                      height: 20.0,
                    ),
                    if (errorMessage != '')
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(
                      height: 5,
                    ),
                    customElevatedButton(context, () async {
                      print('Save changes got pressed');
                      final isFormValid = formValidation(modalState);
                      await scheduleClinicAppt(
                          ctx: ctx,
                          clinicId: clinicId,
                          weekDay: day,
                          isFormValid: isFormValid,
                          operation: 'schedule_day');
                    }, 'Save Changes'),
                    SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> scheduleClinicAppt(
      {required BuildContext ctx,
      int? clinicId,
      String? weekDay,
      bool isFormValid = true,
      String? operation}) async {
    bool _isDialogRunning = false;

    //

    if (isFormValid) {
      FormData body = FormData.fromMap({
        'slot_start': operation == 'toggle_day' ? '' : startTimeDefault,
        'slot_end': operation == 'toggle_day' ? '' : endTimeDefault,
        'slot_duration': operation == 'toggle_day' ? '' : slotDurationDefault,
        'clinic_id': clinicId,
        'week_day': weekDay,
        'operation': operation,
      });

      if (operation != 'toggle_day') {
        showDialog(
            context: ctx,
            barrierDismissible: false,
            builder: (_) {
              _isDialogRunning = true;
              return const ProgressPopupDialog();
            });
      }

      var scheduleResponse = await HttpService().postRequest(
        data: body,
        endPoint: CLINIC_ALL_APPT,
      );

      if (!scheduleResponse.error) {
        // get the day in here as well

        try {
          List<ApptModel> tempApptList = <ApptModel>[];
          if (operation == 'toggle_day' && dayStatus) {
            print('this condtion is turr operation == && dayStatus');
            if (clinicApptFormatedList.length > 0) {
              setState(() {
                dayStatus = !dayStatus;
                clinicApptFormatedList
                    .removeWhere((element) => element.dayPattern?.weekDay?.weekDay == weekDay);
                weekDayApptList = <ApptModel>[];
              });
            }
          } else {
            Map<String, dynamic> _theMap = {
              'clinic_id': widget.clinicObject.id,
              'week_day': weekDay
            };
            final apptListResponse =
                await HttpService().getRequest(endPoint: CLINIC_ALL_APPT, queryMap: _theMap);
            if (operation != 'toggle_day') {
              _isDialogRunning ? Navigator.of(ctx).pop() : null;
              _isDialogRunning = false;
              Navigator.of(ctx).pop();
            }
            if (!apptListResponse.error) {
              try {
                if (apptListResponse.data is List && apptListResponse.data.length != 0) {
                  apptListResponse.data.forEach((appt) {
                    ApptModel bookedApptModel = ApptModel.fromJson(appt);
                    tempApptList.add(bookedApptModel);
                  });
                  if (tempApptList.length > 0) {
                    clinicApptFormatedList
                        .removeWhere((element) => element.dayPattern?.weekDay?.weekDay == weekDay);
                  }
                }
                setState(() {
                  weekDayApptList = tempApptList;
                  clinicApptFormatedList.addAll(tempApptList);
                  if (operation == 'schedule_day') {
                    dayStatus = true;
                  } else {
                    dayStatus = !dayStatus;
                  }
                });
              } catch (e) {
                if (operation != 'toggle_day') {
                  _isDialogRunning ? Navigator.of(ctx).pop() : null;
                  _isDialogRunning = false;
                  Navigator.of(ctx).pop();
                }
                infoNoOkDialogue(context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS,
                    GlobalVariable.ERROR_MESSAGE_TITLE);
              }
            } else {
              if (apptListResponse.errorMessage == NO_INTERNET_CONNECTION) {
                infoNoOkDialogue(context, GlobalVariable.INTERNET_ISSUE_CONTENT,
                    GlobalVariable.INTERNET_ISSUE_TITLE);
              } else {
                infoNoOkDialogue(
                    context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
              }
            }
          }
          toastSnackBar('Scheduled Successfully');
        } catch (e) {
          if (operation != 'toggle_day') {
            _isDialogRunning ? Navigator.of(ctx).pop() : null;
            _isDialogRunning = false;
            Navigator.of(ctx).pop();
          }
          infoNoOkDialogue(context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS,
              GlobalVariable.ERROR_MESSAGE_TITLE);
        }
      } else {
        if (operation != 'toggle_day') {
          _isDialogRunning ? Navigator.of(ctx).pop() : null;
          _isDialogRunning = false;
          Navigator.of(ctx).pop();
        }
        if (scheduleResponse.errorMessage == NO_INTERNET_CONNECTION) {
          infoNoOkDialogue(
              context, GlobalVariable.INTERNET_ISSUE_CONTENT, GlobalVariable.INTERNET_ISSUE_TITLE);
        } else {
          infoNoOkDialogue(
              context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
        }
      }

      //
    }
  }
}

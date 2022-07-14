import 'dart:io';

import 'package:dio/dio.dart';
import 'package:doctor_panel/models/model_list.dart';
import 'package:doctor_panel/widgets/widgets.dart';
import '../../providers/provider_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:path/path.dart';
import '../../utils/utils.dart';
import '../screens.dart';
// import '../../widgets/widgets.dart';
import '../../models/dummy_data.dart';

class ViewClinicAppt extends StatefulWidget {
  final ClinicBriefModel clinicObject;

  const ViewClinicAppt({Key? key, required this.clinicObject}) : super(key: key);
  @override
  _ViewClinicApptState createState() => _ViewClinicApptState();
}

class _ViewClinicApptState extends State<ViewClinicAppt> {
  List<ApptModel> _clinicApptList = <ApptModel>[];

  bool isRescheduled = false;
  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    setState(() {
      _isLoading = true;
    });
    //
    Map<String, dynamic> _theMap = {'clinic_id': widget.clinicObject.id};
    final _theClinicApptResponse =
        await HttpService().getRequest(endPoint: CLINIC_ALL_APPT, queryMap: _theMap);

    if (!_theClinicApptResponse.error) {
      try {
        setState(() {
          if (_theClinicApptResponse.data is List && _theClinicApptResponse.data.length != 0) {
            _theClinicApptResponse.data.forEach((appt) {
              ApptModel bookedApptModel = ApptModel.fromJson(appt);
              _clinicApptList.add(bookedApptModel);
            });
          }

          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _isUnknownError = true;
          _errorMessage = GlobalVariable.UNEXPECTED_ERROR;
        });
      }
    } else {
      infoNoOkDialogue(
          context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      setState(() {
        _isLoading = false;
        if (_theClinicApptResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _theClinicApptResponse.errorMessage!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Palette.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: Palette.blueAppBar,
          leading: IconButton(
            icon: Platform.isAndroid ? Icon(Icons.arrow_back) : Icon(Icons.arrow_back_ios),
            onPressed: () {
              Map<String, dynamic> _theMap = {};
              if (isRescheduled) {
                _theMap = {
                  'is_rescheduled': true,
                  'from': startTimeDefault,
                  'to': endTimeDefault,
                  'duration': slotDurationDefault,
                };
              } else {
                _theMap = {'is_rescheduled': false};
              }
              Navigator.of(context).pop(_theMap);
            },
          ),
          title: Text(
            widget.clinicObject.clinicName ?? "Unknown Clinic",
            style:
                TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.pending_actions),
              onPressed: () async {
                // check if there is already booked appt or not ... if there was then through a question dialgue to contitue
                await showAsBottomSheet(mQuery, context, widget.clinicObject.id!);
              },
            )
          ],
        ),
        body: SafeArea(
            top: false,
            child: Builder(
              builder: (BuildContext ctx) {
                if (_isLoading) {
                  return LoadingPlaceHolder();
                }
                if (_isUnknownError || _isConnectionError) {
                  if (_isConnectionError) {
                    return ErrorPlaceHolder(
                        isStartPage: true,
                        errorTitle: GlobalVariable.INTERNET_ISSUE_TITLE,
                        errorDetail: GlobalVariable.INTERNET_ISSUE_CONTENT);
                  } else {
                    return ErrorPlaceHolder(
                      isStartPage: true,
                      errorTitle: 'Unknown Error. Try again later',
                      errorDetail: _errorMessage,
                    );
                  }
                }
                return WeekDayAppt(
                  clinicApptList: _clinicApptList,
                  mQuery: mQuery,
                  dayPicker: GlobalDummyData.DAY_PICKER,
                  clinicObject: widget.clinicObject,
                );
              },
            )));
  }

  Future<void> showAsBottomSheet(mQuery, BuildContext ctx, int clinicId) async {
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
                            'Time Slot (All)',
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
                      await scheduleClinicAppt(ctx, modalState, clinicId);
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

  Future<void> scheduleClinicAppt(BuildContext ctx, StateSetter modalState, int clinicId) async {
    final isFormValid = formValidation(modalState);
    if (isFormValid) {
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
          'slot_start': startTimeDefault,
          'slot_end': endTimeDefault,
          'slot_duration': slotDurationDefault,
          'clinic_id': clinicId,
          'operation': 'schedule_all',
        });

        var scheduleResponse = await HttpService().postRequest(
          data: body,
          endPoint: CLINIC_ALL_APPT,
        );
        Navigator.of(ctx).pop();
        _isDialogRunning = false;
        Navigator.of(context).pop();

        if (!scheduleResponse.error && scheduleResponse.data['message'] == 'success') {
          _clinicApptList.clear();
          isRescheduled = true;
          _getData();
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
  }
}

///////////// public mehtods for both class ////////////////

String slotDurationDefault = '20';
String startTimeDefault = '05:00';
String endTimeDefault = '05:00';
String errorMessage = '';

bool formValidation(StateSetter modalState) {
  _theSetState('', modalState);
  int startApptTime = int.parse(startTimeDefault.substring(0, 2));
  int endApptTime = int.parse(endTimeDefault.substring(0, 2));

  if (startApptTime > endApptTime) {
    _theSetState('Start time should be less than end time', modalState);
    return false;
  }
  return true;
}

void _theSetState(String theMessage, StateSetter modalState) {
  modalState(() {
    errorMessage = theMessage;
  });
}

////////////////

Container timeSlottingDropDown(modalState, mQuery, timeList, defaultVal, flag) {
  return Container(
    width: mQuery.width * 0.80,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Palette.blueAppBar, width: 1.5),
    ),
    child: DropdownButton<String>(
      value: defaultVal,
      icon: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: Icon(
          Icons.keyboard_arrow_down_sharp,
          // color: Colors.white,
        ),
      ),
      iconSize: 28,
      // itemHeight: 80,
      isExpanded: true,
      elevation: 16,
      style: TextStyle(color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.w500),
      dropdownColor: Palette.imageBackground,
      underline: SizedBox.shrink(),
      onChanged: (String? newValue) {
        print('value of neValeu');
        print(newValue);
        modalState(() {
          if (flag == 'duration') {
            slotDurationDefault = newValue!;
          } else if (flag == 'start') {
            startTimeDefault = newValue!;
          } else {
            endTimeDefault = newValue!;
          }
        });
      },
      items: timeList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
            value: value,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                // value,
                flag == 'duration' ? "$value Mins" : value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // style: TextStyle(
                //   fontSize: 15,
                // ),
              ),
            ));
      }).toList(),
    ),
  );
}

Container slotTitle(String title, mQuery) {
  return Container(
    width: mQuery.width * 0.80,
    child: Text(
      title,
      textAlign: TextAlign.left,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ),
  );
}

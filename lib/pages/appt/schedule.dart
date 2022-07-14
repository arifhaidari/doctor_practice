import 'package:auto_size_text/auto_size_text.dart';
import 'package:doctor_panel/models/model_list.dart';
import 'package:doctor_panel/providers/end_point.dart';
import 'package:doctor_panel/providers/http_service.dart';
import 'package:doctor_panel/providers/provider_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../screens.dart';

class Schedule extends StatefulWidget {
  Schedule({Key? key}) : super(key: key);

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  final List<ClinicBriefModel> clinicBriefList = <ClinicBriefModel>[];

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
    final _scheduleResponse = await HttpService().getRequest(endPoint: CLINIC_BRIEF);

    if (!_scheduleResponse.error) {
      try {
        setState(() {
          if (_scheduleResponse.data is List && _scheduleResponse.data.length != 0) {
            _scheduleResponse.data.forEach((patient) {
              ClinicBriefModel _clinicObject = ClinicBriefModel.fromJson(patient);
              clinicBriefList.add(_clinicObject);
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
        if (_scheduleResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _scheduleResponse.errorMessage!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Palette.scaffoldBackground,
        appBar: myAppBar('Schedule', isAction: true, function: () {}),
        drawer: CustomDrawer(),
        body: Builder(
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
            return clinicBriefList.length == 0
                ? PlaceHolder(
                    title: 'No Clinic Available',
                    body: 'You are not create or selected any clinic yet')
                : ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: PageScrollPhysics(),
                    itemCount: clinicBriefList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.only(top: 5, bottom: 8),
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Container(
                          padding: EdgeInsets.only(top: 8, right: 8, left: 8),
                          width: mQuery.width * 0.94,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: AutoSizeText(
                                  clinicBriefList[index].clinicName ?? "Unknown Clinic",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  minFontSize: 15,
                                ),
                              ),
                              SizedBox(
                                height: 3.0,
                              ),
                              dashedLine(Palette.lightGreen),
                              SizedBox(
                                height: 3.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _columnWidget(
                                      'From: ${clinicBriefList[index].startDayTime ?? "N/A"}',
                                      'Duration: ${clinicBriefList[index].timeSlotDuration ?? "N/A"}'),
                                  Container(
                                    width: 0.8,
                                    height: 50,
                                    color: Palette.blueAppBar,
                                  ),
                                  _columnWidget('To: ${clinicBriefList[index].endDayTime ?? "N/A"}',
                                      'Booked Appts: ${clinicBriefList[index].totalBookedApptNo ?? "0"}'),
                                ],
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              dashedLine(Palette.blueAppBar),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton.icon(
                                      style: TextButton.styleFrom(
                                        minimumSize: Size(140, 35),
                                      ),
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ClinicBookedAppt(
                                                  clinicId: clinicBriefList[index].id ?? 0,
                                                  clinicName: clinicBriefList[index].clinicName ??
                                                      "Unknown Name"))),
                                      icon: Icon(
                                        CupertinoIcons.doc_circle,
                                        // Icons.report_outlined,
                                        color: Colors.green[900],
                                        size: 20,
                                      ),
                                      label: Text(
                                        'Report',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.green[900]),
                                      )),
                                  Text(
                                    '|',
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                  ),
                                  TextButton.icon(
                                      style: TextButton.styleFrom(
                                        minimumSize: Size(140, 35),
                                      ),
                                      onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ViewClinicAppt(
                                                        clinicObject: clinicBriefList[index],
                                                      ))).then((value) {
                                            print('the then is got called');
                                            if (value['is_rescheduled']) {
                                              print('the resechedule is true');
                                              setState(() {
                                                clinicBriefList[index].startDayTime =
                                                    '${value['from']}:00';
                                                clinicBriefList[index].endDayTime =
                                                    '${value['to']}:00';
                                                clinicBriefList[index].totalBookedApptNo = 0;
                                                clinicBriefList[index].timeSlotDuration =
                                                    '00:${value["duration"]}:00';
                                              });
                                            }
                                            // get the value and set it then
                                          }),
                                      icon: Icon(
                                        Icons.schedule,
                                        size: 19,
                                        color: Colors.blue[900],
                                      ),
                                      label: Text(
                                        'Schedule',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.blue[900]),
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
          },
        ));
  }

  Column _columnWidget(String str1, String str2) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            str1,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 1),
          width: 150,
          height: 0.5,
          color: Palette.blueAppBar,
          // child: dashedLine(Palette.blueAppBar),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            str2,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        )
      ],
    );
  }

  AutoSizeText bodyText(String text) {
    return AutoSizeText(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      minFontSize: 14,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        // color: Palette.darkGreen,
      ),
    );
  }
}

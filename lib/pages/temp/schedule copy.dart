import 'package:auto_size_text/auto_size_text.dart';
import 'package:doctor_panel/models/model_list.dart';
import 'package:doctor_panel/providers/end_point.dart';
import 'package:doctor_panel/providers/http_service.dart';
import 'package:doctor_panel/providers/provider_list.dart';
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
                        margin: EdgeInsets.only(top: 5, bottom: 10),
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          width: mQuery.width * 0.94,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  clinicBriefList[index].clinicName ?? "Unknown Clinic",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[900]),
                                ),
                              ),
                              SizedBox(
                                height: 3.0,
                              ),
                              dashedLine(Palette.lightGreen),
                              SizedBox(
                                height: 3.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 90,
                                      width: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15.0),
                                        image: DecorationImage(
                                            image: AssetImage('assets/icons/schedule1.png')),
                                        // color: Colors.transparent.withOpacity(0.3),
                                        // gradient: Palette.regularGradient,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Column(
                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            bodyText(
                                                'Slot Duration: ${clinicBriefList[index].timeSlotDuration ?? "N/A"}'),
                                            SizedBox(
                                              height: 3.0,
                                            ),
                                            bodyText(
                                                'Start Appt Time: ${clinicBriefList[index].startDayTime ?? "N/A"}'),
                                            SizedBox(
                                              height: 3.0,
                                            ),
                                            bodyText(
                                                'End Appt Time: ${clinicBriefList[index].endDayTime ?? "N/A"}'),
                                            SizedBox(
                                              height: 3.0,
                                            ),
                                            bodyText(
                                                'Total Booked Appts: ${clinicBriefList[index].totalBookedApptNo ?? "0"}'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 5.0,
                                            primary: Palette.blueAppBar,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
                                            )),
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ClinicBookedAppt(
                                                    clinicId: clinicBriefList[index].id ?? 0,
                                                    clinicName: clinicBriefList[index].clinicName ??
                                                        "Unknown Name"))),
                                        icon: Icon(Icons.report_outlined),
                                        label: Text(
                                          'Report',
                                          style:
                                              TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                        )),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 5.0,
                                            primary: Palette.blueAppBar,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
                                            )),
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ViewClinicAppt(
                                                      clinicObject: clinicBriefList[index],
                                                    ))),
                                        icon: Icon(Icons.schedule),
                                        label: Text(
                                          'Schedule',
                                          style:
                                              TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                        )),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
          },
        ));
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

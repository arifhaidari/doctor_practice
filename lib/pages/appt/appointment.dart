import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:doctor_panel/models/dummy_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../providers/provider_list.dart';
import '../../widgets/widgets.dart';
import '../../utils/utils.dart';
import '../../models/model_list.dart';
import '../screens.dart';

class Appointment extends StatefulWidget {
  @override
  _AppointmentState createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;
  bool _isNewNote = false;
  String _errorMessage = '';
  String currentDay = "Saturday";

  List<BookedApptModel> bookedApptList = <BookedApptModel>[];

  @override
  void initState() {
    super.initState();
    final todayDate = DateTime.now();
    final formatedDay = DateFormat.EEEE().format(todayDate);
    currentDay = formatedDay;
    _getData(formatedDay);
  }

  Future<void> _getData(String theDay) async {
    // get user cellphone
    setState(() {
      _isLoading = true;

      SharedPref().dashboardBrief().then((value) => _isNewNote = value['is_unseen_note']);
    });

    Map<String, dynamic> _theMap = {
      'is_only_clinic': 'no',
      'day': theDay,
    };
    //
    final _apptResponse =
        await HttpService().getRequest(endPoint: BOOKED_APPT_LIST, queryMap: _theMap);

    if (!_apptResponse.error) {
      try {
        setState(() {
          bookedApptList.clear();
          if (_apptResponse.data is List && _apptResponse.data.length != 0) {
            _apptResponse.data.forEach((appt) {
              BookedApptModel bookedApptModel = BookedApptModel.fromJson(appt);
              bookedApptList.add(bookedApptModel);
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
        if (_apptResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _apptResponse.errorMessage!;
        }
      });
    }
    print('value of bookedApptList length');
    print(bookedApptList.length);
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Palette.scaffoldBackground,
        appBar: AppBar(
          title: Text(
            'Appointments',
            style:
                TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Palette.blueAppBar,
          actions: [
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: _isNewNote ? Colors.red[900] : Colors.white,
              ),
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => NotificationView())),
            ),
          ],
        ),
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5.0,
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
                          'ALL CLINICS',
                          style: TextStyle(
                            fontSize: 17,
                            color: Palette.black,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          minFontSize: 16,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: GlobalDummyData.DAY_DATE_PICKER
                              .map(
                                (e) => _selectedDay(e[0].toString(), e[1].toString()),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: bookedApptList.length <= 0
                      ? PlaceHolder(
                          title: 'No Booked Appt',
                          body: 'Booked appts will be listed here',
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(10.0),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: PageScrollPhysics(),
                          itemCount: bookedApptList.length,
                          itemBuilder: (context, index) {
                            return BookedApptPatientTile(
                                bookedApptModel: bookedApptList[index],
                                buttonWidget: _cancelViewButton(bookedApptList[index], context));
                          },
                        ),
                )
              ],
            );
          },
        ));
  }

  Row _cancelViewButton(BookedApptModel _bookedApptObject, context) {
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
            onPressed: () => getPatientUserDetail(_bookedApptObject.patientId ?? 0, context),
            icon: Icon(
              Icons.person_outline,
              size: 19,
              color: Colors.blue[900],
            ),
            label: Text(
              'View Profile',
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
          bookedApptList.removeWhere((element) => element.id == _bookedId);
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

  Expanded _selectedDay(String day, String date) {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: () {
            print('yo they tap here');
            _getData(day);
            currentDay = day;
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: day.toString() == currentDay
                ? BoxDecoration(color: Palette.blueAppBar, shape: BoxShape.circle)
                : null,
            child: AutoSizeText(
              GlobalDummyData.daysOfWeek[day].toString(),
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
        ),
      ),
    );
  }
}

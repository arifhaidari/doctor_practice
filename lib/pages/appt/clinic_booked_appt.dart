import 'package:doctor_panel/providers/provider_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/utils.dart';
import '../../controller/controller_page.dart';
import '../screens.dart';
import '../../models/model_list.dart';

class ClinicBookedAppt extends StatefulWidget {
  final int clinicId;
  final String clinicName;
  ClinicBookedAppt({Key? key, required this.clinicId, required this.clinicName}) : super(key: key);

  @override
  _ClinicBookedApptState createState() => _ClinicBookedApptState();
}

class _ClinicBookedApptState extends State<ClinicBookedAppt> {
  final List<BookedApptModel> bookedApptList = <BookedApptModel>[];

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

    Map<String, dynamic> _theMap = {
      'is_only_clinic': 'yes',
      'clinic_id': widget.clinicId,
    };
    //
    final _clinicApptResponse = await HttpService().getRequest(
      endPoint: BOOKED_APPT_LIST,
    );

    if (!_clinicApptResponse.error) {
      try {
        setState(() {
          if (_clinicApptResponse.data is List && _clinicApptResponse.data.length != 0) {
            _clinicApptResponse.data.forEach((patient) {
              BookedApptModel bookedAppt = BookedApptModel.fromJson(patient);
              bookedApptList.add(bookedAppt);
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
        if (_clinicApptResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _clinicApptResponse.errorMessage!;
        }
      });
    }
  }

  PopupMenuButton _apptDropdown() {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        if (bookedApptList.length != 0) {
          if (result == 'today') {
            List<BookedApptModel> todayBookedAppt = <BookedApptModel>[];
            final todayDate = DateTime.now();
            final formatedDay = DateFormat.EEEE().format(todayDate);
            todayBookedAppt =
                bookedApptList.where((element) => element.weekDay == formatedDay).toList();
            if (todayBookedAppt.length != 0) {
              ExportApptPdf.generate(bookedApptList, 'today');
            } else {
              toastSnackBar('No Appt Available For Today', lenghtShort: false);
            }
          } else {
            ExportApptPdf.generate(bookedApptList, 'week');
          }
        } else {
          toastSnackBar('No Appt Available For Whole Week', lenghtShort: false);
        }
      },
      icon: Icon(Icons.pending_actions),
      color: Palette.imageBackground,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'today',
          child: Text('Today'),
        ),
        const PopupMenuItem<String>(
          value: 'week',
          child: Text('Week'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Palette.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Today\'s Appt',
          style:
              TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Palette.blueAppBar,
        actions: [_apptDropdown()],
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 5.0,
                  ),
                  Container(
                    width: mQuery.width * 0.98,
                    height: 90,
                    // color: Colors.white,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.white),
                    child: Row(
                      children: [
                        SizedBox(width: 10.0),
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          elevation: 8,
                          child: Container(
                            height: 70.0,
                            width: 70.0,
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Icon(
                              Icons.pending_actions,
                              color: Palette.blueAppBar,
                              size: 50,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.clinicName,
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              '${bookedApptList.length} Patients',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Palette.imageBackground),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  ClinicBookedApptList(bookedApptList: bookedApptList),
                ],
              );
            },
          )),
    );
  }
}

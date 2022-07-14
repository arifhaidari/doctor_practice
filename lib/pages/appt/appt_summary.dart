import 'package:doctor_panel/providers/provider_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../models/model_list.dart';
import '../../utils/utils.dart';
import '../screens.dart';

class ApptSummary extends StatefulWidget {
  final int apptId;
  const ApptSummary({
    Key? key,
    required this.apptId,
  }) : super(key: key);

  @override
  _ApptSummaryState createState() => _ApptSummaryState();
}

class _ApptSummaryState extends State<ApptSummary> {
  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;
  String _errorMessage = '';

  late ApptModel _apptModel;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    // get user cellphone
    setState(() {
      _isLoading = true;
    });
    //
    final _apptResponse =
        await HttpService().getRequest(endPoint: APPT_DETAIL_PLUS + '${widget.apptId}/');

    if (!_apptResponse.error) {
      try {
        setState(() {
          _apptModel = ApptModel.fromJson(_apptResponse.data);
          print('value fo the new fieldls ');
          print(_apptModel.feedback);
          print(_apptModel.review);
          print(_apptModel.review.runtimeType);
          _isLoading = false;
        });
      } catch (e) {
        print('value fo errorrroorr');
        print(e);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Appointment Summary',
            style:
                TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Palette.blueAppBar,
        ),
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
                  errorTitle: GlobalVariable.UNKNOWN_ERROR,
                  errorDetail: _errorMessage,
                );
              }
            }
            return _apptModel == null
                ? ErrorPlaceHolder(
                    isStartPage: true,
                    errorTitle: GlobalVariable.UNKNOWN_ERROR,
                    errorDetail: GlobalVariable.UNEXPECTED_ERROR,
                  )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: Column(
                            children: [
                              cardDetailItem('Clinic: ${_apptModel.clinic!.clinicName}',
                                  MdiIcons.hospitalBuilding),
                              cardDetailItem(
                                  'Slot: ${_apptModel.startApptTime} - ${_apptModel.endApptTime}',
                                  Icons.date_range),
                              cardDetailItem(
                                  'Day: ${_apptModel.dayPattern == null ? "Unknown" : _apptModel.dayPattern!.weekDay!.weekDay}',
                                  MdiIcons.viewWeekOutline),
                              cardDetailItem('Date: ${_apptModel.apptDate}', MdiIcons.calendar),
                              cardDetailItem('Status: ${_apptModel.status}',
                                  _apptModel.status == 'Completed' ? Icons.done_all : Icons.done),
                              if (_apptModel.status == 'Completed')
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star_border_outlined,
                                          size: 22.0,
                                          color: Colors.blue[900],
                                        ),
                                        SizedBox(
                                          width: 3.0,
                                        ),
                                        RatingBarIndicator(
                                          rating: _apptModel.feedback ?? 3.5,
                                          itemBuilder: (context, index) => Icon(
                                            Icons.star,
                                            color: Colors.amberAccent,
                                          ),
                                          itemCount: 5,
                                          itemSize: 20.0,
                                          unratedColor: Colors.blue[500],
                                          direction: Axis.horizontal,
                                        ),
                                      ],
                                    ),
                                    cardDetailItem(
                                        _apptModel.conditionTreated != null
                                            ? 'Condition Treated: ${_apptModel.conditionTreated!.map((e) => e.name).toList().join(",")}'
                                            : "No Conditin Treated Entered",
                                        MdiIcons.bedOutline,
                                        maxLine: 4),
                                    cardDetailItem(
                                        'Remarks: ${_apptModel.remark == null ? "Remark Is Not Entered By Doctor" : _apptModel.remark}',
                                        CupertinoIcons.signature,
                                        maxLine: 15),
                                    cardDetailItem(
                                        'Review: ${_apptModel.review == null ? "No Review Has Been Given" : _apptModel.review}',
                                        Icons.rate_review_outlined,
                                        maxLine: 15),
                                  ],
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
          },
        ));
  }
}

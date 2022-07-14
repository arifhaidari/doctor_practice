import 'package:auto_size_text/auto_size_text.dart';
import 'package:doctor_panel/models/model_list.dart';
import 'package:doctor_panel/pages/place_holder.dart';
import 'package:doctor_panel/providers/provider_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../../utils/utils.dart';
import '../screens.dart';

class PatientApptSlot extends StatefulWidget {
  final int patientId;

  const PatientApptSlot({Key? key, required this.patientId}) : super(key: key);
  @override
  _PatientApptSlotState createState() => _PatientApptSlotState();
}

class _PatientApptSlotState extends State<PatientApptSlot> {
  // bool status = false;
  List<ApptModel> _apptModelList = <ApptModel>[];

  bool _isUnknownError = false;
  bool _isConnectionError = false;
  String _errorMessage = '';

  final _scrollController = ScrollController();
  String _nextPage = '';
  String _sortingKey = 'All';
  int _itemCount = 0;

  @override
  void initState() {
    super.initState();
    _getCompletedBookedAppt(_sortingKey);
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent == _scrollController.offset) {
        _itemCount <= _apptModelList.length
            ? toastSnackBar(GlobalVariable.NO_MORE_ITEM)
            : _getCompletedBookedAppt(_sortingKey, nextPage: true);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _getCompletedBookedAppt(String query, {bool nextPage = false}) async {
    List<ApptModel> _tempApptList = <ApptModel>[];
    _sortingKey = query;
    Map<String, dynamic> theQueryParam = {
      'user_id': widget.patientId,
      'query': query,
    };

    var apptResponse = await HttpService().getRequest(
        endPoint: (nextPage && _nextPage != '') ? _nextPage : PATIENT_BOOKED_COMPLETED_APPT,
        queryMap: theQueryParam);

    if (!apptResponse.error) {
      try {
        setState(() {
          if (apptResponse.data['results'] is List && apptResponse.data['results'].length != 0) {
            _itemCount = apptResponse.data['count'];
            _nextPage = apptResponse.data['next'] ?? '';
            // then clear the existing list
            apptResponse.data['results'].forEach((response) {
              final _apptModel = ApptModel.fromJson(response);
              _tempApptList.add(_apptModel);
            });
          }
          if (!nextPage) {
            _apptModelList.clear();
            _apptModelList.addAll(_tempApptList);
          } else {
            _apptModelList.addAll(_tempApptList);
          }
        });
      } catch (e) {
        setState(() {
          _isUnknownError = true;
          _errorMessage = GlobalVariable.UNEXPECTED_ERROR;
        });
      }
    } else {
      infoNoOkDialogue(
          context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      setState(() {
        if (apptResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = apptResponse.errorMessage!;
        }
      });
    }
  }

  // DateTime _pickedDate = DateTime.now();

  Future<void> _datePickerSorter() async {
    final initialDate = DateTime.now();
    final newDate = await showMonthPicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5, 5),
      lastDate: DateTime(DateTime.now().year + 5, 9),
      initialDate: initialDate,
      // locale: Locale("es"),
    );

    if (newDate == null) return;
    print('value of newDate');
    print(newDate);
    _getCompletedBookedAppt(newDate.toString());
    // add a date to sort
    // setState(() {
    //   _pickedDate = newDate;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Palette.blueAppBar,
        onPressed: () => _datePickerSorter(),
        child: Icon(
          Icons.date_range,
          size: 30,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _getCompletedBookedAppt(_sortingKey);
        },
        child: SafeArea(
            top: false,
            child: Builder(
              builder: (BuildContext ctx) {
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
                return _apptModelList.length == 0
                    ? PlaceHolder(
                        title: 'No Appt Available',
                        body: 'Completed appts will be listed here',
                      )
                    : StaggeredGridView.countBuilder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        physics: ScrollPhysics(),
                        padding: const EdgeInsets.all(8.0),
                        staggeredTileBuilder: (index) => StaggeredTile.count(2, 1.2),
                        crossAxisCount: Responsive.isMobile(context) ? 4 : 8,
                        itemCount: _apptModelList.length,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        itemBuilder: (context, index) {
                          print('value of _itemCount <= _apptModelList.length');
                          print(_itemCount);
                          print(_apptModelList.length);
                          return GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ApptSummary(apptId: _apptModelList[index].id ?? 0))),
                            child: Card(
                              shape:
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                              elevation: 8.0,
                              child: Container(
                                  height: 140,
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: _apptModelList[index].status == 'Booked'
                                        ? Colors.brown
                                        : Palette.blueAppBar,
                                  ),
                                  child: Column(
                                    children: [
                                      _apptHeader(
                                        date: _apptModelList[index].apptDate ?? 'Unknown Date',
                                        status: _apptModelList[index].status ?? 'Unknow State',
                                      ),
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
                                          Expanded(
                                              child: _fromToText(
                                                  'From',
                                                  _apptModelList[index].startApptTime ??
                                                      'Uknown Time')),
                                          Expanded(
                                              child: _fromToText(
                                                  'To',
                                                  _apptModelList[index].endApptTime ??
                                                      'Uknown Time')),
                                        ],
                                      )
                                    ],
                                  )),
                            ),
                          );
                        });
              },
            )
            // child: StandardGridView(),
            ),
      ),
    );
  }

  Row _apptHeader({
    String status = 'Completed',
    String date = 'Monday',
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: AutoSizeText(
            status,
            style: TextStyle(fontSize: 14, color: Colors.white),
            maxLines: 1,
            minFontSize: 12,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: AutoSizeText(
            date,
            style: TextStyle(fontSize: 14, color: Colors.white),
            maxLines: 1,
            minFontSize: 12,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
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

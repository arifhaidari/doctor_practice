import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:dio/dio.dart';
import 'package:doctor_panel/models/model_list.dart';
import 'package:doctor_panel/providers/provider_list.dart';
import 'package:doctor_panel/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/utils.dart';
import '../screens.dart';

class AwardSetting extends StatefulWidget {
  final bool isProfessionalProfileCompleted;

  const AwardSetting({Key? key, required this.isProfessionalProfileCompleted}) : super(key: key);
  @override
  _AwardSettingState createState() => _AwardSettingState();
}

class _AwardSettingState extends State<AwardSetting> {
  final _formKey = GlobalKey<FormState>();
  final _awardController = TextEditingController();
  final _rtlAwardController = TextEditingController();
  final _awardDateController = TextEditingController();

  final _dateTimeFormat = DateFormat("yyyy-MM-dd");
  bool _isUpdate = false;

  int _awardId = 0;

  List<AwardModel> awardList = <AwardModel>[];

  String _errorMessage = '';

  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;

  bool _isEditorExpanded = false;

  void _theSetState(String theMessage) {
    _errorMessage = theMessage;
  }

  @override
  void initState() {
    super.initState();
    _getAwardSetting();
  }

  void _getAwardSetting() async {
    setState(() {
      _isLoading = true;
    });
    var awardObject = await HttpService().getRequest(endPoint: AWARD_GET_POST);

    if (!awardObject.error) {
      try {
        setState(() {
          if (awardObject.data is List && awardObject.data.length != 0) {
            awardObject.data.forEach((response) {
              final theObject = AwardModel.fromJson(response);
              awardList.add(theObject);
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
        if (awardObject.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = awardObject.errorMessage!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return SafeArea(
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
                    errorTitle: 'Internet Connection Issue',
                    errorDetail: 'Check your internet connection and try again');
              } else {
                return ErrorPlaceHolder(
                  isStartPage: true,
                  errorTitle: 'Unknown Error. Try again later',
                  errorDetail: _errorMessage,
                );
              }
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    margin: EdgeInsets.only(top: 10),
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      width: mQuery.width * 0.90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.white,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (awardList.isNotEmpty)
                              Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 15),
                                    width: mQuery.width * 0.75,
                                    child: Text('My Award(s)',
                                        textAlign: TextAlign.center,
                                        style:
                                            TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    width: mQuery.width * 0.72,
                                    child: Wrap(
                                      spacing: 8.0,
                                      runSpacing: 5.0,
                                      children: [
                                        ...awardList.map(
                                          (e) => InputChip(
                                            label: Text(e.awardName!),
                                            labelStyle: TextStyle(
                                              color: Colors.white,
                                            ),
                                            elevation: 5.0,
                                            deleteIconColor: Colors.white,
                                            onPressed: () {
                                              _addRemoveAwardData(e, 'update');
                                            },
                                            // avatar: Icon(Icons.local_hospital),
                                            backgroundColor: Palette.blueAppBar,
                                            onDeleted: () {
                                              if (!widget.isProfessionalProfileCompleted)
                                                questionDialogue(
                                                    context,
                                                    'Do you really want to delete this award?',
                                                    'Remove Award', () {
                                                  setState(() {
                                                    awardList.remove(e);
                                                  });
                                                });
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            if (awardList.isEmpty && !widget.isProfessionalProfileCompleted)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: mQuery.width * 0.72,
                                child: Center(
                                  child: Text(
                                    'No Award has been added.\nClick the + button to add',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            if (awardList.isEmpty && widget.isProfessionalProfileCompleted)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: mQuery.width * 0.72,
                                child: Center(
                                  child: Text(
                                    'Note: You are not added any award to your practice info. If you wish to add award then chagne the state of your profile on review and add award and re-submit your profile for approval',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                              ),
                            if (_isEditorExpanded)
                              Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 15),
                                    width: mQuery.width * 0.74,
                                    child: dashedLine(Palette.blueAppBar),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 15),
                                    width: mQuery.width * 0.75,
                                    child: Text('Add New Award',
                                        textAlign: TextAlign.center,
                                        style:
                                            TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 15),
                                    width: mQuery.width * 0.75,
                                    height: 50.0,
                                    child: TextFormField(
                                      enabled: widget.isProfessionalProfileCompleted ? false : true,
                                      controller: _awardController,
                                      decoration: textFieldDesign(context, 'Award'),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 15),
                                    width: mQuery.width * 0.75,
                                    height: 50.0,
                                    child: TextFormField(
                                      enabled: widget.isProfessionalProfileCompleted ? false : true,
                                      controller: _rtlAwardController,
                                      decoration: textFieldDesign(context, 'Award (Farsi/Pashto)'),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 15),
                                    width: mQuery.width * 0.75,
                                    height: 50.0,
                                    child: DateTimeField(
                                      enabled: widget.isProfessionalProfileCompleted ? false : true,
                                      format: _dateTimeFormat,
                                      controller: _awardDateController,
                                      decoration: textFieldDesign(context, 'End Date'),
                                      onShowPicker: (context, currentValue) {
                                        return showDatePicker(
                                          context: context,
                                          initialDate: currentValue ?? DateTime.now(),
                                          firstDate: DateTime(DateTime.now().year - 30, 6),
                                          lastDate: DateTime(DateTime.now().year + 5, 6),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              width: mQuery.width * 0.74,
                              child: dashedLine(Palette.blueAppBar),
                            ),
                            if (!widget.isProfessionalProfileCompleted)
                              Container(
                                width: mQuery.width * 0.75,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                        icon: Icon(
                                          _isEditorExpanded
                                              ? CupertinoIcons.minus_circle_fill
                                              : CupertinoIcons.add_circled_solid,
                                          size: 40.0,
                                          color:
                                              _isEditorExpanded ? Palette.red : Palette.blueAppBar,
                                        ),
                                        onPressed: () {
                                          _addRemoveAwardData(null, 'add');
                                        })
                                  ],
                                ),
                              ),
                            if (_errorMessage != '')
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                width: mQuery.width * 0.90,
                                padding: EdgeInsets.symmetric(horizontal: 25),
                                child: Text(
                                  _errorMessage,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            SizedBox(
                              height: 15,
                            ),
                            if (!widget.isProfessionalProfileCompleted)
                              customElevatedButton(context, () {
                                _saveUpdateAward(context);
                              }, 'Save'),
                            SizedBox(
                              height: 8.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            );
          },
        ));
  }

  Future<void> _saveUpdateAward(BuildContext ctx) async {
    final isFormValid = _formValidation();
    if (!isFormValid) {
      return;
    }
    bool _isDialogRunning = false;

    List<int> awardIdList = [];

    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) {
          _isDialogRunning = true;
          return const ProgressPopupDialog();
        });

    try {
      awardList.forEach((element) => awardIdList.add(element.id!));

      final Map<String, dynamic> fieldData = {
        'award_id': _isUpdate ? _awardId : '',
        'award_name': _awardController.text,
        'rtl_award_name': _rtlAwardController.text,
        'award_year': _awardDateController.text,
      };

      FormData body = FormData.fromMap({
        'award_list_id': awardIdList,
        'is_editor_expanded': _isEditorExpanded,
        'award_field_data': _isEditorExpanded ? fieldData : '',
      });
      var awardResponse = await HttpService().postRequest(
        data: body,
        endPoint: AWARD_GET_POST,
      );

      Navigator.of(ctx).pop();
      _isDialogRunning = false;

      if (!awardResponse.error) {
        final newOrUpdateObject = AwardModel(
          id: awardResponse.data['new_award_id'] ?? 0,
          awardName: _awardController.text,
          rtlAwardName: _rtlAwardController.text,
          awardYear: _awardDateController.text,
        );
        print(awardResponse.data['new_award_id']);
        setState(() {
          if (!_isUpdate) {
            // get the new created id and add it along with the object
            awardList.add(newOrUpdateObject);
          } else {
            awardList[awardList.indexWhere((element) => element.id == _awardId)] =
                newOrUpdateObject;
          }
        });
        toastSnackBar('Saved Successfully');
        if (!_isUpdate) {
          _addRemoveAwardData(null, 'success');
        }
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

  void _addRemoveAwardData(AwardModel? awardModel, String operation) {
    setState(() {
      if (operation == 'update') {
        _isUpdate = true;
        _isEditorExpanded = true;
        _awardId = awardModel!.id ?? 0;
        _awardController.text = awardModel.awardName!;
        _rtlAwardController.text = awardModel.rtlAwardName!;
        _awardDateController.text = awardModel.awardYear!;
      } else {
        _isUpdate = false;
        _isEditorExpanded = operation == 'success' ? false : !_isEditorExpanded;
        _awardController.clear();
        _rtlAwardController.clear();
        _awardDateController.clear();
      }
    });
  }

  bool _formValidation() {
    if (!_isEditorExpanded) {
      if (awardList.length == 0) {
        _theSetState('There is no experience in your list');
        return false;
      }
      return true;
    }
    _theSetState('');
    if (_awardController.text.trim() == '') {
      _theSetState('Please enter award name');
      return false;
    }

    if (_rtlAwardController.text.trim() == '') {
      _theSetState('Please enter award name (Dari/Farsi)');
      return false;
    }

    if (_awardDateController.text.trim() == '') {
      _theSetState('Please enter award date');
      return false;
    }
    final awardYear = DateTime.tryParse(_awardDateController.text);
    final todayDate = DateTime.now();

    if (awardYear!.isAfter(todayDate)) {
      _theSetState('Award date should not be in the future');
      return false;
    }
    return true;
  }
}

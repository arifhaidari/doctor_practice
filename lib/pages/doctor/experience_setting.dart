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

class ExperienceSetting extends StatefulWidget {
  final bool isProfessionalProfileCompleted;

  const ExperienceSetting({Key? key, required this.isProfessionalProfileCompleted})
      : super(key: key);
  @override
  _ExperienceSettingState createState() => _ExperienceSettingState();
}

class _ExperienceSettingState extends State<ExperienceSetting> {
  final _formKey = GlobalKey<FormState>();

  final _hospitalController = TextEditingController();
  final _rtlHospitalController = TextEditingController();
  final _designationController = TextEditingController();
  final _rtlDesignationController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _dateTimeFormat = DateFormat("yyyy-MM-dd");

  String _errorMessage = '';

  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;

  bool _isEditorExpanded = false;
  bool _isUpdate = false;

  int _experienceId = 0;

  List<ExperienceModel> experienceList = <ExperienceModel>[];

  @override
  void initState() {
    super.initState();
    _getEducationSubs();
  }

  void _getEducationSubs() async {
    setState(() {
      _isLoading = true;
    });
    var experienceObejctList = await HttpService().getRequest(endPoint: EXPERIENCE_LIST);

    if (!experienceObejctList.error) {
      try {
        setState(() {
          if (experienceObejctList.data is List && experienceObejctList.data.length != 0) {
            // Experience
            experienceObejctList.data.forEach((response) {
              final theObject = ExperienceModel.fromJson(response);
              experienceList.add(theObject);
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
        if (experienceObejctList.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = experienceObejctList.errorMessage!;
        }
      });
    }
  }

  void _theSetState(String theMessage) {
    _errorMessage = theMessage;
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
                            if (experienceList.isNotEmpty)
                              Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 15),
                                    width: mQuery.width * 0.75,
                                    child: Text('My Added Experience(s)',
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
                                        ...experienceList.map(
                                          (e) => InputChip(
                                            label: Text(e.designation!),
                                            labelStyle: TextStyle(
                                              color: Colors.white,
                                            ),
                                            elevation: 5.0,
                                            deleteIconColor: Colors.white,
                                            onPressed: () {
                                              _addRemoveExperienceData(e, 'update');
                                            },
                                            // avatar: Icon(Icons.local_hospital),
                                            backgroundColor: Palette.blueAppBar,
                                            onDeleted: () {
                                              if (!widget.isProfessionalProfileCompleted)
                                                questionDialogue(
                                                    context,
                                                    'Do you really want to delete this experience?',
                                                    'Remove Experience', () {
                                                  setState(() {
                                                    experienceList.remove(e);
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
                            if (experienceList.isEmpty && !widget.isProfessionalProfileCompleted)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: mQuery.width * 0.72,
                                child: Center(
                                  child: Text(
                                    'No Experience has been added.\nClick the + button to add',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            if (experienceList.isEmpty && widget.isProfessionalProfileCompleted)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: mQuery.width * 0.72,
                                child: Center(
                                  child: Text(
                                    'Note: You are not added any experience to your practice info. If you wish to add experience then chagne the state of your profile on review and add experience and re-submit your profile for approval',
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
                                    child: Text(
                                      'Add/Update Experience',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 15),
                                    width: mQuery.width * 0.75,
                                    height: 50.0,
                                    child: TextFormField(
                                      enabled: widget.isProfessionalProfileCompleted ? false : true,
                                      controller: _hospitalController,
                                      decoration: textFieldDesign(context, 'Hospital Name'),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 15),
                                    width: mQuery.width * 0.75,
                                    height: 50.0,
                                    child: TextFormField(
                                      enabled: widget.isProfessionalProfileCompleted ? false : true,
                                      controller: _rtlHospitalController,
                                      decoration:
                                          textFieldDesign(context, 'Hospital Name (Farsi/Pashto)'),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 15),
                                    width: mQuery.width * 0.75,
                                    height: 50.0,
                                    child: TextFormField(
                                      enabled: widget.isProfessionalProfileCompleted ? false : true,
                                      controller: _designationController,
                                      decoration: textFieldDesign(context, 'Designation'),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 15),
                                    width: mQuery.width * 0.75,
                                    height: 50.0,
                                    child: TextFormField(
                                      enabled: widget.isProfessionalProfileCompleted ? false : true,
                                      controller: _rtlDesignationController,
                                      decoration:
                                          textFieldDesign(context, 'Designation (Farsi/Pashto)'),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 15),
                                    width: mQuery.width * 0.75,
                                    height: 50.0,
                                    child: DateTimeField(
                                      enabled: widget.isProfessionalProfileCompleted ? false : true,
                                      format: _dateTimeFormat,
                                      controller: _startDateController,
                                      decoration: textFieldDesign(context, 'Start Date'),
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
                                  Container(
                                    margin: const EdgeInsets.only(top: 15),
                                    width: mQuery.width * 0.75,
                                    height: 50.0,
                                    child: DateTimeField(
                                      enabled: widget.isProfessionalProfileCompleted ? false : true,
                                      format: _dateTimeFormat,
                                      controller: _endDateController,
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
                                // margin: const EdgeInsets.only(top: 15),
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
                                          _addRemoveExperienceData(null, 'add');
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
                                _saveUpdateExperience(context);
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

  Future<void> _saveUpdateExperience(BuildContext ctx) async {
    final isFormValid = _formValidation();
    if (!isFormValid) {
      return;
    }

    List<int> experienceIdList = [];
    bool _isDialogRunning = false;
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) {
          _isDialogRunning = true;
          return const ProgressPopupDialog();
        });
    try {
      experienceList.forEach((element) => experienceIdList.add(element.id!));

      final Map<String, dynamic> fieldData = {
        'experience_id': _isUpdate ? _experienceId : '',
        'hospital_name': _hospitalController.text,
        'rtl_hospital_name': _rtlHospitalController.text,
        'designation': _designationController.text,
        'rtl_designation': _rtlDesignationController.text,
        'start_date': _startDateController.text,
        'end_date': _endDateController.text,
      };

      FormData body = FormData.fromMap({
        'experience_list_id': experienceIdList,
        'is_editor_expanded': _isEditorExpanded,
        'experience_field_data': _isEditorExpanded ? fieldData : '',
      });
      var experienceResponse = await HttpService().postRequest(
        data: body,
        endPoint: EXPERIENCE_LIST,
      );

      Navigator.of(ctx).pop();
      _isDialogRunning = false;

      if (!experienceResponse.error) {
        final newOrUpdateObject = ExperienceModel(
          id: experienceResponse.data['new_experience_id'] ?? 0,
          hospitalName: _hospitalController.text,
          rtlHospitalName: _rtlHospitalController.text,
          designation: _designationController.text,
          rtlDesignation: _rtlDesignationController.text,
          startDate: _startDateController.text,
          endDate: _endDateController.text,
        );
        print(experienceResponse.data['new_experience_id']);
        setState(() {
          if (!_isUpdate) {
            // get the new created id and add it along with the object
            experienceList.add(newOrUpdateObject);
          } else {
            experienceList[experienceList.indexWhere((element) => element.id == _experienceId)] =
                newOrUpdateObject;
          }
        });
        toastSnackBar('Saved Successfully');
        if (!_isUpdate) {
          _addRemoveExperienceData(null, 'success');
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

  void _addRemoveExperienceData(ExperienceModel? experienceModel, String operation) {
    setState(() {
      if (operation == 'update') {
        _isUpdate = true;
        _isEditorExpanded = true;
        _experienceId = experienceModel!.id ?? 0;
        _hospitalController.text = experienceModel.hospitalName!;
        _rtlHospitalController.text = experienceModel.rtlHospitalName!;
        _designationController.text = experienceModel.designation!;
        _rtlDesignationController.text = experienceModel.rtlDesignation!;
        _startDateController.text = experienceModel.startDate!;
        _endDateController.text = experienceModel.endDate!;
      } else {
        _isUpdate = false;
        _isEditorExpanded = operation == 'success' ? false : !_isEditorExpanded;
        _hospitalController.clear();
        _rtlHospitalController.clear();
        _designationController.clear();
        _rtlDesignationController.clear();
        _startDateController.clear();
        _endDateController.clear();
      }
    });
  }

  bool _formValidation() {
    if (!_isEditorExpanded) {
      if (experienceList.length == 0) {
        _theSetState('There is no experience in your list');
        return false;
      }
      return true;
    }
    _theSetState('');
    if (_hospitalController.text.trim() == '') {
      _theSetState('Please enter hospital name');
      return false;
    }
    if (_rtlHospitalController.text.trim() == '') {
      _theSetState('Please enter hospital name (Dari/Pashto)');
      return false;
    }

    if (_designationController.text.trim() == '') {
      _theSetState('Please enter designation');
      return false;
    }
    if (_rtlDesignationController.text.trim() == '') {
      _theSetState('Please enter designation (Dari/Pashto)');
      return false;
    }
    if (_startDateController.text.trim() == '') {
      _theSetState('Please select start date');
      return false;
    }

    if (_endDateController.text.trim() == '') {
      _theSetState('Please select end date');
      return false;
    }

    final startDate = DateTime.tryParse(_startDateController.text);
    final endDate = DateTime.tryParse(_endDateController.text);

    if (startDate!.isAfter(endDate!)) {
      _theSetState('Start date should be before end date');
      return false;
    }
    return true;
  }
}

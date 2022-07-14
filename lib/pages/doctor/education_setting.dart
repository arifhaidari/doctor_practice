import 'package:dio/dio.dart';
import 'package:doctor_panel/models/model_list.dart';
import 'package:doctor_panel/providers/provider_list.dart';
import 'package:doctor_panel/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import '../../utils/utils.dart';
import '../screens.dart';

class EducationSetting extends StatefulWidget {
  final bool isProfessionalProfileCompleted;

  const EducationSetting({Key? key, required this.isProfessionalProfileCompleted})
      : super(key: key);
  @override
  _EducationSettingState createState() => _EducationSettingState();
}

class _EducationSettingState extends State<EducationSetting> {
  final _formKey = GlobalKey<FormState>();
  final _degreeTypeController = TextEditingController();
  final _educationDegreeController = TextEditingController();
  final _collegeController = TextEditingController();
  final _rtlCollegeController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  List<EducationModel> educationList = <EducationModel>[];
  List<DegreeTypeModel> degreeTypeList = <DegreeTypeModel>[];
  List<EducationDegreeModel> educationDegreeList = <EducationDegreeModel>[];
  List<EducationDegreeModel> educationDegreeOptionalList = <EducationDegreeModel>[];

  final _dateTimeFormat = DateFormat("yyyy-MM-dd");

  String _errorMessage = '';

  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;

  bool _isEdictorExpanded = false;
  bool _isUpdate = false;
  bool _isReverse = false;

  int _educationId = 0;

  List<DegreeTypeModel> getDegreeTypeSuggessions(String query) {
    _isReverse = true;
    return List.of(degreeTypeList).where((theVale) {
      final degreeName = theVale.name!.toLowerCase();
      final queryLower = query.toLowerCase();
      return degreeName.contains(queryLower);
    }).toList();
  }

  List<EducationDegreeModel> getEducationDegreeSuggestions(String query) {
    _isReverse = true;
    return List.of(educationDegreeOptionalList).where((theVale) {
      final educationName = theVale.name!.toLowerCase();
      final queryLower = query.toLowerCase();
      return educationName.contains(queryLower);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _getEducationSubs();
  }

  void _getEducationSubs() async {
    setState(() {
      _isLoading = true;
    });
    var educationListObject = await HttpService().getRequest(endPoint: EDUCATION_SUB_LIST);

    if (!educationListObject.error) {
      try {
        setState(() {
          // Education
          educationListObject.data['doctor_education_list'].forEach((response) {
            final theObject = EducationModel.fromJson(response);
            educationList.add(theObject);
          });

          // DegreeTypeModel
          educationListObject.data['degree_type_list'].forEach((response) {
            final theObject = DegreeTypeModel.fromJson(response);
            degreeTypeList.add(theObject);
          });

          // EducationDegree
          educationListObject.data['education_degree_list'].forEach((response) {
            final theObject = EducationDegreeModel.fromJson(response);
            educationDegreeList.add(theObject);
          });

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
        if (educationListObject.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = educationListObject.errorMessage!;
        }
      });
    }
  }

  void _isBachelorDone(DegreeTypeModel degreeTypeModel) {
    final isBachelorExist = educationList.firstWhere(
        (element) => element.degree!.degreeType!.name == 'Bachelor',
        orElse: () => EducationModel(id: null));

    if (isBachelorExist.id == null && degreeTypeModel.name != 'Bachelor') {
      infoNoOkDialogue(context, 'Add a bachelor degree first then you can the rest of degrees',
          'No Bachelor Degree Available');
    } else {
      _degreeTypeController.text = degreeTypeModel.name!;
      educationDegreeOptionalList = educationDegreeList
          .where((element) => element.degreeType!.id == degreeTypeModel.id)
          .toList();
    }
  }

  void _theSetState(String theMessage) {
    _errorMessage = theMessage;
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        _isReverse = false;
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SafeArea(
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
                    errorTitle: GlobalVariable.UNKNOWN_ERROR,
                    errorDetail: _errorMessage,
                  );
                }
              }
              return SingleChildScrollView(
                reverse: _isReverse,
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
                              if (educationList.isNotEmpty)
                                Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 15),
                                      width: mQuery.width * 0.75,
                                      child: Text('My Education(s)',
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
                                          ...educationList.map(
                                            (e) => InputChip(
                                              label: Text(e.degree!.name!),
                                              labelStyle: TextStyle(
                                                color: Colors.white,
                                              ),
                                              elevation: 5.0,
                                              deleteIconColor: Colors.white,
                                              onPressed: () {
                                                _addRemoveEducationData(e, 'update');
                                              },
                                              // avatar: Icon(Icons.local_hospital),
                                              backgroundColor: Palette.blueAppBar,
                                              onDeleted: () {
                                                if (!widget.isProfessionalProfileCompleted)
                                                  questionDialogue(
                                                      context,
                                                      'Do you really want to delete ${e.degree!.name} clinic?',
                                                      'Remove Education', () {
                                                    setState(() {
                                                      educationList.remove(e);
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

                              if (educationList.isEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  width: mQuery.width * 0.72,
                                  child: Center(
                                    child: Text(
                                      'No Education has been added.\nClick the + button to add',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),

                              if (_isEdictorExpanded)
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
                                      child: Text('Add/Update Education',
                                          textAlign: TextAlign.center,
                                          style:
                                              TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 15),
                                      width: mQuery.width * 0.75,
                                      child: TypeAheadFormField<DegreeTypeModel?>(
                                          enabled:
                                              widget.isProfessionalProfileCompleted ? false : true,
                                          loadingBuilder: (context) => circularLoading(),
                                          noItemsFoundBuilder: (context) {
                                            return Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'No Degree Found',
                                                style: TextStyle(
                                                    fontSize: 16.0, fontWeight: FontWeight.w400),
                                              ),
                                            );
                                          },
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: _degreeTypeController,
                                            decoration: textFieldDesign(context, 'Select Degree',
                                                isIcon: true,
                                                theTextController: _degreeTypeController),
                                          ),
                                          suggestionsCallback: getDegreeTypeSuggessions,
                                          itemBuilder:
                                              (context, DegreeTypeModel? degreeTypeModel) =>
                                                  ListTile(
                                                    title: Text(degreeTypeModel!.name!),
                                                  ),
                                          onSuggestionSelected: (DegreeTypeModel? degreeTypeModel) {
                                            _educationDegreeController.clear();
                                            educationDegreeOptionalList.clear();
                                            _isBachelorDone(degreeTypeModel!);
                                          }),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 15),
                                      width: mQuery.width * 0.75,
                                      child: TypeAheadFormField<EducationDegreeModel?>(
                                          enabled:
                                              widget.isProfessionalProfileCompleted ? false : true,
                                          loadingBuilder: (context) => circularLoading(),
                                          noItemsFoundBuilder: (context) {
                                            return Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'No Degree Name Found',
                                                style: TextStyle(
                                                    fontSize: 16.0, fontWeight: FontWeight.w400),
                                              ),
                                            );
                                          },
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: _educationDegreeController,
                                            decoration: textFieldDesign(
                                                context, 'Select Degree Name',
                                                isIcon: true,
                                                theTextController: _educationDegreeController),
                                          ),
                                          suggestionsCallback: getEducationDegreeSuggestions,
                                          itemBuilder: (context,
                                                  EducationDegreeModel? educationDegreeModel) =>
                                              ListTile(
                                                title: Text(educationDegreeModel!.name!),
                                              ),
                                          onSuggestionSelected:
                                              (EducationDegreeModel? educationDegreeModel) {
                                            _educationDegreeController.text =
                                                educationDegreeModel!.name!;
                                          }),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 15),
                                      width: mQuery.width * 0.75,
                                      height: 50.0,
                                      child: TextFormField(
                                        enabled:
                                            widget.isProfessionalProfileCompleted ? false : true,
                                        controller: _collegeController,
                                        decoration: textFieldDesign(context, 'College/Institue'),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 15),
                                      width: mQuery.width * 0.75,
                                      height: 50.0,
                                      child: TextFormField(
                                        enabled:
                                            widget.isProfessionalProfileCompleted ? false : true,
                                        controller: _rtlCollegeController,
                                        decoration: textFieldDesign(
                                            context, 'College/Institute (Farsi/Pashto)'),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 15),
                                      width: mQuery.width * 0.75,
                                      height: 50.0,
                                      child: DateTimeField(
                                        enabled:
                                            widget.isProfessionalProfileCompleted ? false : true,
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
                                        enabled:
                                            widget.isProfessionalProfileCompleted ? false : true,
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
                                  width: mQuery.width * 0.75,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                          icon: Icon(
                                            _isEdictorExpanded
                                                ? CupertinoIcons.minus_circle_fill
                                                : CupertinoIcons.add_circled_solid,
                                            size: 40.0,
                                            color: _isEdictorExpanded
                                                ? Palette.red
                                                : Palette.blueAppBar,
                                          ),
                                          onPressed: () {
                                            _addRemoveEducationData(null, 'add');
                                          })
                                    ],
                                  ),
                                ),
                              // //////

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
                                  _saveUpdateEducation(context);
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
          )),
    );
  }

  Future<void> _saveUpdateEducation(BuildContext ctx) async {
    final isFormValid = _formValidation();

    if (!isFormValid) {
      return;
    }

    List<int> educationIdList = [];
    bool _isDialogRunning = false;
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) {
          _isDialogRunning = true;
          return const ProgressPopupDialog();
        });
    try {
      educationList.forEach((element) => educationIdList.add(element.id!));

      final Map<String, dynamic> fieldData = {
        'education_id': _isUpdate ? _educationId : '',
        'school_name': _collegeController.text,
        'rtl_school_name': _rtlCollegeController.text,
        'degree': _educationDegreeController.text,
        'degree_type': _degreeTypeController.text,
        'start_date': _startDateController.text,
        'end_date': _endDateController.text,
      };

      FormData body = FormData.fromMap({
        'education_list_id': educationIdList,
        'is_editor_expanded': _isEdictorExpanded,
        'education_field_data': _isEdictorExpanded ? fieldData : '',
      });
      var educationResponse = await HttpService().postRequest(
        data: body,
        endPoint: EDUCATION_SUB_LIST,
      );

      Navigator.of(ctx).pop();
      _isDialogRunning = false;

      if (!educationResponse.error) {
        final newOrUpdateObject = EducationModel(
          id: educationResponse.data['new_education_id'] ?? 0,
          schoolName: _collegeController.text,
          rtlSchoolName: _rtlCollegeController.text,
          degree: EducationDegreeModel(
              name: _educationDegreeController.text,
              degreeType: DegreeTypeModel(name: _degreeTypeController.text)),
          startDate: _startDateController.text,
          endDate: _endDateController.text,
        );
        setState(() {
          if (!_isUpdate) {
            // get the new created id and add it along with the object
            educationList.add(newOrUpdateObject);
          } else {
            educationList[educationList.indexWhere((element) => element.id == _educationId)] =
                newOrUpdateObject;
          }
        });
        toastSnackBar('Saved Successfully');
        if (!_isUpdate) {
          _addRemoveEducationData(null, 'success');
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

    //
  }

  void _addRemoveEducationData(EducationModel? educationModel, String operation) {
    setState(() {
      if (operation == 'update') {
        _isEdictorExpanded = true;
        _isUpdate = true;
        _educationId = educationModel!.id ?? 0;
        _degreeTypeController.text = educationModel.degree!.degreeType!.name!;
        _educationDegreeController.text = educationModel.degree!.name!;
        _collegeController.text = educationModel.schoolName!;
        _rtlCollegeController.text = educationModel.rtlSchoolName!;
        _startDateController.text = educationModel.startDate!;
        _endDateController.text = educationModel.endDate!;
      } else {
        _isUpdate = false;
        _isEdictorExpanded = operation == 'success' ? false : !_isEdictorExpanded;
        _degreeTypeController.clear();
        _educationDegreeController.clear();
        _collegeController.clear();
        _rtlCollegeController.clear();
        _startDateController.clear();
        _endDateController.clear();
      }
    });
  }

  bool _formValidation() {
    print('valueo ffo in form validation ');
    if (!_isEdictorExpanded) {
      if (educationList.length == 0) {
        _theSetState('There is no education in your list');
        return false;
      }
      return true;
    }
    _theSetState('');
    if (_degreeTypeController.text.trim() == '') {
      _theSetState('Please enter degree type');
      return false;
    }
    if (_educationDegreeController.text.trim() == '') {
      _theSetState('Please enter degree name');
      return false;
    }
    if (_collegeController.text.trim() == '') {
      _theSetState('Please enter college/university');
      return false;
    }

    if (_rtlCollegeController.text.trim() == '') {
      _theSetState('Please enter college/university name (Dari/Pashto)');
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

    final isDegreeType = degreeTypeList.firstWhere(
        (element) => element.name == _degreeTypeController.text,
        orElse: () => DegreeTypeModel(id: null));
    if (isDegreeType.id == null) {
      _theSetState('Select a proper Degree type name with correct spelling');
      return false;
    }
    final isEducationDegree = educationDegreeList.firstWhere(
        (element) => element.name == _educationDegreeController.text,
        orElse: () => EducationDegreeModel(id: null));
    if (isEducationDegree.id == null) {
      _theSetState('Select a proper Degree Name with correct spelling');
      return false;
    }
    return true;
  }
}

import 'package:dio/dio.dart';
import 'package:doctor_panel/models/model_list.dart';
import 'package:doctor_panel/providers/provider_list.dart';
import 'package:doctor_panel/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../utils/utils.dart';
import '../screens.dart';

class CareServiceSetting extends StatefulWidget {
  final bool isProfessionalProfileCompleted;

  const CareServiceSetting({Key? key, required this.isProfessionalProfileCompleted})
      : super(key: key);
  @override
  _CareServiceSettingState createState() => _CareServiceSettingState();
}

class _CareServiceSettingState extends State<CareServiceSetting> {
  final _formKey = GlobalKey<FormState>();
  final _specialityTextController = TextEditingController();
  final _conditionTextController = TextEditingController();
  final _serviceTextController = TextEditingController();
  //
  List<SpecialityModel> specialityList = <SpecialityModel>[];
  List<ConditionModel> conditionList = <ConditionModel>[];
  List<ServiceModel> serviceList = <ServiceModel>[];

  // Selected Care Services
  List<SpecialityModel> selectedSpecialityList = <SpecialityModel>[];
  List<ConditionModel> selectedConditionList = <ConditionModel>[];
  List<ServiceModel> selectedServiceList = <ServiceModel>[];

  // optinal list
  List<ConditionModel> optionalConditionList = <ConditionModel>[];
  List<ServiceModel> optionalServiceList = <ServiceModel>[];

  String _errorMessage = '';

  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;
  bool _isReverse = false;

  @override
  void initState() {
    super.initState();
    _getCareServicesList();
  }

  void _getCareServicesList() async {
    setState(() {
      _isLoading = true;
    });

    var careServiceRawList = await HttpService().getRequest(endPoint: CARE_SERVICE_LIST);

    if (!careServiceRawList.error) {
      try {
        if (careServiceRawList.data is List && careServiceRawList.data.length != 0) {
          // speciality_list
          if (careServiceRawList.data[0]['speciality_list'].length > 0) {
            careServiceRawList.data[0]['speciality_list'].forEach((response) {
              final titleObject = SpecialityModel.fromJson(response);
              specialityList.add(titleObject);
            });
          }

          // condition_list
          if (careServiceRawList.data[0]['condition_list'].length > 0) {
            careServiceRawList.data[0]['condition_list'].forEach((response) {
              final titleObject = ConditionModel.fromJson(response);
              conditionList.add(titleObject);
            });
          }

          // service_list
          if (careServiceRawList.data[0]['service_list'].length > 0) {
            careServiceRawList.data[0]['service_list'].forEach((response) {
              final titleObject = ServiceModel.fromJson(response);
              serviceList.add(titleObject);
            });
          }
        }
        setState(() {
          // selected_speciality_list
          if (careServiceRawList.data[0]['selected_speciality_list'].length > 0) {
            careServiceRawList.data[0]['selected_speciality_list'].forEach((response) {
              final titleObject = SpecialityModel.fromJson(response);
              selectedSpecialityList.add(titleObject);
            });
          }

          // selected_condition_list
          if (careServiceRawList.data[0]['selected_condition_list'].length > 0) {
            careServiceRawList.data[0]['selected_condition_list'].forEach((response) {
              final titleObject = ConditionModel.fromJson(response);
              selectedConditionList.add(titleObject);
            });
          }

          // selected_service_list
          if (careServiceRawList.data[0]['selected_service_list'].length > 0) {
            careServiceRawList.data[0]['selected_service_list'].forEach((response) {
              final titleObject = ServiceModel.fromJson(response);
              selectedServiceList.add(titleObject);
            });
          }
          _isLoading = false;
        });
        _createOptionalList();
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
        if (careServiceRawList.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = careServiceRawList.errorMessage!;
        }
      });
    }
  }

  void _removeCareServices(SpecialityModel specialityObject) {
    setState(() {
      try {
        optionalConditionList
            .removeWhere((element) => element.speciality!.id == specialityObject.id);
        optionalServiceList.removeWhere((element) => element.speciality!.id == specialityObject.id);
        selectedConditionList
            .removeWhere((element) => element.speciality!.id == specialityObject.id);
        selectedServiceList.removeWhere((element) => element.speciality!.id == specialityObject.id);
      } catch (e) {}
    });
  }

  void _createOptionalList() {
    if (selectedSpecialityList.length > 0) {
      selectedSpecialityList.forEach((specialityElement) {
        _createOptionalListSub(specialityElement);
      });
    }
  }

  void _createOptionalListSub(SpecialityModel specialityObject) {
    final conditionTempList = conditionList
        .where((conditionElement) => conditionElement.speciality!.id == specialityObject.id)
        .toList();
    optionalConditionList.addAll(conditionTempList);

    //
    final serviceTempList = serviceList
        .where((serviceElement) => serviceElement.speciality!.id == specialityObject.id)
        .toList();

    optionalServiceList.addAll(serviceTempList);
  }

  List<SpecialityModel> getSpecialitySuggestions(String query) {
    _isReverse = true;
    print('value of _isReverse');
    print(_isReverse);
    return List.of(specialityList).where((theVale) {
      final specialityName = theVale.name!.toLowerCase();
      final queryLower = query.toLowerCase();
      return specialityName.contains(queryLower);
    }).toList();
  }

  List<ConditionModel> getConditionSuggestions(String query) {
    _isReverse = true;
    return List.of(optionalConditionList).where((theVale) {
      final conditionName = theVale.name!.toLowerCase();
      final queryLower = query.toLowerCase();
      return conditionName.contains(queryLower);
    }).toList();
  }

  List<ServiceModel> getServiceSuggestions(String query) {
    _isReverse = true;
    return List.of(optionalServiceList).where((theVale) {
      final serviceName = theVale.name!.toLowerCase();
      final queryLower = query.toLowerCase();
      return serviceName.contains(queryLower);
    }).toList();
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
                  errorTitle: 'Unknown Error. Try again later',
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
                            if (!widget.isProfessionalProfileCompleted)
                              Container(
                                margin: const EdgeInsets.only(top: 15),
                                width: mQuery.width * 0.75,
                                child: TypeAheadFormField<SpecialityModel?>(
                                    // enabled: widget.isProfessionalProfileCompleted ? false : true,
                                    loadingBuilder: (context) => circularLoading(),
                                    noItemsFoundBuilder: (context) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'No Speciality Found',
                                          style: TextStyle(
                                              fontSize: 16.0, fontWeight: FontWeight.w400),
                                        ),
                                      );
                                    },
                                    textFieldConfiguration: TextFieldConfiguration(
                                      controller: _specialityTextController,
                                      decoration: textFieldDesign(context, 'Search Speciality',
                                          isIcon: true,
                                          theTextController: _specialityTextController),
                                    ),
                                    suggestionsCallback: getSpecialitySuggestions,
                                    itemBuilder: (context, SpecialityModel? specialityModel) =>
                                        ListTile(
                                          title: Text(specialityModel!.name!),
                                        ),
                                    onSuggestionSelected: (SpecialityModel? specialityModel) {
                                      _specialityTextController.clear();
                                      final theVal = selectedSpecialityList.firstWhere(
                                          (element) => element.id == specialityModel!.id,
                                          orElse: () => SpecialityModel(id: null));
                                      if (theVal.id == null) {
                                        setState(() {
                                          selectedSpecialityList.add(specialityModel!);
                                          _createOptionalListSub(specialityModel);
                                        });
                                      }
                                    }),
                              ),
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: mQuery.width * 0.72,
                              child: Wrap(
                                  // alignment: WrapAlignment.start,
                                  spacing: 8.0,
                                  runSpacing: 5.0,
                                  children: [
                                    if (selectedSpecialityList.isEmpty)
                                      Center(
                                        child: Text(
                                          'No Speciality Is Selected',
                                          style:
                                              TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ...selectedSpecialityList.map((e) {
                                      return InputChip(
                                        label: Text(e.name!),
                                        labelStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        elevation: 5.0,
                                        deleteIconColor: Colors.white,
                                        onPressed: () {
                                          infoNoOkDialogue(
                                              context,
                                              'Speciality Name: ${e.name}\nDari Name: ${e.farsiName}\nPashto Name: ${e.pashtoName}',
                                              'Speciality Info');
                                        },
                                        // avatar: Icon(Icons.local_hospital),
                                        backgroundColor: Palette.blueAppBar,
                                        onDeleted: () {
                                          if (!widget.isProfessionalProfileCompleted) {
                                            questionDialogue(
                                                context,
                                                'Do you really want to remove this Speciality?',
                                                'Remove Speciality', () {
                                              setState(() {
                                                _removeCareServices(e);
                                                selectedSpecialityList.remove(e);
                                              });
                                            });
                                          }
                                        },
                                      );
                                    }).toList(),
                                  ]),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              width: mQuery.width * 0.74,
                              child: dashedLine(Palette.blueAppBar),
                            ),
                            if (!widget.isProfessionalProfileCompleted)
                              Container(
                                margin: const EdgeInsets.only(top: 15),
                                width: mQuery.width * 0.75,
                                child: TypeAheadFormField<ConditionModel?>(
                                    // enabled: widget.isProfessionalProfileCompleted ? false : true,
                                    loadingBuilder: (context) => circularLoading(),
                                    noItemsFoundBuilder: (context) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'No Condition Found',
                                          style: TextStyle(
                                              fontSize: 16.0, fontWeight: FontWeight.w400),
                                        ),
                                      );
                                    },
                                    textFieldConfiguration: TextFieldConfiguration(
                                      controller: _conditionTextController,
                                      decoration: textFieldDesign(context, 'Search Condition',
                                          isIcon: true,
                                          theTextController: _conditionTextController),
                                    ),
                                    suggestionsCallback: getConditionSuggestions,
                                    itemBuilder: (context, ConditionModel? conditionModel) =>
                                        ListTile(
                                          title: Text(conditionModel!.name!),
                                        ),
                                    onSuggestionSelected: (ConditionModel? conditionModel) {
                                      _conditionTextController.clear();
                                      final theVal = selectedConditionList.firstWhere(
                                          (element) => element.id == conditionModel!.id,
                                          orElse: () => ConditionModel(id: null));
                                      if (theVal.id == null) {
                                        setState(() {
                                          selectedConditionList.add(conditionModel!);
                                        });
                                      }
                                    }),
                              ),
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: mQuery.width * 0.72,
                              child: Wrap(
                                  // alignment: WrapAlignment.start,
                                  spacing: 8.0,
                                  runSpacing: 5.0,
                                  children: [
                                    if (selectedConditionList.isEmpty)
                                      Center(
                                        child: Text(
                                          'No Condition Is Selected',
                                          style:
                                              TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ...selectedConditionList.map((e) {
                                      return InputChip(
                                        label: Text(e.name!),
                                        labelStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        elevation: 5.0,
                                        deleteIconColor: Colors.white,
                                        onPressed: () {
                                          final _theSpeciality = selectedSpecialityList.firstWhere(
                                              (element) => element.id == e.speciality!.id);
                                          infoNoOkDialogue(
                                              context,
                                              'Condition Name: ${e.name}\nDari Name: ${e.farsiName}\nPashto Name: ${e.pashtoName}\n Speciality: ${_theSpeciality.name}',
                                              'Condition Info');
                                        },
                                        // avatar: Icon(Icons.local_hospital),
                                        backgroundColor: Palette.blueAppBar,
                                        onDeleted: () {
                                          if (!widget.isProfessionalProfileCompleted)
                                            questionDialogue(
                                                context,
                                                'Do you really want to remove this Condition?',
                                                'Remove Condition', () {
                                              setState(() {
                                                selectedConditionList.remove(e);
                                              });
                                            });
                                        },
                                      );
                                    }).toList(),
                                  ]),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              width: mQuery.width * 0.74,
                              child: dashedLine(Palette.blueAppBar),
                            ),
                            if (!widget.isProfessionalProfileCompleted)
                              Container(
                                margin: const EdgeInsets.only(top: 15),
                                width: mQuery.width * 0.75,
                                child: TypeAheadFormField<ServiceModel?>(
                                    loadingBuilder: (context) => circularLoading(),
                                    noItemsFoundBuilder: (context) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'No Service Found',
                                          style: TextStyle(
                                              fontSize: 16.0, fontWeight: FontWeight.w400),
                                        ),
                                      );
                                    },
                                    textFieldConfiguration: TextFieldConfiguration(
                                      controller: _serviceTextController,
                                      decoration: textFieldDesign(context, 'Search Service',
                                          isIcon: true, theTextController: _serviceTextController),
                                    ),
                                    suggestionsCallback: getServiceSuggestions,
                                    itemBuilder: (context, ServiceModel? serviceModel) => ListTile(
                                          title: Text(serviceModel!.name!),
                                        ),
                                    onSuggestionSelected: (ServiceModel? serviceModel) {
                                      _conditionTextController.clear();
                                      final theVal = selectedServiceList.firstWhere(
                                          (element) => element.id == serviceModel!.id,
                                          orElse: () => ServiceModel(id: null));
                                      if (theVal.id == null) {
                                        setState(() {
                                          selectedServiceList.add(serviceModel!);
                                        });
                                      }
                                    }),
                              ),
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: mQuery.width * 0.72,
                              child: Wrap(
                                  // alignment: WrapAlignment.start,
                                  spacing: 8.0,
                                  runSpacing: 5.0,
                                  children: [
                                    if (selectedServiceList.isEmpty)
                                      Center(
                                        child: Text(
                                          'No Serivce Is Selected',
                                          style:
                                              TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ...selectedServiceList.map((e) {
                                      return InputChip(
                                        label: Text(e.name!),
                                        labelStyle: TextStyle(
                                          color: Colors.white,
                                        ),
                                        elevation: 5.0,
                                        deleteIconColor: Colors.white,
                                        onPressed: () {
                                          final _theSpeciality = selectedSpecialityList.firstWhere(
                                              (element) => element.id == e.speciality!.id);
                                          infoNoOkDialogue(
                                              context,
                                              'Service Name: ${e.name}\nDari Name: ${e.farsiName}\nPashto Name: ${e.pashtoName}\n Speciality: ${_theSpeciality.name}',
                                              'Service Name');
                                        },
                                        // avatar: Icon(Icons.local_hospital),
                                        backgroundColor: Palette.blueAppBar,
                                        onDeleted: () {
                                          if (!widget.isProfessionalProfileCompleted) {
                                            questionDialogue(
                                                context,
                                                'Do you really want to remove this Service?',
                                                'Remove Service', () {
                                              setState(() {
                                                selectedServiceList.remove(e);
                                              });
                                            });
                                          }
                                        },
                                      );
                                    }).toList(),
                                  ]),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              width: mQuery.width * 0.74,
                              child: dashedLine(Palette.blueAppBar),
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
                                _saveUpdateCareServices(context);
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
        ),
      ),
    );
  }

  Future<void> _saveUpdateCareServices(BuildContext ctx) async {
    if (specialityList.length != 0 && conditionList.length != 0 && serviceList.length != 0) {
      List<int> specialityIdList = [];
      List<int> conditionIdList = [];
      List<int> serviceIdList = [];

      bool _isDialogRunning = false;
      showDialog(
          context: ctx,
          barrierDismissible: false,
          builder: (_) {
            _isDialogRunning = true;
            return const ProgressPopupDialog();
          });
      try {
        selectedSpecialityList.forEach((element) => specialityIdList.add(element.id!));
        selectedConditionList.forEach((element) => conditionIdList.add(element.id!));
        selectedServiceList.forEach((element) => serviceIdList.add(element.id!));

        FormData body = FormData.fromMap({
          'specialist': specialityIdList,
          'conditions': conditionIdList,
          'services': serviceIdList,
        });
        var scheduleResponse = await HttpService().postRequest(
          data: body,
          endPoint: CARE_SERVICE_LIST,
        );

        Navigator.of(ctx).pop();
        _isDialogRunning = false;

        if (!scheduleResponse.error) {
          toastSnackBar('Saved Successfully');
        } else {
          infoNoOkDialogue(
              context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
        }
      } catch (e) {
        _isDialogRunning ? Navigator.of(ctx).pop() : null;
        infoNoOkDialogue(
            context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    } else {
      _theSetState(
          'You should select at least one speciality with it\'s services and conditions correspondents');
    }
  }
}

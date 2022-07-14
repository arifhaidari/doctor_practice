import 'package:dio/dio.dart';
import 'package:doctor_panel/models/model_list.dart';
import 'package:doctor_panel/providers/provider_list.dart';
import 'package:doctor_panel/utils/global_variable.dart';
import 'package:doctor_panel/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../utils/utils.dart';
import '../screens.dart';

class ClinicInfoSetting extends StatefulWidget {
  final bool isProfessionalProfileCompleted;
  final int doctorId;

  const ClinicInfoSetting(
      {Key? key, required this.doctorId, required this.isProfessionalProfileCompleted})
      : super(key: key);
  @override
  _ClinicInfoSettingState createState() => _ClinicInfoSettingState();
}

class _ClinicInfoSettingState extends State<ClinicInfoSetting> {
  final _clinicSearchController = TextEditingController();
  //
  final _formKey = GlobalKey<FormState>();
  final _clinicNameController = TextEditingController();
  final _rtlClinicNameController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _rtlClinicAddressController = TextEditingController();
  final _clinicCityController = TextEditingController();
  final _clinicDistrictController = TextEditingController();

  String _errorMessage = '';

  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;

  int _clinicId = 0;

  bool _isEditorExpanded = false;
  bool _isUpdate = false;

  List<ClinicModel> doctorCreatedClinicList = <ClinicModel>[];
  List<ClinicModel> selectedClinicList = <ClinicModel>[];
  List<ClinicModel> searchedClinicList = <ClinicModel>[];
  List<ClinicModel> allExistingClinicList = <ClinicModel>[];

  List<CityModel> cityList = <CityModel>[];
  List<DistrictModel> districtList = <DistrictModel>[];
  List<DistrictModel> optionalDistrictList = <DistrictModel>[];

  void _theSetState(String theMessage) {
    _errorMessage = theMessage;
  }

  @override
  void initState() {
    super.initState();
    _getClinicList();
  }

  void _getSearchedClinic(String query, BuildContext ctx) async {
    if (query.length % 3 == 0 && query != '') {
      print('query.length % 3 == 0 && _clinicNo <= 3 ture ');
      final clinicListObject = await HttpService().getRequest(endPoint: CLINIC_LIST + "?q=$query");

      if (!clinicListObject.error) {
        if (clinicListObject.data is List && clinicListObject.data.length != 0) {
          if (clinicListObject.data.length > 0) {
            searchedClinicList.clear();
            setState(() {
              clinicListObject.data.forEach((response) {
                final theObject = ClinicModel.fromJson(response);
                searchedClinicList.add(theObject);
              });
            });
          }
        }
      }
    }
  }

  Future<void> _getClinicList() async {
    setState(() {
      _isLoading = true;
    });

    final clinicListObject = await HttpService().getRequest(endPoint: CLINIC_LIST);

    if (!clinicListObject.error) {
      try {
        if (clinicListObject.data is List && clinicListObject.data.length != 0) {
          if (clinicListObject.data.length > 0) {
            clinicListObject.data.forEach((response) {
              final theObject = ClinicModel.fromJson(response);
              allExistingClinicList.add(theObject);
            });
          }
        }
        setState(() {
          // filter the selected and created clinics
          selectedClinicList = allExistingClinicList
              .where((element) => element.createdBy != widget.doctorId)
              .toList();
          doctorCreatedClinicList = allExistingClinicList
              .where((element) => element.createdBy == widget.doctorId)
              .toList();
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
        if (clinicListObject.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = clinicListObject.errorMessage!;
        }
      });
    }
  }

  int _calculateClinicLength() {
    int returnVal = doctorCreatedClinicList.length + selectedClinicList.length;
    return returnVal;
  }

  bool _isReverse = false;

  void _createDistrictOptionalList(CityModel cityObject) {
    optionalDistrictList =
        districtList.where((element) => element.city!.id == cityObject.id).toList();
  }

  List<CityModel> getCitySuggessions(String query) {
    _isReverse = true;
    return List.of(cityList).where((theVale) {
      final cityName = theVale.name!.toLowerCase();
      final queryLower = query.toLowerCase();
      return cityName.contains(queryLower);
    }).toList();
  }

  List<DistrictModel> getDistrictSuggessions(String query) {
    _isReverse = true;
    return List.of(optionalDistrictList).where((theVale) {
      final districtName = theVale.name!.toLowerCase();
      final queryLower = query.toLowerCase();
      return districtName.contains(queryLower);
    }).toList();
  }

  List<ClinicModel> getClinicSuggestions(String query) {
    _isReverse = true;
    return List.of(searchedClinicList).where((theVale) {
      final clinicName = theVale.clinicName!.toLowerCase();
      final queryLower = query.toLowerCase();
      return clinicName.contains(queryLower);
    }).toList();
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
                                  child: Card(
                                    elevation: 8.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)),
                                    child: TypeAheadFormField<ClinicModel?>(
                                        loadingBuilder: (context) => circularLoading(),
                                        noItemsFoundBuilder: (context) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'No Clinic Found',
                                              style: TextStyle(
                                                  fontSize: 16.0, fontWeight: FontWeight.w400),
                                            ),
                                          );
                                        },
                                        textFieldConfiguration: TextFieldConfiguration(
                                            onChanged: (theVal) {
                                              if (_calculateClinicLength() >= 4) {
                                                warningDialogue(
                                                    context,
                                                    'If you want this clinic into your practice info, then you should remove one your existing clinic',
                                                    'You have added 4 clinics');
                                              } else {
                                                _getSearchedClinic(theVal, context);
                                              }
                                            },
                                            controller: _clinicSearchController,
                                            decoration: searchFieldDecoation(
                                                context, 'Search Clinic', _clinicSearchController)),
                                        suggestionsCallback: getClinicSuggestions,
                                        itemBuilder: (context, ClinicModel? clinicModel) =>
                                            ListTile(
                                              title: Text(clinicModel!.clinicName!),
                                            ),
                                        onSuggestionSelected: (ClinicModel? clinicModel) {
                                          _clinicSearchController.clear();
                                          final theVal = selectedClinicList.firstWhere(
                                              (element) => element.id == clinicModel!.id,
                                              orElse: () => ClinicModel(id: null));
                                          if (theVal.id == null) {
                                            setState(() {
                                              selectedClinicList.add(clinicModel!);
                                            });
                                          }
                                          _clinicSearchController.clear();
                                          searchedClinicList.clear();
                                        }),
                                  ),
                                ),
                              if (selectedClinicList.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 15),
                                  width: mQuery.width * 0.75,
                                  child: Text('Selected Clinic(s)',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                                ),
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: mQuery.width * 0.72,
                                child: Wrap(
                                    // alignment: WrapAlignment.start,
                                    spacing: 8.0,
                                    runSpacing: 5.0,
                                    children: [
                                      if (selectedClinicList.isEmpty)
                                        Center(
                                          child: Text(
                                            'No existing clinic is selected',
                                            style: TextStyle(
                                                fontSize: 15, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ...selectedClinicList.map((e) {
                                        return InputChip(
                                          label: Text(e.clinicName!),
                                          labelStyle: TextStyle(
                                            color: Colors.white,
                                          ),
                                          elevation: 5.0,
                                          deleteIconColor: Colors.white,
                                          onPressed: () {
                                            infoNoOkDialogue(
                                                context,
                                                'Name(Dari/Pashto): ${e.rtlClinicName}\nLocation: ${e.district!.name}, ${e.city!.name}\nAddress: ${e.address}',
                                                e.clinicName ?? 'Unknown Clinic');
                                          },
                                          // avatar: Icon(Icons.local_hospital),
                                          backgroundColor: Palette.blueAppBar,
                                          onDeleted: () {
                                            if (!widget.isProfessionalProfileCompleted)
                                              questionDialogue(
                                                  context,
                                                  'Do you really want to remove ${e.clinicName} from your list of clinic?\nNote: All booked appointments related to this clinic will be canceled automatically!',
                                                  'Remove Clinic', () {
                                                setState(() {
                                                  selectedClinicList.remove(e);
                                                });
                                              });
                                          },
                                        );
                                      }).toList(),
                                    ]),
                              ),
                              if (doctorCreatedClinicList.isNotEmpty)
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
                                      child: Text('Registered Clinic(s)',
                                          textAlign: TextAlign.center,
                                          style:
                                              TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                                    ),
                                  ],
                                ),
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: mQuery.width * 0.72,
                                child: Wrap(
                                    // alignment: WrapAlignment.start,
                                    spacing: 8.0,
                                    runSpacing: 5.0,
                                    children: [
                                      ...doctorCreatedClinicList.map((e) {
                                        return InputChip(
                                          label: Text(e.clinicName ?? 'Unknown Name'),
                                          labelStyle: TextStyle(
                                            color: Colors.white,
                                          ),
                                          elevation: 5.0,
                                          deleteIconColor: Colors.white,
                                          onPressed: () {
                                            _addRemoveClinicData(e, 'update');
                                          },
                                          // avatar: Icon(Icons.local_hospital),
                                          backgroundColor: Palette.blueAppBar,
                                          onDeleted: () {
                                            // you can only remove the clinic from the list of your practice addresses
                                            if (!widget.isProfessionalProfileCompleted)
                                              questionDialogue(
                                                  context,
                                                  'If there is no doctor has selected this clinic as practice address then it will be removed otherwise you will only remove this clinic from your practice addresses only.\nNote: All booked appointments related to this clinic will be canceled automatically! \nDo you really want to delete ${e.clinicName}?',
                                                  'Remove Clinic', () {
                                                setState(() {
                                                  doctorCreatedClinicList.remove(e);
                                                });
                                              });
                                          },
                                        );
                                      }).toList(),
                                    ]),
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
                                      child: Text('Add/Update Clinic',
                                          textAlign: TextAlign.center,
                                          style:
                                              TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 15),
                                      width: mQuery.width * 0.75,
                                      height: 50.0,
                                      child: TextFormField(
                                        enabled:
                                            widget.isProfessionalProfileCompleted ? false : true,
                                        controller: _clinicNameController,
                                        decoration: textFieldDesign(context, 'Clinic Name'),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 15),
                                      width: mQuery.width * 0.75,
                                      height: 50.0,
                                      child: TextFormField(
                                        enabled:
                                            widget.isProfessionalProfileCompleted ? false : true,
                                        controller: _rtlClinicNameController,
                                        decoration:
                                            textFieldDesign(context, 'Clinic Name (Farsi/Pashto)'),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 15),
                                      width: mQuery.width * 0.75,
                                      height: 50.0,
                                      child: TextFormField(
                                        enabled:
                                            widget.isProfessionalProfileCompleted ? false : true,
                                        controller: _clinicAddressController,
                                        decoration: textFieldDesign(context, 'Clinic Address'),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 15),
                                      width: mQuery.width * 0.75,
                                      height: 50.0,
                                      child: TextFormField(
                                        enabled:
                                            widget.isProfessionalProfileCompleted ? false : true,
                                        controller: _rtlClinicAddressController,
                                        decoration: textFieldDesign(
                                            context, 'Clinic Address (Farsi/Pashto)'),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 15),
                                      width: mQuery.width * 0.75,
                                      child: TypeAheadFormField<CityModel?>(
                                          enabled:
                                              widget.isProfessionalProfileCompleted ? false : true,
                                          loadingBuilder: (context) => circularLoading(),
                                          noItemsFoundBuilder: (context) {
                                            return Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'No Province Found',
                                                style: TextStyle(
                                                    fontSize: 16.0, fontWeight: FontWeight.w400),
                                              ),
                                            );
                                          },
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: _clinicCityController,
                                            decoration: textFieldDesign(context, 'Select Province',
                                                isIcon: true,
                                                theTextController: _clinicCityController),
                                          ),
                                          suggestionsCallback: getCitySuggessions,
                                          itemBuilder: (context, CityModel? cityModel) => ListTile(
                                                title: Text(cityModel!.name!),
                                              ),
                                          onSuggestionSelected: (CityModel? cityModel) {
                                            if (!widget.isProfessionalProfileCompleted) {
                                              _clinicCityController.clear();
                                              _clinicDistrictController.clear();
                                              _clinicCityController.text = cityModel!.name!;
                                              _createDistrictOptionalList(cityModel);
                                            }
                                          }),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 15),
                                      width: mQuery.width * 0.75,
                                      child: TypeAheadFormField<DistrictModel?>(
                                          enabled:
                                              widget.isProfessionalProfileCompleted ? false : true,
                                          loadingBuilder: (context) => circularLoading(),
                                          noItemsFoundBuilder: (context) {
                                            return Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'No District Found',
                                                style: TextStyle(
                                                    fontSize: 16.0, fontWeight: FontWeight.w400),
                                              ),
                                            );
                                          },
                                          textFieldConfiguration: TextFieldConfiguration(
                                            controller: _clinicDistrictController,
                                            decoration: textFieldDesign(context, 'Select District',
                                                isIcon: true,
                                                theTextController: _clinicDistrictController),
                                          ),
                                          suggestionsCallback: getDistrictSuggessions,
                                          itemBuilder: (context, DistrictModel? districtModel) =>
                                              ListTile(
                                                title: Text(districtModel!.name!),
                                              ),
                                          onSuggestionSelected: (DistrictModel? districtModel) {
                                            if (!widget.isProfessionalProfileCompleted) {
                                              _clinicDistrictController.clear();
                                              _clinicDistrictController.text = districtModel!.name!;
                                            }
                                          }),
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
                                            color: _isEditorExpanded
                                                ? Palette.red
                                                : Palette.blueAppBar,
                                          ),
                                          onPressed: () {
                                            _addRemoveClinicData(null, 'add');
                                            print('cupertino icon button got pressed');
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
                                  _saveUpdateClinic(context);
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

  Future<void> _saveUpdateClinic(BuildContext ctx) async {
    if (_calculateClinicLength() >= 4 && !_isUpdate && _isEditorExpanded) {
      infoNoOkDialogue(
          context,
          'If you want to add this clinic you should remmove one of your clinics either from registered or selected',
          'You have registered 4 clinics');
      return;
    }

    final isFormValid = _formValidation();
    if (!isFormValid) {
      return;
    }

    List<int> selectedClinicIdList = [];
    List<int> doctorCreatedIdlist = [];

    bool _isDialogRunning = false;
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) {
          _isDialogRunning = true;
          return const ProgressPopupDialog();
        });

    try {
      selectedClinicList.forEach((element) => selectedClinicIdList.add(element.id!));
      doctorCreatedClinicList.forEach((element) => doctorCreatedIdlist.add(element.id!));

      final _clinicFieldData = {
        'clinic_id': _isUpdate ? _clinicId : '',
        'clinic_name': _clinicNameController.text,
        'rtl_clinic_name': _rtlClinicNameController.text,
        'address': _clinicAddressController.text,
        'rtl_address': _rtlClinicAddressController.text,
        'city_name': _clinicCityController.text,
        'district_name': _clinicDistrictController.text,
      };
      FormData body = FormData.fromMap({
        'selected_clinic_list_id': selectedClinicIdList,
        'doctor_created_clinic_list_id': doctorCreatedIdlist,
        'is_expanded': _isEditorExpanded,
        'clinic_field_data': _isEditorExpanded ? _clinicFieldData : '',
      });
      var scheduleResponse = await HttpService().postRequest(
        data: body,
        endPoint: CLINIC_LIST,
      );

      Navigator.of(ctx).pop();
      _isDialogRunning = false;

      if (!scheduleResponse.error) {
        if (_isEditorExpanded) {
          final newOrUpdateObject = ClinicModel(
            id: scheduleResponse.data['new_clinic_id'] ?? 0,
            clinicName: _clinicNameController.text,
            rtlClinicName: _rtlClinicNameController.text,
            address: _clinicAddressController.text,
            rtlAddress: _rtlClinicAddressController.text,
            city: CityModel(name: _clinicCityController.text),
            district: DistrictModel(name: _clinicDistrictController.text),
          );
          print(scheduleResponse.data['new_clinic_id']);
          setState(() {
            if (!_isUpdate) {
              // get the new created id and add it along with the object
              doctorCreatedClinicList.add(newOrUpdateObject);
            } else {
              doctorCreatedClinicList[doctorCreatedClinicList
                  .indexWhere((element) => element.id == _clinicId)] = newOrUpdateObject;
            }
          });
        }

        toastSnackBar('Saved Successfully');
        if (!_isUpdate) {
          _addRemoveClinicData(null, 'success');
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

  void _addRemoveClinicData(ClinicModel? clinicModelObject, String operation) async {
    if (operation == 'update') {
      setState(() {
        _isUpdate = true;
        _isEditorExpanded = true;
        _clinicId = clinicModelObject!.id ?? 0;
        _clinicNameController.text = clinicModelObject.clinicName ?? "";
        _rtlClinicNameController.text = clinicModelObject.rtlClinicName ?? "";
        _clinicAddressController.text = clinicModelObject.address ?? "";
        _rtlClinicAddressController.text = clinicModelObject.rtlAddress ?? "";
        _clinicCityController.text = clinicModelObject.city!.name ?? "";
        _clinicDistrictController.text = clinicModelObject.district!.name ?? "";
      });
    } else {
      setState(() {
        _isUpdate = false;
        _isEditorExpanded = operation == 'success' ? false : !_isEditorExpanded;
      });
      _clinicNameController.clear();
      _rtlClinicNameController.clear();
      _clinicAddressController.clear();
      _rtlClinicAddressController.clear();
      _clinicCityController.clear();
      _clinicDistrictController.clear();
    }
    // get clinic and district list for the first time
    if (cityList.length <= 0 && !widget.isProfessionalProfileCompleted) {
      // city part

      var cityDistrictList =
          await HttpService().getRequest(endPoint: CITY_DISTRICT_LIST, isAuth: false);
      if (!cityDistrictList.error) {
        if (cityDistrictList.data is List && cityDistrictList.data.length != 0) {
          setState(() {
            cityDistrictList.data[0]['city_list'].forEach((response) {
              final theObject = CityModel.fromJson(response);
              cityList.add(theObject);
            });
            cityDistrictList.data[0]['district_list'].forEach((response) {
              final theObject = DistrictModel.fromJson(response);
              districtList.add(theObject);
            });
          });
        }
      }
    }
  }

  bool _formValidation() {
    if (!_isEditorExpanded) {
      if (selectedClinicList.length == 0 && doctorCreatedClinicList.length == 0) {
        _theSetState('You have no clinic selected or created to save');
        return false;
      }
      return true;
    }
    _theSetState('');

    if (_clinicNameController.text.trim() == '') {
      _theSetState('Clinic name should not be empty');
      return false;
    }

    if (_rtlClinicNameController.text.trim() == '') {
      _theSetState('Clinic name (Dari/Pashto) should not be empty');
      return false;
    }

    if (_clinicAddressController.text.trim() == '') {
      _theSetState('Clinic address should not be empty');
      return false;
    }

    if (_rtlClinicAddressController.text.trim() == '') {
      _theSetState('Clinic address (Dari/Pashto) should not be empty');
      return false;
    }

    if (_clinicCityController.text.trim() == '') {
      _theSetState('Clinic province should not be empty');
      return false;
    }

    if (_clinicDistrictController.text.trim() == '') {
      _theSetState('Clinic district should not be empty');
      return false;
    }
    final isCity = cityList.firstWhere((element) => element.name == _clinicCityController.text,
        orElse: () => CityModel(id: null));
    if (isCity.id == null) {
      _theSetState('Select a proper provice name with correct spelling');
      return false;
    }
    final isDistrict = districtList.firstWhere(
        (element) => element.name == _clinicDistrictController.text,
        orElse: () => DistrictModel(id: null));
    if (isDistrict.id == null) {
      _theSetState('Select a proper district name with correct spelling');
      return false;
    }
    return true;
  }
}

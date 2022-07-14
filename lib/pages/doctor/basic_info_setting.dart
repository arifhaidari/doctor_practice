import 'dart:io';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:dio/dio.dart';
import 'package:doctor_panel/models/dummy_data.dart';
import 'package:doctor_panel/models/model_list.dart';
import 'package:doctor_panel/pages/screens.dart';
import 'package:doctor_panel/providers/provider_list.dart';
import 'package:doctor_panel/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../utils/utils.dart';

class BasicInfoSetting extends StatefulWidget {
  final int userId;
  final List<DoctorTitleModel> doctorTitleList;
  final bool isProfileOnProgress;
  final bool isProfessionProfileCompleted;

  const BasicInfoSetting({
    Key? key,
    required this.userId,
    required this.doctorTitleList,
    this.isProfileOnProgress = false,
    required this.isProfessionProfileCompleted,
  }) : super(key: key);
  @override
  _BasicInfoSettingState createState() => _BasicInfoSettingState();
}

class _BasicInfoSettingState extends State<BasicInfoSetting> {
  final dateFormatterPattern = DateFormat("yyyy-MM-dd");

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rtlNameController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _feeController = TextEditingController();
  final _dobController = TextEditingController();
  final _freeServiceStartDateController = TextEditingController();
  final _freeServiceEndDateController = TextEditingController();

  late DoctorModel doctorModel;

  String defaultTitle = 'Dr';
  String defaultGender = 'Male';
  String _errorMessage = '';
  File? _image;
  final picker = ImagePicker();

  bool _freeCheck = false;

  late final ImageProvider _theImage;
  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;

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
    final chatUserResponse = await HttpService().getRequest(endPoint: BASIC_INFO);

    if (!chatUserResponse.error) {
      try {
        setState(() {
          doctorModel = DoctorModel.fromJson(chatUserResponse.data);
          _theImage = (doctorModel.user!.avatar != null
              ? NetworkImage(doctorModel.user!.avatar!)
              : AssetImage(doctorModel.user!.gender != null
                  ? GlobalVariable.DOCTOR_MALE
                  : GlobalVariable.DOCOTOR_FEMALE) as ImageProvider);
          _nameController.text = doctorModel.user?.name ?? '';
          _rtlNameController.text = doctorModel.user?.rtlName ?? '';
          _licenseNumberController.text = doctorModel.licenseNo ?? '';
          _dobController.text = doctorModel.user?.dob ?? '';
          _feeController.text = doctorModel.fee != null ? doctorModel.fee.toString() : '';
          defaultTitle = doctorModel.title?.title != null ? doctorModel.title!.title : 'Dr';
          _freeServiceStartDateController.text =
              doctorModel.isFreeService! ? (doctorModel.freeServiceSchedule!.startAt ?? '') : '';
          _freeServiceEndDateController.text =
              doctorModel.isFreeService! ? (doctorModel.freeServiceSchedule!.endAt ?? '') : '';
          defaultTitle = doctorModel.title?.title != null ? doctorModel.title!.title : 'Dr';
          defaultGender = (doctorModel.user?.gender != null ? doctorModel.user!.gender : 'Male')!;

          // _isFreeServiceActivated = doctorModel.isFreeService!;
          _freeCheck = doctorModel.isFreeService!;
          _isLoading = false;
        });
      } catch (e) {
        print('value of e -----');
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
        if (chatUserResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = chatUserResponse.errorMessage!;
        }
      });
    }
  }

  void _theSetState(String theMessage) {
    _errorMessage = theMessage;
  }

  Future<void> _saveBasicInfo(BuildContext ctx) async {
    final _isFormValid = _formValidation();
    if (_isFormValid) {
      bool _isDialogRunning = false;
      showDialog(
          context: ctx,
          barrierDismissible: false,
          builder: (_) {
            _isDialogRunning = true;
            return const ProgressPopupDialog();
          });
      try {
        String avatarName = 'no_avatar';
        if (_image != null) {
          avatarName = _image!.path.split('/').last;
        }

        FormData body = FormData.fromMap({
          'avatar': avatarName == 'no_avatar'
              ? 'no_avatar'
              : await MultipartFile.fromFile(
                  _image!.path,
                  filename: avatarName,
                ),
          'name': _nameController.text,
          'rtl_name': _rtlNameController.text,
          'license_number': _licenseNumberController.text,
          'fee': _feeController.text,
          'dob': _dobController.text,
          'is_free_service': _freeCheck,
          'free_service_start': _freeServiceStartDateController.text,
          'free_service_end': _freeServiceEndDateController.text,
          'doctor_title': defaultTitle,
          'gender': defaultGender,
        });
        var scheduleResponse = await HttpService().postRequest(
          data: body,
          endPoint: VIEW_DOCTOR_PROFILE_PLUS + "${widget.userId}/",
        );
        Navigator.of(ctx).pop();
        _isDialogRunning = false;

        if (!scheduleResponse.error) {
          toastSnackBar('Saved Successfully');
          // DefaultTabController.of(context)!.animateTo(1);
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
  }

  bool _formValidation() {
    print('insid eht _formValidation');
    final _isValid = _formKey.currentState!.validate();
    _theSetState('');
    if (_isValid) {
      print('insdid eht isValid');
      if (_nameController.text.trim() == '' ||
          _nameController.text.length < 3 ||
          _rtlNameController.text.trim() == '' ||
          _rtlNameController.text.length < 3) {
        _theSetState('Name field should not be empty or less than three characters');
        return false;
      }

      if (_licenseNumberController.text.trim() == '') {
        _theSetState('License number should not be empty');
        return false;
      }

      final isPositiveInteger = int.tryParse(_feeController.text) ?? 351;

      if (_feeController.text.trim() == '' || isPositiveInteger < 0 || isPositiveInteger == 351) {
        // check this condition whether it is true of not
        _theSetState('Fee should not be empty, letters or negative numebrs');
        return false;
      }

      if (_freeServiceStartDateController.text.trim() == '' && _freeCheck) {
        _theSetState('Free service start date should not be empty');
        return false;
      }

      if (_freeServiceEndDateController.text.trim() == '' && _freeCheck) {
        _theSetState('Free service end date should not be empty');
        return false;
      }

      if (_dobController.text.trim() == '') {
        _theSetState('Date of birth should not be empty');
        return false;
      }

      if (_freeCheck) {
        final startDate = DateTime.tryParse(_freeServiceStartDateController.text);
        final endDate = DateTime.tryParse(_freeServiceEndDateController.text);

        if (startDate!.isAfter(endDate!)) {
          _theSetState('Start date should be before the end date in Free Checkup Service');
          return false;
        }
      }
    }
    return true;
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
                            _userProfile(),
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              width: mQuery.width * 0.75,
                              height: 50.0,
                              child: TextFormField(
                                enabled: widget.isProfessionProfileCompleted ? false : true,
                                controller: _nameController,
                                decoration: textFieldDesign(context, 'Full Name'),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              width: mQuery.width * 0.75,
                              height: 50.0,
                              child: TextFormField(
                                enabled: widget.isProfessionProfileCompleted ? false : true,
                                controller: _rtlNameController,
                                decoration: textFieldDesign(context, 'Full Name(Farsi/Pashto)'),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              width: mQuery.width * 0.75,
                              height: 50.0,
                              child: TextFormField(
                                enabled: widget.isProfessionProfileCompleted ? false : true,
                                controller: _licenseNumberController,
                                decoration: textFieldDesign(context, 'License Number'),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              width: mQuery.width * 0.75,
                              height: 50.0,
                              child: TextFormField(
                                enabled: widget.isProfessionProfileCompleted ? false : true,
                                controller: _feeController,
                                keyboardType: TextInputType.number,
                                decoration: textFieldDesign(context, 'Fee (AFN)'),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              width: mQuery.width * 0.70,
                              height: 50,
                              child: CheckboxListTile(
                                  value: _freeCheck,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                  title: Text(
                                    'Active Free Checkup Service',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                  activeColor: Colors.blue,
                                  onChanged: (newVal) {
                                    if (!widget.isProfessionProfileCompleted) {
                                      if (doctorModel.isFreeService!) {
                                        infoNoOkDialogue(
                                            context,
                                            'You cannot change this setting before the due date or contact admin\nPhone: +93 799 858388\nEmail: admin@doctorplus.af',
                                            'Free Checkup Service');
                                      } else {
                                        if (_freeCheck) {
                                          setState(() {
                                            _freeCheck = newVal!;
                                          });
                                        } else {
                                          questionDialogue(
                                              context,
                                              "Note: Click OK to start 'Free Checkup Serivce' for a period time of your choice. Please remember, after the service activation you cannot change its due date before it is completed or request the admin.",
                                              'Active Free Checkup Service', () {
                                            setState(() {
                                              _freeCheck = newVal!;
                                            });
                                          });
                                        }
                                      }
                                    }
                                  }),
                            ),
                            if (_freeCheck)
                              Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 15),
                                    width: mQuery.width * 0.75,
                                    height: 50.0,
                                    child: DateTimeField(
                                      enabled: !doctorModel.isFreeService!,
                                      controller: _freeServiceStartDateController,
                                      decoration:
                                          textFieldDesign(context, 'Free Service Start Date'),
                                      format: dateFormatterPattern,
                                      onShowPicker: (context, currentValue) {
                                        return showDatePicker(
                                          context: context,
                                          firstDate: DateTime(DateTime.now().year - 1),
                                          initialDate: currentValue ?? DateTime.now(),
                                          lastDate: DateTime(DateTime.now().year + 1),
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 15),
                                    width: mQuery.width * 0.75,
                                    height: 50.0,
                                    child: DateTimeField(
                                      enabled: !doctorModel.isFreeService!,
                                      controller: _freeServiceEndDateController,
                                      decoration: textFieldDesign(context, 'Free Service End Date'),
                                      format: dateFormatterPattern,
                                      onShowPicker: (context, currentValue) {
                                        return showDatePicker(
                                          context: context,
                                          firstDate: DateTime(DateTime.now().year - 1),
                                          initialDate: currentValue ?? DateTime.now(),
                                          lastDate: DateTime(DateTime.now().year + 1),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            Container(
                              width: mQuery.width * 0.75,
                              margin: const EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _infoDropdown(widget.doctorTitleList, defaultTitle, 'title'),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  _infoDropdown(
                                      GlobalDummyData.GENDER_LIST, defaultGender, 'gender'),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              width: mQuery.width * 0.75,
                              height: 50.0,
                              child: DateTimeField(
                                enabled: widget.isProfessionProfileCompleted ? false : true,
                                controller: _dobController,
                                decoration: textFieldDesign(context, 'Date Of Birth'),
                                format: dateFormatterPattern,
                                onShowPicker: (context, currentValue) {
                                  return showDatePicker(
                                      context: context,
                                      firstDate: DateTime(1965),
                                      initialDate: currentValue ?? DateTime.now(),
                                      lastDate: DateTime.now());
                                },
                              ),
                            ),
                            if (widget.isProfileOnProgress)
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                width: mQuery.width * 0.90,
                                padding: EdgeInsets.symmetric(horizontal: 25),
                                child: Text(
                                  'Note: Your profile is submitted for review. You can edit your info until the review is completed',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue[900]),
                                  textAlign: TextAlign.center,
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
                            if (!widget.isProfessionProfileCompleted)
                              customElevatedButton(context, () {
                                _saveBasicInfo(context);
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

  Card _userProfile() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      elevation: 10.0,
      child: GestureDetector(
        onTap: () {
          if (!widget.isProfessionProfileCompleted) _showModalBottomSheet();
        },
        child: Container(
          height: 135,
          width: 135,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: _image != null
                ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                : DecorationImage(image: _theImage),
            color: Colors.white,
            border: Border.all(color: Palette.blueAppBar, width: 2.5),
          ),
          child: Align(
            alignment: Alignment(1.0, 1.0),
            child: Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              child: Container(
                decoration: BoxDecoration(
                    color: Palette.blueAppBar,
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2,
                      color: Colors.white,
                    )),
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  Icons.add_a_photo_outlined,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Expanded _infoDropdown(theList, defaultVal, dropType) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Palette.blueAppBar, width: 1.5),
        ),
        child: DropdownButton<String>(
          value: defaultVal,
          icon: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Icon(
              Icons.keyboard_arrow_down_sharp,
            ),
          ),
          iconSize: 28,
          isExpanded: true,
          elevation: 16,
          style: TextStyle(color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.w500),
          dropdownColor: Palette.imageBackground,
          underline: SizedBox.shrink(),
          onChanged: (String? newValue) {
            if (!widget.isProfessionProfileCompleted) {
              setState(() {
                if (dropType == 'title') {
                  defaultTitle = newValue!;
                } else {
                  defaultGender = newValue!;
                }
              });
            }
          },
          items: theList.map<DropdownMenuItem<String>>((value) {
            return DropdownMenuItem<String>(
                value: dropType == 'title' ? value.title : value,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    dropType == 'title' ? value.title : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ));
          }).toList(),
        ),
      ),
    );
  }

  Future getImage(String mediaType) async {
    var pickedFile;
    if (mediaType == 'camera') {
      pickedFile = await picker.getImage(
          source: ImageSource.camera,
          imageQuality: 65, // <- Reduce Image quality
          maxHeight: 300, // <- reduce the image size
          maxWidth: 300);
    } else {
      pickedFile = await picker.getImage(
          source: ImageSource.gallery,
          imageQuality: 65, // <- Reduce Image quality
          maxHeight: 300, // <- reduce the image size
          maxWidth: 300);
    }
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void _showModalBottomSheet() {
    final borderRaius = Radius.circular(15);
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: borderRaius, topRight: borderRaius),
        ),
        context: context,
        builder: (context) {
          return SafeArea(
            top: false,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ListTile(
                    onTap: () async {
                      Navigator.of(context).pop();
                      getImage('camera');
                    },
                    leading: Icon(
                      Icons.camera_alt_outlined,
                      color: Palette.blueAppBar,
                    ),
                    title: Text('Camera'),
                    horizontalTitleGap: 0,
                    minLeadingWidth: 35,
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).pop();
                      getImage('gallery');
                    },
                    horizontalTitleGap: 0,
                    minLeadingWidth: 35,
                    leading: Icon(
                      Icons.drive_file_move_outline,
                      color: Palette.blueAppBar,
                    ),
                    title: Text('Gallery'),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

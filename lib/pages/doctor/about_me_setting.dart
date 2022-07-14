import 'package:dio/dio.dart';
import 'package:doctor_panel/providers/provider_list.dart';
import 'package:doctor_panel/widgets/widgets.dart';
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import '../../utils/utils.dart';
import '../screens.dart';

class AboutMeSetting extends StatefulWidget {
  final bool isProfessionalProfileCompleted;

  const AboutMeSetting({Key? key, required this.isProfessionalProfileCompleted}) : super(key: key);
  @override
  _AboutMeSettingState createState() => _AboutMeSettingState();
}

class _AboutMeSettingState extends State<AboutMeSetting> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _farsiBioController = TextEditingController();
  final _pashtoBioController = TextEditingController();

  String _errorMessage = '';
  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _aboutMe();
  }

  void _aboutMe() async {
    setState(() {
      _isLoading = true;
    });
    var aboutObject = await HttpService().getRequest(endPoint: BIO_GET_POST);

    if (!aboutObject.error) {
      try {
        // About Me
        setState(() {
          _bioController.text = aboutObject.data[0]['english_bio'];
          _farsiBioController.text = aboutObject.data[0]['farsi_bio'];
          _pashtoBioController.text = aboutObject.data[0]['pashto_bio'];
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
        if (aboutObject.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = aboutObject.errorMessage!;
        }
      });
    }
  }

  void _theSetState(String theMessage) {
    _errorMessage = theMessage;
  }

  Future<void> _saveBasicInfo(BuildContext ctx) async {
    final isFormValid = _formValidation();
    if (!isFormValid) {
      return;
    }
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
        'english_bio': _bioController.text,
        'farsi_bio': _farsiBioController.text,
        'pashto_bio': _pashtoBioController.text,
      });

      var scheduleResponse = await HttpService().postRequest(
        data: body,
        endPoint: BIO_GET_POST,
      );
      Navigator.of(ctx).pop();
      _isDialogRunning = false;

      if (!scheduleResponse.error) {
        FocusScope.of(context).unfocus();
        toastSnackBar('Saved Successfully');
        // DefaultTabController.of(context)!.animateTo(6);
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

  bool _formValidation() {
    final _isValid = _formKey.currentState!.validate();
    _theSetState('');
    if (_isValid) {
      print('insdid eht isValid');
      if (_bioController.text.trim() == '') {
        _theSetState('English bio field should not be empty');
        return false;
      }

      if (_farsiBioController.text.trim() == '') {
        _theSetState('Dari bio field should not be empty');
        return false;
      }

      if (_pashtoBioController.text.trim() == '') {
        _theSetState('Pashto bio field should not be empty');
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return SafeArea(
      top: false,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
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
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              width: mQuery.width * 0.75,
                              child: TextFormField(
                                enabled: widget.isProfessionalProfileCompleted ? false : true,
                                maxLines: 7,
                                controller: _bioController,
                                decoration: textFieldDesign(context, 'Biography'),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              width: mQuery.width * 0.75,
                              child: TextFormField(
                                enabled: widget.isProfessionalProfileCompleted ? false : true,
                                maxLines: 7,
                                controller: _farsiBioController,
                                decoration: textFieldDesign(context, 'Biography (Farsi)'),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              width: mQuery.width * 0.75,
                              child: TextFormField(
                                enabled: widget.isProfessionalProfileCompleted ? false : true,
                                maxLines: 7,
                                controller: _pashtoBioController,
                                decoration: textFieldDesign(context, 'Biography (Pashto)'),
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
        ),
      ),
    );
  }
}

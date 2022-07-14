import 'package:dio/dio.dart';
import 'package:doctor_panel/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../models/dummy_data.dart';
import '../utils/utils.dart';
import '../pages/screens.dart';
import '../providers/provider_list.dart';
import '../models/model_list.dart';

class SignupLogin extends StatefulWidget {
  @override
  _SignupLoginState createState() => _SignupLoginState();
}

class _SignupLoginState extends State<SignupLogin> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;
  bool isLoading = false;
  String errorMessage = '';

  List<DoctorTitleModel> _doctorTitleList = [];

  String defaultTitle = 'Dr.';
  String defaultGender = 'Male';

  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      _getServerData();
    });
  }

  Future<void> _getServerData() async {
    setState(() {
      _isLoading = true;
    });
    var doctorTitleResponse =
        await HttpService().getRequest(endPoint: DOCTOR_TITLE_URL, isAuth: false);

    if (!doctorTitleResponse.error) {
      try {
        setState(() {
          if (doctorTitleResponse.data is List && doctorTitleResponse.data.length != 0) {
            doctorTitleResponse.data.forEach((response) {
              final titleObject = DoctorTitleModel.fromJson(response);
              _doctorTitleList.add(titleObject);
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
        if (doctorTitleResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = doctorTitleResponse.errorMessage!;
        }
      });
    }
  }

  @override
  void dispose() {
    _clearControllers('login');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
        // backgroundColor: Colors.white.withAlpha(245),
        backgroundColor: Palette.darkPurple,
        body: Builder(
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Center(
                      child: Center(
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          child: Container(
                            height: 170,
                            width: 170,
                            decoration: BoxDecoration(
                              // shape: BoxShape.circle,
                              color: Palette.darkPurple,
                            ),
                            child: Container(
                              height: 150,
                              // width: mQuery.width,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(GlobalVariable.LOGIN_BACKGROUND),
                                    fit: BoxFit.fitHeight),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'DOCTOR PRACTICE',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Palette.imageBackground),
                    ),
                    if (!isLogin)
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          // color: Palette.lighterBlue,
                          child: TextField(
                            controller: _nameController,
                            textAlign: TextAlign.center,
                            decoration: _signupLogin(
                                context, 'Full Name', _nameController, Icons.person_outline),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        // color: Palette.lighterBlue,
                        child: TextField(
                          controller: _phoneController,
                          textAlign: TextAlign.center,
                          decoration: _signupLogin(
                              context, 'Phone(07XXXXXXXX)', _phoneController, Icons.phone_outlined),
                        ),
                      ),
                    ),
                    if (!isLogin)
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _infoDropdown(_doctorTitleList, defaultTitle, 'title'),
                            SizedBox(
                              width: 10.0,
                            ),
                            _infoDropdown(GlobalDummyData.GENDER_LIST, defaultGender, 'gender'),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        // color: Palette.lighterBlue,
                        child: TextField(
                          controller: _passwordController,
                          textAlign: TextAlign.center,
                          decoration: _signupLogin(
                              context, 'Password', _passwordController, Icons.lock_outline),
                        ),
                      ),
                    ),
                    if (!isLogin)
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          // color: Palette.lighterBlue,
                          child: TextField(
                            controller: _confirmPassController,
                            textAlign: TextAlign.center,
                            decoration: _signupLogin(context, 'Confirm Password',
                                _confirmPassController, Icons.lock_open_outlined),
                          ),
                        ),
                      ),
                    if (errorMessage != '')
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (isLogin)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: TextButton(
                                onPressed: () => Navigator.push(
                                    context, MaterialPageRoute(builder: (_) => ForgetPassword())),
                                child: Text(
                                  'Forget Password?',
                                  style: TextStyle(fontSize: 16, color: Colors.blue),
                                )),
                          )
                        ],
                      ),
                    Container(
                      margin: EdgeInsets.only(top: !isLogin ? 10 : 0),
                      width: mQuery.width,
                      height: 45,
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: ElevatedButton(
                        onPressed: () {
                          if (isLogin) {
                            _loginButton(context);
                          } else {
                            _registerButton(context);
                          }
                        },
                        child: Text(isLogin ? 'LOGIN NOW' : 'REGISTER'),
                        style: ElevatedButton.styleFrom(
                            // elevation: 8.0,
                            onPrimary: Colors.white,
                            textStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                            primary: Palette.blueAppBar,
                            shape:
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLogin ? 'Don\'t have account?' : 'Already have account?',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isLogin = !isLogin;
                              errorMessage = '';
                            });
                          },
                          child: Text(
                            isLogin ? 'Signup Now!' : 'Login Now!',
                            style: TextStyle(fontSize: 17, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        child: dashedLine(Colors.blue)),
                    SizedBox(
                      height: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              textStyle: TextStyle(fontSize: 17),
                              primary: Palette.blueAppBar,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            icon: Icon(
                              MdiIcons.facebook,
                            ),
                            label: Text('Facebook'),
                          ),
                        ),
                        SizedBox(
                          width: 25,
                        ),
                        Container(
                          width: 150,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              textStyle: TextStyle(fontSize: 17),
                              primary: Palette.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            icon: Icon(
                              MdiIcons.google,
                            ),
                            label: Text('Google'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }

  void _clearControllers(String operation) {
    // FocusScope.of(context).unfocus();
    if (operation != 'register') {
      _phoneController.clear();
    }
    _nameController.clear();
    _passwordController.clear();
    _confirmPassController.clear();
  }

  void _loginButton(BuildContext ctx) async {
    final isFormValid = _formValidation('login');
    if (isFormValid) {
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
          'phone': _phoneController.text,
          'password': _passwordController.text,
        });
        var loginResponse =
            await HttpService().postRequest(data: body, endPoint: LOGIN_URL, isAuth: false);

        Navigator.of(ctx).pop();
        _isDialogRunning = false;

        if (!loginResponse.error) {
          try {
            if (loginResponse.data['is_doctor']) {
              if (loginResponse.data['is_active']) {
                SharedPref().setToken(loginResponse.data['access']);
                SharedPref().dashboardBriefSetter(loginResponse.data);
                if (loginResponse.data['is_profile_completed']) {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => NavScreen()));
                } else {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileSetting(
                                isProfessionalProfileCompleted: false,
                              )));
                  toastSnackBar('Your profile is incomplete. Please complete it');
                }
              } else {
                questionDialogue(
                    context,
                    'If you want to activate your account. We will send you an OTP to your ${_phoneController.text} to verify it. Press Ok to receive the OTP.',
                    'Account Is Not Activated!',
                    () => createOTP(context, _phoneController.text, 'verify'));
              }
            } else {
              infoNoOkDialogue(
                  context,
                  'Enter your credential properly. If forgot, try forget password option',
                  'Wrong Credentials');
            }
          } catch (e) {
            infoNoOkDialogue(context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS,
                GlobalVariable.ERROR_MESSAGE_TITLE);
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
  }

  void _registerButton(BuildContext ctx) async {
    final isFormValid = _formValidation('register');
    if (isFormValid) {
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
          'phone': _phoneController.text,
          "full_name": _nameController.text,
          "gender": defaultGender,
          "blood_group": 'A+',
          "user_type": "Doctor",
          "title": defaultTitle,
          'password': _passwordController.text,
          "confirm_password": _confirmPassController.text
        });
        var loginResponse =
            await HttpService().postRequest(data: body, endPoint: REGISTER_URL, isAuth: false);
        Navigator.of(ctx).pop();
        _isDialogRunning = false;

        if (!loginResponse.error) {
          createOTP(context, _phoneController.text, 'verify');
          toastSnackBar('Registered Successfully');
          _clearControllers('register');
        } else {
          print('value of the error message ====');
          print(loginResponse.error);
          print(loginResponse.errorMessage);
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

  bool _formValidation(String operation) {
    final isFormValid = _formKey.currentState!.validate();
    _theSetState('');

    if (isFormValid) {
      if (operation == 'login' || operation == 'register') {
        if (_phoneController.text == '') {
          _theSetState('Phone number should not be empty');
          return false;
        }

        if (double.tryParse(_phoneController.text) == null) {
          _theSetState('Phone should be digits');
          return false;
        }

        if (_phoneController.text.length < 10 || _phoneController.text.length > 10) {
          _theSetState('Phone number is not valid, should be 10 digits');
          return false;
        }

        if (int.tryParse(_phoneController.text) == null) {
          _theSetState('Please enter valid phone number');
          return false;
        }

        if (_passwordController.text == '') {
          _theSetState('Password field should not be empty');
          return false;
        }

        if (_passwordController.text.length < 6 || _passwordController.text.length > 20) {
          _theSetState(
              'Password should not be less than 6 or greater than 20 characters or digits');
          return false;
        }
      }
      if (operation == 'register') {
        if (_nameController.text == '' || _nameController.text.length < 3) {
          _theSetState('Name field should not be empty or less than three characters');
          return false;
        }
        if (_confirmPassController.text == '') {
          _theSetState('Password confirmation should not be empty');
          return false;
        }

        if (_passwordController.text != _confirmPassController.text) {
          _theSetState('Your passwords do not match');
          return false;
        }
      }
    }

    return true;
  }

  void _theSetState(String theMessage) {
    setState(() {
      errorMessage = theMessage;
    });
  }

  Expanded _infoDropdown(theList, defaultVal, dropType) {
    return Expanded(
      child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Palette.lighterBlue,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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
            style: TextStyle(color: Colors.black54, fontSize: 17.0, fontWeight: FontWeight.w500),
            dropdownColor: Palette.imageBackground,
            underline: SizedBox.shrink(),
            onChanged: (String? newValue) {
              setState(() {
                if (dropType == 'title') {
                  defaultTitle = newValue!;
                  print(newValue);
                } else {
                  defaultGender = newValue!;
                }
              });
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
      ),
    );
  }

  InputDecoration _signupLogin(BuildContext context, String theHintText,
      TextEditingController theController, IconData preIcon) {
    return InputDecoration(
      fillColor: Palette.lighterBlue,
      focusColor: Colors.white,
      contentPadding: EdgeInsets.all(10),
      filled: true,
      suffixIcon: IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          theController.clear();
          FocusScope.of(context).unfocus();
        },
      ),
      prefixIcon: Icon(preIcon),
      hintText: theHintText,
      hintStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.grey[550]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    );
  }
}

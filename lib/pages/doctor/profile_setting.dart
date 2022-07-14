import 'dart:io';

import 'package:doctor_panel/models/model_list.dart';
import 'package:doctor_panel/providers/provider_list.dart';
import 'package:flutter/material.dart';
import '../../utils/utils.dart';
import '../screens.dart';

class ProfileSetting extends StatefulWidget {
  late bool isProfessionalProfileCompleted;

  ProfileSetting({Key? key, this.isProfessionalProfileCompleted = true}) : super(key: key);
  @override
  _ProfileSettingState createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {
  List<DoctorTitleModel> _doctorTitleList = <DoctorTitleModel>[];
  int _doctorId = 0;
  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;
  bool _isProfileOnProgress = false;
  String _errorMessage = '';
  @override
  void initState() {
    super.initState();
    _getTitle();
  }

  Future<void> _getTitle() async {
    setState(() {
      _isLoading = true;
    });
    // doctor id
    final theVal = await SharedPref().dashboardBrief();
    try {
      _doctorId = int.tryParse(theVal['id']) ?? 0;
      _isProfileOnProgress = theVal['is_profile_on_progress'];
    } catch (e) {
      _doctorId = 0;
      _isProfileOnProgress = false;
    }

    //title
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
            _isLoading = false;
          }
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

  _returnBackBtn() {
    !widget.isProfessionalProfileCompleted
        ? null
        : Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => NavScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _returnBackBtn();
        return false;
      },
      child: DefaultTabController(
        length: 8,
        child: Scaffold(
            backgroundColor: Palette.scaffoldBackground,
            appBar: AppBar(
              leading: widget.isProfessionalProfileCompleted
                  ? IconButton(
                      icon:
                          Platform.isAndroid ? Icon(Icons.arrow_back) : Icon(Icons.arrow_back_ios),
                      onPressed: () => _returnBackBtn())
                  : null,
              title: Text(
                "Profile Settings",
                style: TextStyle(
                    fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
              ),
              backgroundColor: Palette.blueAppBar,
              actions: [if (!widget.isProfessionalProfileCompleted) _logoutButton()],
              bottom: TabBar(
                isScrollable: true,
                unselectedLabelColor: Colors.yellowAccent,
                labelColor: Palette.blueAppBar,
                indicatorSize: TabBarIndicatorSize.label,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: Palette.tabGradient,
                  // color: Colors.white,
                  color: Palette.scaffoldBackground,
                ),
                tabs: [
                  patientProfileTab('Basic Info', context),
                  patientProfileTab('Care Services', context),
                  patientProfileTab('Clinic Info', context),
                  patientProfileTab('Education', context),
                  patientProfileTab('Experience', context),
                  patientProfileTab('About Me', context),
                  patientProfileTab('Award', context),
                  patientProfileTab('Submission', context),
                ],
              ),
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
                      errorTitle: 'Unknown Error. Try again later',
                      errorDetail: _errorMessage,
                    );
                  }
                }
                return TabBarView(
                  children: [
                    BasicInfoSetting(
                      userId: _doctorId,
                      doctorTitleList: _doctorTitleList,
                      isProfileOnProgress: _isProfileOnProgress,
                      isProfessionProfileCompleted: widget.isProfessionalProfileCompleted,
                    ),
                    CareServiceSetting(
                        isProfessionalProfileCompleted: widget.isProfessionalProfileCompleted),
                    ClinicInfoSetting(
                        doctorId: _doctorId,
                        isProfessionalProfileCompleted: widget.isProfessionalProfileCompleted),
                    EducationSetting(
                        isProfessionalProfileCompleted: widget.isProfessionalProfileCompleted),
                    ExperienceSetting(
                        isProfessionalProfileCompleted: widget.isProfessionalProfileCompleted),
                    AboutMeSetting(
                        isProfessionalProfileCompleted: widget.isProfessionalProfileCompleted),
                    AwardSetting(
                        isProfessionalProfileCompleted: widget.isProfessionalProfileCompleted),
                    ProfileSubmission(
                      isProfileOnProgress: _isProfileOnProgress,
                      isProfessionalProfileCompleted: widget.isProfessionalProfileCompleted,
                      theFunc: (bool toggler, String operation) {
                        print('the paramter funciton is getting clalled ');
                        print(operation);
                        print(toggler);
                        setState(() {
                          if (operation == 'request') {
                            widget.isProfessionalProfileCompleted = false;
                            _isProfileOnProgress = false;
                          } else {
                            widget.isProfessionalProfileCompleted = false;
                            _isProfileOnProgress = true;
                          }
                        });
                      },
                    ),
                  ],
                );
              },
            )),
      ),
    );
  }

  PopupMenuButton _logoutButton() {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        questionDialogue(context, 'Do you really want to logout?', 'Logout', () {
          SharedPref().logout();

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SignupLogin()));
        });
      },
      icon: Icon(Icons.logout),
      color: Palette.imageBackground,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'Logout',
          child: Text('Logout'),
        ),
      ],
    );
  }
}

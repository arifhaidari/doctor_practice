import 'pages/screens.dart';
import 'utils/utils.dart';

import './utils/shared_pref.dart';
import 'package:flutter/material.dart';
import './pages/nav_screen.dart';
import 'providers/provider_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Doctor Practice',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder(
          future: SharedPref().getToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return StartSplashScreen();
            }
            if (snapshot.hasError) {
              return ErrorPlaceHolderPage(
                  isStartPage: true,
                  errorDetail: 'Check your internet connection and try again',
                  errorTitle: 'Uknown Error');
            }
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                if (snapshot.data == '') {
                  return SignupLogin();
                }
              }
            }
            return FutureBuilder(
              future: HttpService().getRequest(endPoint: USER_BASIC_INFO, isAuth: true),
              builder: (context, AsyncSnapshot<APIResponse> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return StartSplashScreen();
                }
                if (snapshot.hasError) {
                  return ErrorPlaceHolderPage(
                      isStartPage: true,
                      errorDetail: 'Check your internet connection and try again',
                      errorTitle: 'Uknown Error');
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.error) {
                      if (snapshot.data!.errorMessage == NO_INTERNET_CONNECTION) {
                        return ErrorPlaceHolderPage(
                            isStartPage: true,
                            errorDetail:
                                'You have no internet connect. Turn on your data or connect to a wifi',
                            errorTitle: 'Internet Connection Error');
                      }
                      if (snapshot.data!.errorMessage == 'bad_authorization_header' ||
                          snapshot.data!.errorMessage == 'token_not_valid') {
                        return SignupLogin();
                      } else {
                        return ErrorPlaceHolderPage(
                          isStartPage: true,
                          errorDetail: snapshot.data!.errorMessage.toString(),
                          errorTitle: 'System Error',
                        );
                      }
                    }
                  }
                }
                SharedPref().dashboardBriefSetter(snapshot.data!.data);
                if (!snapshot.data!.data['is_profile_completed']) {
                  print('value fo the professional stauts---=-==-==-==-');
                  return ProfileSetting(
                    isProfessionalProfileCompleted: false,
                  );
                }
                return NavScreen();
              },
            );
          },
        ),
      ),
    );
  }
}

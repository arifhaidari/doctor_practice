import 'package:doctor_panel/models/model_list.dart';
import 'package:doctor_panel/providers/provider_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/utils.dart';
import '../pages/screens.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar('Settings'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _settingCard(
              context,
              'Pin Your Clinics On Map',
              'You can only pin your own clinic on map',
              CupertinoIcons.map_pin_ellipse,
              'clinic_setting',
            ),
            _settingCard(
              context,
              'Change Password',
              'Make sure you remember your current password',
              CupertinoIcons.lock,
              'change_password',
            ),
          ],
        ),
      ),
    );
  }

  Card _settingCard(
      BuildContext context, String title, String sub, IconData icon, String operation) {
    return Card(
      color: Palette.imageBackground,
      margin: EdgeInsets.only(top: 10, right: 15, left: 15),
      elevation: 5,
      child: ListTile(
        onTap: () {
          if (operation == 'clinic_setting') {
            _getClinicList(context);
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChangePassword(
                          operation: 'change_password',
                        )));
          }
        },
        leading: Icon(
          icon,
          size: 35,
          color: Palette.blueAppBar,
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          sub,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Future<void> _getClinicList(BuildContext context) async {
    List<ClinicModel> clinicList = <ClinicModel>[];

    //title
    var doctorTitleResponse =
        await HttpService().getRequest(endPoint: CLINIC_LIST + "?q=get_doctor_created_clinic");

    if (!doctorTitleResponse.error) {
      try {
        if (doctorTitleResponse.data is List && doctorTitleResponse.data.length != 0) {
          doctorTitleResponse.data.forEach((response) {
            final titleObject = ClinicModel.fromJson(response);
            clinicList.add(titleObject);
          });
        }
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SettingPinClinic(clinicModelList: clinicList)));
      } catch (e) {
        infoNoOkDialogue(
            context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    } else {
      infoNoOkDialogue(
          context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
    }
  }
}

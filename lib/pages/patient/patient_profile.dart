import 'package:doctor_panel/models/model_list.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../../utils/utils.dart';
import '../screens.dart';

class PatientProfile extends StatefulWidget {
  final PatientModel patientModel;

  const PatientProfile({Key? key, required this.patientModel}) : super(key: key);
  @override
  _PatientProfileState createState() => _PatientProfileState();
}

class _PatientProfileState extends State<PatientProfile> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Palette.scaffoldBackground,
        appBar: AppBar(
          title: Text(
            "Patient Profile",
            style:
                TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Palette.blueAppBar,
          bottom: TabBar(
            // isScrollable: true,
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
              patientProfileTab('Overview', context),
              patientProfileTab('Appts', context),
              patientProfileTab('Records', context),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PatientOverview(
              patientModel: widget.patientModel,
            ),
            PatientApptSlot(
              patientId: widget.patientModel.user!.id ?? 0,
            ),
            MedicalRecord(
              patientId: widget.patientModel.user!.id ?? 0,
            ),
            // FamilyMember(),
          ],
        ),
      ),
    );
  }
}

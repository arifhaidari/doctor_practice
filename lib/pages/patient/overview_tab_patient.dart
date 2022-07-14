// import 'package:doctor_panel/utils/utils.dart';
// import 'package:doctor_panel/widgets/widgets.dart';
import 'package:doctor_panel/models/model_list.dart';
import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

class PatientOverview extends StatelessWidget {
  final PatientModel patientModel;

  const PatientOverview({Key? key, required this.patientModel}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PatientCard(
            patientModel: patientModel,
            isViewProfile: true,
          ),
        ],
      ),
    );
  }
}

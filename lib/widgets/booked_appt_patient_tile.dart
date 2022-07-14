import 'package:auto_size_text/auto_size_text.dart';
import 'package:doctor_panel/models/model_list.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../providers/provider_list.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'package:flutter/material.dart';

class BookedApptPatientTile extends StatelessWidget {
  final BookedApptModel bookedApptModel;
  final Row buttonWidget;
  final bool isAppt;
  const BookedApptPatientTile(
      {Key? key, required this.bookedApptModel, required this.buttonWidget, this.isAppt = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.only(top: 5, bottom: 8),
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: EdgeInsets.only(top: 8, right: 8, left: 8),
        width: mQuery.width * 0.94,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => getPatientUserDetail(bookedApptModel.patientId ?? 0, context),
                    child: ProfileAvatarSquare(
                      avatarLink: MEDIA_LINK + bookedApptModel.avatar!,
                      gender: bookedApptModel.gender ?? 'Male',
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              getPatientUserDetail(bookedApptModel.patientId ?? 0, context),
                          child: tileText("${bookedApptModel.patientName}", 'patient_name'),
                        ),
                        tileText("Date: ${bookedApptModel.apptDate}", 'other'),
                        tileText(
                            "Duration: ${bookedApptModel.startApptTime!.substring(0, 5)} - ${bookedApptModel.endApptTime!.substring(0, 5)}",
                            'other'),
                        if (bookedApptModel.city != null || bookedApptModel.city != '')
                          tileText("${bookedApptModel.city}, ${bookedApptModel.district}", 'other'),
                        if (bookedApptModel.city == null) tileText("Unknown Address", 'other'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            if (isAppt)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    MdiIcons.hospitalBuilding,
                    color: Palette.blueAppBar,
                    size: 20,
                  ),
                  Expanded(
                    child: AutoSizeText(
                      ' ${bookedApptModel.clinicName}',
                      maxLines: 1,
                      minFontSize: 12,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            SizedBox(
              height: 5,
            ),
            dashedLine(Palette.blueAppBar),
            buttonWidget,
          ],
        ),
      ),
    );
  }
}

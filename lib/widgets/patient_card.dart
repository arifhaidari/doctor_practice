import 'package:auto_size_text/auto_size_text.dart';
import 'package:doctor_panel/models/model_list.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../utils/utils.dart';
import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import '../pages/screens.dart';

class PatientCard extends StatelessWidget {
  const PatientCard({
    Key? key,
    required this.patientModel,
    this.isViewProfile = false,
  }) : super(key: key);

  // final Size mQuery;
  final isViewProfile;
  final PatientModel patientModel;

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.only(top: 5, bottom: isViewProfile ? 5 : 10, right: 0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: EdgeInsets.all(8),
        width: mQuery.width * 0.94,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (!isViewProfile)
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // if (!isViewProfile)
                    Text(
                      'Booked Appts: ${patientModel.totalBookedAppt}',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                    ),

                    Expanded(
                      child: AutoSizeText(
                        patientModel.user?.address != null
                            ? "${patientModel.user?.address?.district?.name}, ${patientModel.user?.address?.city?.name}"
                            : "Address Unknown",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        textAlign: TextAlign.right,
                        minFontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            if (!isViewProfile)
              SizedBox(
                height: 3.0,
              ),
            if (!isViewProfile) dashedLine(Palette.lightGreen),
            if (!isViewProfile)
              SizedBox(
                height: 3.0,
              ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => isViewProfile
                        ? null
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PatientProfile(patientModel: patientModel))),
                    child: ProfileAvatarCircle(
                      imageUrl: patientModel.user?.avatar,
                      isActive: true,
                      radius: 80,
                      male: patientModel.user?.gender == "Male" ? true : false,
                    ),
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => isViewProfile
                                    ? null
                                    : Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PatientProfile(
                                                  patientModel: patientModel,
                                                ))),
                                child: AutoSizeText(
                                  patientModel.user?.name ?? 'Unknown',
                                  maxLines: 1,
                                  minFontSize: 16,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 3.0,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: AutoSizeText(
                                '${(patientModel.user?.age == "" || patientModel.user?.age == null) ? "Age Unknown" : patientModel.user?.age} ${patientModel.user?.age == "" ? "" : "Years"}, Blood Group (${patientModel.bloodGroup ?? "Unknown"})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                minFontSize: 14,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Palette.darkGreen),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 3.0,
                        ),
                        // if (!isFamilyMember)
                        GestureDetector(
                          onTap: () async {
                            final theToken = await SharedPref().getToken();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ChatMessage(
                                        theToken: theToken.toString(),
                                        chatUserModel: ChatUserModel(
                                            phone: patientModel.user!.phone ?? '',
                                            name: patientModel.user!.name,
                                            rtlName: patientModel.user!.name,
                                            avatar: patientModel.user?.avatar,
                                            lastText: LastChatText(timestamp: '')))));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Card(
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100)),
                                color: Palette.lighterBlue,
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(shape: BoxShape.circle),
                                  child: Center(
                                    child: Icon(
                                      MdiIcons.chatPlus,
                                      // Icons.chat,
                                      size: 22,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: AutoSizeText(
                                  patientModel.user?.phone ?? "No Phone",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  minFontSize: 15,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isViewProfile)
              Container(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 5.0, bottom: 5.0),
                child: Column(
                  children: [
                    cardDetailItem(
                        'Completed Appts No: ${patientModel.totalBookedAppt}', Icons.date_range),
                    cardDetailItem(
                        'Last Appointment: ${(patientModel.lastCompletedAppt == "" || patientModel.lastCompletedAppt == null) ? "No Completed Appt Yet" : patientModel.lastCompletedAppt}',
                        Icons.access_time),
                    cardDetailItem(
                        patientModel.user?.address != null
                            ? "${patientModel.user?.address?.district!.name ?? ''}, ${patientModel.user?.address?.city!.name ?? ''}"
                            : "Address Not Available",
                        Icons.room,
                        maxLine: 2),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}

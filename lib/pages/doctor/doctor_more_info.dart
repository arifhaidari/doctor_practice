import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/utils.dart';
import '../../models/model_list.dart';

class DoctorMoreInfo extends StatefulWidget {
  const DoctorMoreInfo({
    Key? key,
    required this.mQuery,
    required this.doctorModel,
  }) : super(key: key);

  final Size mQuery;
  final DoctorModel doctorModel;

  @override
  _DoctorMoreInfoState createState() => _DoctorMoreInfoState();
}

class _DoctorMoreInfoState extends State<DoctorMoreInfo> {
  int _moreTabIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _moreTabTitle(
                'Clinics',
                0,
              ),
              SizedBox(
                width: 2,
              ),
              _moreTabTitle('Education', 1),
              SizedBox(
                width: 2,
              ),
              _moreTabTitle('Experience', 2),
              SizedBox(
                width: 2,
              ),
              _moreTabTitle('Award', 3),
            ],
          ),
        ),
        _moreInfoBody(widget.mQuery, widget.doctorModel),
      ],
    );
  }

  Widget _moreTabTitle(String title, int theIndex) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _moreTabIndex = theIndex;
          });
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: _moreTabIndex == theIndex ? Palette.imageBackground : Colors.black26,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _moreInfoBody(mQuery, DoctorModel modelObject) {
    if (_moreTabIndex == 1) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: _educationTabBody(mQuery, modelObject.educationList ?? []),
      );
    }
    if (_moreTabIndex == 2) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: _experienceTabBody(mQuery, modelObject.experienceList ?? []),
      );
    }
    if (_moreTabIndex == 3) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: _awardTabBody(mQuery, modelObject.awardList ?? []),
      );
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: _clinicTabBody(mQuery, modelObject.clinicList ?? []),
    );
  }

  Widget _awardTabBody(mQuery, List<AwardModel>? awardList) {
    if (awardList == null || awardList.length < 0) {
      return Text('No Item');
    }
    return ListView.builder(
        itemCount: awardList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  awardList[index].awardName ?? "Unknown Award",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                ),
                SizedBox(
                  height: 3,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.check,
                      size: 22,
                    ),
                    Expanded(
                      child: Text(
                        awardList[index].awardYear.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 15, color: Palette.blueAppBar),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  Widget _experienceTabBody(mQuery, List<ExperienceModel>? experienceList) {
    if (experienceList == null || experienceList.length < 0) {
      return Text('No Item');
    }
    return ListView.builder(
        itemCount: experienceList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  experienceList[index].designation ?? "Unknown Designation",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                ),
                SizedBox(
                  height: 3,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.check,
                      size: 22,
                    ),
                    Expanded(
                      child: Text(
                        experienceList[index].hospitalName ?? "Unknown Hospital",
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 15, color: Palette.blueAppBar),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 25,
                    ),
                    Expanded(
                      child: Text(
                        '${experienceList[index].startDate ?? "Unknown Start Time"} - ${experienceList[index].endDate ?? "Unknown End Time"}',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  Widget _educationTabBody(mQuery, List<EducationModel>? educationList) {
    if (educationList == null || educationList.length < 0) {
      return Text('No Item');
    }

    return ListView.builder(
        itemCount: educationList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  educationList[index].degree!.name ?? "Unknown Degree",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                ),
                SizedBox(
                  height: 3,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.check,
                      size: 22,
                    ),
                    Expanded(
                      child: Text(
                        educationList[index].schoolName ?? "Unknown School",
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 15, color: Palette.blueAppBar),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 25,
                    ),
                    Expanded(
                      child: Text(
                        '${educationList[index].startDate ?? "Unknown Start Time"} - ${educationList[index].endDate ?? "Unknown End Time"}',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  Widget _clinicTabBody(mQuery, List<ClinicModel>? clinicList) {
    if (clinicList == null || clinicList.length < 0) {
      return Text('No Item');
    }
    return ListView.builder(
        itemCount: 2,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clinicList[index].clinicName ?? "Unknow Clinic Name",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                ),
                SizedBox(
                  height: 3,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_city,
                      color: Palette.blueAppBar,
                      size: 23,
                    ),
                    Expanded(
                      child: Text(
                        'Province/City: ${clinicList[index].city!.name ?? "Unknown City"}',
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_city,
                      color: Palette.blueAppBar,
                      size: 23,
                    ),
                    Expanded(
                      child: Text(
                        'District: ${clinicList[index].district!.name ?? "Unknown District"}',
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Palette.blueAppBar,
                      size: 23,
                    ),
                    Expanded(
                      child: Text(
                        clinicList[index].address ?? "Unknown Address",
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}

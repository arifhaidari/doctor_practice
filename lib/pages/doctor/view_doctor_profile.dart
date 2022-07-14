import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../providers/provider_list.dart';
import '../../providers/end_point.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../screens.dart';
import '../../models/model_list.dart';

class ViewDoctorProfile extends StatefulWidget {
  @override
  _ViewDoctorProfileState createState() => _ViewDoctorProfileState();
}

class _ViewDoctorProfileState extends State<ViewDoctorProfile> {
  bool favorito = false;

  bool _isUnknownError = false;
  bool _isConnectionError = false;
  bool _isLoading = false;
  String _errorMessage = '';

  late DoctorModel _doctorModel;
  late FeedbackDataModel _feedbackDataModel;

  late ImageProvider theImage;

  final borderRad =
      BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10));

  // List<Map<String, double>> _mapList = [
  //   {'lat': 34.53401150373386, 'lng': 69.1728845254006},
  //   {'lat': 34.53696709035473, 'lng': 69.19056250241701}
  // ];

  @override
  void initState() {
    super.initState();
    print('value of DRAWER_DATA');
    print(DRAWER_DATA['id']);
    _getData();
  }

  Future<void> _getData() async {
    setState(() {
      _isLoading = true;
    });
    //
    final _doctorProfileResponse = await HttpService()
        .getRequest(endPoint: VIEW_DOCTOR_PROFILE_PLUS + "${DRAWER_DATA['id']}/");

    if (!_doctorProfileResponse.error) {
      try {
        setState(() {
          _doctorModel = DoctorModel.fromJson(_doctorProfileResponse.data['doctor_dataset']);
          _feedbackDataModel =
              FeedbackDataModel.fromJson(_doctorProfileResponse.data['feedback_dataset']);
          theImage = (_doctorModel.user!.avatar != null
              ? NetworkImage(_doctorModel.user!.avatar!)
              : AssetImage(_doctorModel.user!.gender == 'Male'
                  ? GlobalVariable.DOCTOR_MALE
                  : GlobalVariable.DOCOTOR_FEMALE) as ImageProvider);

          _isLoading = false;
        });
      } catch (e) {
        print('value rof erororororor909099');
        print(e);
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
        if (_doctorProfileResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _doctorProfileResponse.errorMessage!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Palette.scaffoldBackground,
        body: Builder(
          builder: (BuildContext ctx) {
            if (_isLoading) {
              return const LoadingPlaceHolder();
            }
            if (_isUnknownError || _doctorModel == null || _isConnectionError) {
              if (_isConnectionError) {
                return const ErrorPlaceHolder(
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
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  // title: Text('Doctor Name'),
                  elevation: 0,
                  pinned: true,
                  // snap: true,
                  floating: true,
                  expandedHeight: 80.0,
                  backgroundColor: Palette.blueAppBar,
                  // collapsedHei3511
                  //ght: ,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      _doctorModel.user!.name ?? 'Uknown Doctor',
                      style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
                    ),
                    // background:
                  ),
                ),
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 130,
                            color: Palette.blueAppBar,
                          ),
                          Container(
                            height: 95,
                            decoration: const BoxDecoration(
                                color: Colors.transparent,
                                // color: Palette.red,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                          )
                        ],
                      ),
                      _profileAvatar(mQuery),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      // if (index == 0) {
                      //   return
                      // }
                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                theCircularIndicator(
                                  icon: Icons.star,
                                  text: "Overall\nExperience",
                                  thePercentage: _feedbackDataModel.overallExperience ?? 35.0,
                                ),
                                theCircularIndicator(
                                  icon: Icons.local_hospital,
                                  text: "Doctor\nCheckup",
                                  thePercentage: _feedbackDataModel.doctorCheckup ?? 35.0,
                                ),
                                theCircularIndicator(
                                  icon: Icons.people,
                                  text: "Staff\nBehavior",
                                  thePercentage: _feedbackDataModel.staffBehavior ?? 35.0,
                                ),
                                theCircularIndicator(
                                  icon: Icons.clean_hands,
                                  text: "Clinic\nEnvironment",
                                  thePercentage: _feedbackDataModel.clinicEnvironment ?? 35.0,
                                ),
                              ],
                            ),
                          ),
                          _customDivider(),
                          _mapAddress(_doctorModel),
                          const Divider(),
                          _careServiceItem(mQuery, 'Specialities', _doctorModel),
                          _customDivider(),
                          _careServiceItem(mQuery, 'Services', _doctorModel),
                          _customDivider(),
                          _careServiceItem(mQuery, 'Conditions', _doctorModel),
                          _customDivider(),
                          Column(
                            children: [
                              const Text(
                                'Biography',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 4.0,
                              ),
                              SizedBox(
                                width: mQuery.width * 0.85,
                                child: Text(
                                  _doctorModel.bio ?? 'No Biography Available',
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          DoctorMoreInfo(mQuery: mQuery, doctorModel: _doctorModel),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      );
                    },
                    childCount: 1,
                  ),
                ),
              ],
            );
          },
        ));
  }

  Widget _mapAddress(DoctorModel modelObject) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 22,
              ),
              Text(
                modelObject.clinicList![0].city != null
                    ? '${modelObject.clinicList![0].district!.name ?? ""}, ${modelObject.clinicList![0].city!.name ?? ""}'
                    : "Unknown District, Unknown City",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
          Container(
              height: 200,
              decoration: BoxDecoration(
                color: Palette.imageBackground,
                border: Border.all(width: 3, color: Palette.imageBackground),
              ),
              child: GoogleMapWidget(
                mapType: 'view_doctor_profile',
                clinicObjectList: modelObject.clinicList ?? <ClinicModel>[],
              )),
        ],
      ),
    );
  }

  Container _profileAvatar(mQuery) {
    return Container(
      // height: 150,
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 50,
                color: Colors.transparent,
              ),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Container(
                  width: mQuery.width * 0.88,
                  height: 170,
                  decoration:
                      BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.star_border,
                              color: Colors.blue[900],
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DoctorReview(),
                              ),
                            ),
                          ),
                          IconButton(
                              icon: Icon(CupertinoIcons.settings),
                              onPressed: () => Navigator.push(
                                  context, MaterialPageRoute(builder: (_) => ProfileSetting()))),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RatingBarIndicator(
                            rating: _feedbackDataModel.averageStar ?? 3.5,
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 21.0,
                            unratedColor: Colors.grey[500],
                            direction: Axis.horizontal,
                          ),
                          tileText("(${_feedbackDataModel.feedbackNo})", 'other'),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(child: _rowAnalitics(_feedbackDataModel.patientNo!, 'Patients')),
                          const SizedBox(
                            height: 25,
                            child: VerticalDivider(
                              thickness: 1,
                              color: Colors.black,
                            ),
                          ),
                          Expanded(
                              child: _rowAnalitics(_feedbackDataModel.completedApptNo!, 'Appts')),
                          const SizedBox(
                            height: 25,
                            child: VerticalDivider(
                              thickness: 1,
                              color: Colors.black,
                            ),
                          ),
                          Expanded(
                              child: _rowAnalitics(_feedbackDataModel.experienceYear!, 'Experience',
                                  experience: true)),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        '${DRAWER_DATA["feedback_no"]} Feedbacks, On Avg ${DRAWER_DATA["average_star"]}/5',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          ProfileAvatarCircle(
            imageUrl: _doctorModel.user!.avatar!,
            radius: 108,
            circleColor: Palette.imageBackground,
          )
        ],
      ),
    );
  }

  Container _careServiceItem(mQuery, String title, DoctorModel modelObject) {
    final theList = modelObject.specialityList;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          ),
          SizedBox(
            height: 3,
          ),
          if (theList == null || theList.length < 0)
            Text(
              "No Item",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16.0,
              ),
            ),
          if (theList != null && theList.length > 0)
            ...theList.map(
              (e) => Row(children: [
                Icon(
                  Icons.check,
                  color: Palette.blueAppBar,
                ),
                Text(
                  e.name ?? "",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16.0,
                  ),
                ),
              ]),
            )
        ],
      ),
    );
  }

  Column _rowAnalitics(int theDigit, String theTitle, {bool experience = false}) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
              text: theDigit.toString(),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black),
              children: [
                if (experience)
                  TextSpan(
                      text: ' Year(s)',
                      style:
                          TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.black))
              ]),
        ),
        Text(
          theTitle,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Container _customDivider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: dashedLine(Colors.blue),
    );
  }
}

class BioGraphy extends StatefulWidget {
  final String bio;
  final String farsiBio;
  final String pashtoBio;
  const BioGraphy({
    Key? key,
    required this.bio,
    required this.farsiBio,
    required this.pashtoBio,
  }) : super(key: key);

  @override
  _BioGraphyState createState() => _BioGraphyState();
}

class _BioGraphyState extends State<BioGraphy> {
  bool expandText = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 30,
        right: 30,
      ),
      child: InkWell(
          onTap: () {
            setState(() {
              expandText = !expandText;
            });
          },
          child: Column(
            children: [
              if (expandText)
                RichText(
                  text: TextSpan(
                    text: widget.bio,
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400, color: Colors.black),
                    children: [
                      TextSpan(
                        text: ' ... Show More',
                        style: TextStyle(
                            color: Colors.blue[900], fontSize: 15.0, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              if (!expandText)
                Column(
                  children: [
                    Text(
                      'Biography',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                          text: widget.bio,
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: ' ... Show Less',
                              style: TextStyle(
                                  color: Colors.blue[900],
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500),
                            )
                          ]),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      'زنده گی نامه',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      widget.farsiBio,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      'بیوگرافی',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      widget.pashtoBio,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
            ],
          )),
    );
  }
}

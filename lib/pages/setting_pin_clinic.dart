import 'package:doctor_panel/models/clinic_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import '../utils/utils.dart';
import '../pages/screens.dart';

class SettingPinClinic extends StatefulWidget {
  final List<ClinicModel> clinicModelList;

  const SettingPinClinic({Key? key, required this.clinicModelList}) : super(key: key);
  @override
  _SettingPinClinicState createState() => _SettingPinClinicState();
}

class _SettingPinClinicState extends State<SettingPinClinic> {
  @override
  void initState() {
    super.initState();
    print('value of clinicModelList');
    print(widget.clinicModelList.length);
  }
  // List<Map<String, double>> _mapList = [
  //   {'lat': 34.53401150373386, 'lng': 69.1728845254006},
  //   {'lat': 34.53696709035473, 'lng': 69.19056250241701}
  // ];

  void _onMapTapped(ClinicModel clinicObject) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ClinicMapLocation(
                  isGetLocation: true,
                  clinicObjectList: <ClinicModel>[clinicObject],
                )));
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
      appBar: myAppBar('Pin Clinics On Map'),
      body: ListView.builder(
          itemCount: widget.clinicModelList.length,
          itemBuilder: (context, index) {
            return _mapAddress(widget.clinicModelList[index], mQuery);
          }),
    );
  }

  Widget _mapAddress(ClinicModel clinicObject, mQuery) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Icon(
                Icons.local_hospital_outlined,
                size: 22,
              ),
              Text(
                clinicObject.clinicName ?? 'Uknown Clinic',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
          Stack(
            children: [
              Container(
                height: 200,
                width: mQuery.width * 0.95,
                decoration: BoxDecoration(
                  color: Palette.imageBackground,
                  border: Border.all(width: 3, color: Palette.imageBackground),
                ),
                child: clinicObject.latitude == null
                    ? PlaceHolder(
                        title: 'No Map Coordination',
                        body: 'Tap to add map coordination to clinic',
                      )
                    : GoogleMapWidget(
                        mapType: 'pin_clinic',
                        clinicObjectList: <ClinicModel>[clinicObject],
                        // clinicObject: clinicObject,
                        // coordinate: [
                        //   {
                        //     'lat': clinicObject.latitude ?? 34.53401150373386,
                        //     'lng': clinicObject.longtitude ?? 69.1728845254006
                        //   }
                        // ],
                      ),
              ),
              Positioned(
                  bottom: 5,
                  right: 10,
                  child: ElevatedButton.icon(
                    onPressed: () => _onMapTapped(clinicObject),
                    icon: Icon(CupertinoIcons.location),
                    label: Text(
                      'Pin',
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      primary: Palette.imageBackground,
                    ),
                  )),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 15),
            child: dashedLine(Palette.blueAppBar),
          ),
        ],
      ),
    );
  }
}

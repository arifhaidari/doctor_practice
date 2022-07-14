import 'package:dio/dio.dart';
import 'package:doctor_panel/models/clinic_model.dart';
import 'package:doctor_panel/providers/provider_list.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/utils.dart';
import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClinicMapLocation extends StatefulWidget {
  final bool isGetLocation;
  final List<ClinicModel> clinicObjectList;

  const ClinicMapLocation({Key? key, this.isGetLocation = false, required this.clinicObjectList})
      : super(key: key);
  @override
  _ClinicMapLocationState createState() => _ClinicMapLocationState();
}

class _ClinicMapLocationState extends State<ClinicMapLocation> {
  MapType _mapType = MapType.normal;

  @override
  void initState() {
    super.initState();
  }

  Widget _onMapButton(VoidCallback function, IconData icon, String tag) {
    print('inside th_onMapButton');
    return FloatingActionButton(
      splashColor: Palette.blueAppBar,
      heroTag: tag,
      elevation: 8,
      onPressed: function,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: Palette.imageBackground,
      child: Icon(
        icon,
        size: 35.0,
        color: Colors.amberAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // title: Text('Clinic Location'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            GoogleMapWidget(
              mapType: 'clinic_location',
              mapStyle: _mapType,
              clinicObjectList: widget.clinicObjectList,
              // coordinate: [
              //   ...widget.clinicObjectList.map((e) => {
              //         'lat': e.latitude ?? 34.53401150373386,
              //         'lng': e.longtitude ?? 69.1728845254006
              //       })
              //   // {'lat': 34.53401150373386, 'lng': 69.1728845254006},
              //   // {'lat': 34.53696709035473, 'lng': 69.19056250241701},
              // ],
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 65,
                    ),
                    if (widget.isGetLocation)
                      _onMapButton(_getCurrentLocation, Icons.location_searching_outlined,
                          'current_location'),
                    SizedBox(
                      height: 15.0,
                    ),
                    _onMapButton(_changeMapType, Icons.map, 'change_map'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _changeMapType() {
    print('insdie the _changeMapType');
    setState(() {
      _mapType = _mapType == MapType.normal
          ? MapType.hybrid
          : (_mapType == MapType.hybrid ? MapType.terrain : MapType.normal);
    });
  }

  void _getCurrentLocation() async {
    bool _isDialogRunning = false;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          _isDialogRunning = true;
          return const ProgressPopupDialog();
        });
    try {
      Position _position =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print(_position);

      // LatLng latestLatlng = LatLng(_position.latitude, _position.longitude);

      FormData body = FormData.fromMap({
        'clinic_id': widget.clinicObjectList.first.id,
        'latitude': _position.latitude,
        'longtitude': _position.longitude,
      });

      var clinicCoordinateResponse = await HttpService().postRequest(
        data: body,
        endPoint: CLINIC_LIST + '?q=pin_coordinate',
      );
      Navigator.of(context).pop();
      _isDialogRunning = false;

      if (!clinicCoordinateResponse.error) {
        infoNoOkDialogue(
            context,
            'If you are in your clinic right now, then your clinic location has been pinned to map',
            'Get Current Location');
      } else {
        infoNoOkDialogue(
            context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    } catch (e) {
      _isDialogRunning ? Navigator.of(context).pop() : null;
      infoNoOkDialogue(
          context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS, GlobalVariable.ERROR_MESSAGE_TITLE);
    }
    //
  }
}

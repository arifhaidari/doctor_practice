import 'package:doctor_panel/models/model_list.dart';
import 'package:doctor_panel/providers/provider_list.dart';
import 'package:doctor_panel/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/utils.dart';
import '../screens.dart';

class MedicalRecord extends StatefulWidget {
  final int patientId;
  MedicalRecord({Key? key, required this.patientId}) : super(key: key);

  @override
  _MedicalRecordState createState() => _MedicalRecordState();
}

class _MedicalRecordState extends State<MedicalRecord> {
  bool _isUnknownError = false;
  bool _isConnectionError = false;
  String _errorMessage = '';
  final _scrollController = ScrollController();
  String _nextPage = '';
  String _sortingKey = 'All';
  int _itemCount = 0;

  List<MedicalRecordModel> medicalRecordList = <MedicalRecordModel>[];

  @override
  void initState() {
    super.initState();
    _getData(_sortingKey);
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent == _scrollController.offset) {
        _itemCount <= medicalRecordList.length
            ? toastSnackBar(GlobalVariable.NO_MORE_ITEM)
            : _getData(_sortingKey, nextPage: true);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Future<void> _getData(String query, {bool nextPage = false}) async {
    List<MedicalRecordModel> _tempMedicalRecordList = <MedicalRecordModel>[];
    _sortingKey = query;
    Map<String, dynamic> _theMap = {
      'user_id': widget.patientId,
      'query': query,
    };
    //
    final _medicalRecordResponse = await HttpService().getRequest(
        endPoint: (nextPage && _nextPage != '') ? _nextPage : PATIENT_MEDICAL_RECORD,
        queryMap: _theMap);
    print('after the thing request');
    if (!_medicalRecordResponse.error) {
      try {
        setState(() {
          if (_medicalRecordResponse.data['results'] is List &&
              _medicalRecordResponse.data['results'].length != 0) {
            _itemCount = _medicalRecordResponse.data['count'];
            _nextPage = _medicalRecordResponse.data['next'] ?? '';
            _medicalRecordResponse.data['results'].forEach((patient) {
              MedicalRecordModel patientModel = MedicalRecordModel.fromJson(patient);
              _tempMedicalRecordList.add(patientModel);
            });
          }

          print('value fo _tempMedicalRecordList');
          print(_tempMedicalRecordList.length);

          if (!nextPage) {
            medicalRecordList.clear();
            medicalRecordList.addAll(_tempMedicalRecordList);
          } else {
            medicalRecordList.addAll(_tempMedicalRecordList);
          }
        });
      } catch (e) {
        print('value fo erorororororo');
        print(e);
        setState(() {
          _isUnknownError = true;
          _errorMessage = GlobalVariable.UNEXPECTED_ERROR;
        });
      }
    } else {
      infoNoOkDialogue(
          context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      setState(() {
        if (_medicalRecordResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _medicalRecordResponse.errorMessage!;
        }
      });
    }
  }

  // String dropdownValue = 'All';
// 'All', 'Me', 'Others'

  void _launchPopup(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoActionSheet(
            title: Text(
              'Filter Medical Record',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _getData('All');
                  },
                  child: Text(
                    'All',
                    style: TextStyle(color: Palette.blueAppBar),
                  )),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _getData('Me');
                  },
                  child: Text(
                    'Me',
                    style: TextStyle(color: Palette.blueAppBar),
                  )),
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _getData('Others');
                  },
                  child: Text(
                    'Others',
                    style: TextStyle(color: Palette.blueAppBar),
                  )),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // final mQuery = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Palette.blueAppBar,
        onPressed: () {
          _launchPopup(context);
        },
        child: Icon(
          Icons.sort,
          size: 30,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _getData(_sortingKey);
        },
        child: SafeArea(
            top: false,
            child: Builder(
              builder: (BuildContext ctx) {
                if (_isUnknownError || _isConnectionError) {
                  if (_isConnectionError) {
                    return ErrorPlaceHolder(
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
                return medicalRecordList.length == 0
                    ? PlaceHolder(
                        title: 'No Medical Record Available',
                        body: 'Medical record will be listed here')
                    : ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: medicalRecordList.length + 1,
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          if (index < medicalRecordList.length) {
                            return ExpandableMedicalWidget(
                              medicalRecordObject: medicalRecordList[index],
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 25.0),
                              child: Center(
                                child: _itemCount <= medicalRecordList.length
                                    ? null
                                    : const CircularProgressIndicator(),
                              ),
                            );
                          }
                        });
              },
            )),
      ),
    );
  }
}

class ExpandableMedicalWidget extends StatelessWidget {
  final MedicalRecordModel medicalRecordObject;
  const ExpandableMedicalWidget({
    Key? key,
    required this.medicalRecordObject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: ExpansionTile(
        expandedAlignment: Alignment.topLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: EdgeInsets.only(left: 15.0, bottom: 10.0, right: 15.0),
        collapsedBackgroundColor: Palette.imageBackground,
        backgroundColor: Colors.black12,
        title: Row(
          children: [
            Expanded(
              child: AutoSizeText(
                medicalRecordObject.title ?? 'No Title',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                minFontSize: 13,
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ),
            SizedBox(
              width: 3.0,
            ),
            Text(
              '(${medicalRecordObject.fileModel!.length} Files)',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 5.0),
            // height: 100,
            child: medicalRecordObject.fileModel!.length == 0
                ? Center(child: Text('No File Available'))
                : Column(
                    children: [
                      Text(medicalRecordObject.title ?? 'No Title'),
                      SizedBox(
                        height: 5,
                      ),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 5.0,
                        // shrinkWrap: true,
                        // scrollDirection: Axis.horizontal,
                        children: medicalRecordObject.fileModel!
                            .map(
                              (e) => GestureDetector(
                                onTap: () => isPdf(e.file ?? '')
                                    ? showPdf(e.file ?? '', context)
                                    : Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MedicalPhotoGallery(
                                                  medicalRecordFileList: medicalRecordObject
                                                      .fileModel!
                                                      .where((element) => !isPdf(element.file!))
                                                      .toList(),
                                                ))),
                                child: Container(
                                  height: 90,
                                  width: 90,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Palette.imageBackground,
                                        borderRadius: BorderRadius.circular(5)),
                                    margin: EdgeInsets.only(right: 5.0),
                                    child: isPdf(e.file ?? '')
                                        ? Center(
                                            child: Icon(
                                              Icons.picture_as_pdf_outlined,
                                              size: 40,
                                            ),
                                          )
                                        : CachedNetworkImage(
                                            imageBuilder: (context, imageProvider) => Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                    colorFilter: ColorFilter.mode(
                                                        Colors.red, BlendMode.colorBurn)),
                                              ),
                                            ),
                                            placeholder: (context, url) => circularLoading(),
                                            errorWidget: (context, url, error) => Icon(
                                              Icons.error,
                                              color: Colors.white,
                                              size: 50,
                                            ),
                                            fit: BoxFit.cover,
                                            imageUrl: e.file ?? '',
                                          ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        // children: medicalNameOnlyList.map((e) => Text(e)).toList(),
                      ),
                    ],
                  ),
          )
        ],
      ),
    );
  }

  // void _showPdf(String url, BuildContext context) async {
  //   final pdfFile = await PDFMixin.loadNetwork(url);

  //   if (url != '') {
  //     Navigator.push(context, MaterialPageRoute(builder: (context) {
  //       return PDFViewerPage(file: pdfFile);
  //     }));
  //   }
  // }
}

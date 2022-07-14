import 'package:doctor_panel/models/model_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../providers/end_point.dart';
import 'package:doctor_panel/providers/http_service.dart';
import '../../utils/utils.dart';
import '../../pages/screens.dart';
import '../../widgets/widgets.dart';

class Patient extends StatefulWidget {
  @override
  _PatientState createState() => _PatientState();
}

class _PatientState extends State<Patient> {
  final TextEditingController _searchPatientController = TextEditingController();
  List<PatientModel> patientModelList = <PatientModel>[];
  List<PatientModel> _searchList = <PatientModel>[];

  bool _isUnknownError = false;
  bool _isConnectionError = false;
  String _errorMessage = '';
  final _scrollController = ScrollController();
  String _nextPage = '';
  int _itemCount = 0;

  @override
  void initState() {
    super.initState();
    _getData();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent == _scrollController.offset) {
        _itemCount <= patientModelList.length
            ? toastSnackBar(GlobalVariable.NO_MORE_ITEM)
            : _getData(nextPage: true);
      }
    });
  }

  Future<void> _getData({bool nextPage = false}) async {
    List<PatientModel> _tempPatientModelList = <PatientModel>[];
    final patientResponse = await HttpService()
        .getRequest(endPoint: (nextPage && _nextPage != '') ? _nextPage : MY_PATIENT_LIST);

    if (!patientResponse.error) {
      try {
        setState(() {
          if (patientResponse.data['results'] is List &&
              patientResponse.data['results'].length != 0) {
            _itemCount = patientResponse.data['count'];
            _nextPage = patientResponse.data['next'] ?? '';
            patientResponse.data['results'].forEach((patientObject) {
              PatientModel theObject = PatientModel.fromJson(patientObject);
              _tempPatientModelList.add(theObject);
            });

            if (!nextPage) {
              patientModelList.clear();
              patientModelList.addAll(_tempPatientModelList);
            } else {
              patientModelList.addAll(_tempPatientModelList);
            }
          }
        });
      } catch (e) {
        setState(() {
          _isUnknownError = true;
          _errorMessage = GlobalVariable.UNEXPECTED_ERROR;
        });
      }
    } else {
      infoNoOkDialogue(
          context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      setState(() {
        if (patientResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = patientResponse.errorMessage!;
        }
      });
    }
  }

  void _searchPatient(String query, {bool isForSearch = false}) async {
    if (query.length % 3 == 0 && query != '') {
      String lowerQuery = query.toLowerCase();

      if (query.length < 6) {
        final theList = patientModelList.where((element) {
          final theName =
              element.user!.name != null ? element.user!.name!.toLowerCase() : 'name_not_available';
          return ((theName != 'name_not_available' ? theName.contains(lowerQuery) : false) ||
              (element.user!.rtlName != null ? element.user!.rtlName!.contains(query) : false));
        });
        if (theList.length > 0 && !isForSearch) {
          setState(() {
            theList.forEach((element) {
              patientModelList.remove(element);
              patientModelList.insert(0, element);
            });
          });
        }
      } else {
        final searchResultObject =
            await HttpService().getRequest(endPoint: MY_PATIENT_LIST + "?q=$query");

        if (!searchResultObject.error) {
          try {
            if (searchResultObject.data['results'] is List &&
                searchResultObject.data['results'].length != 0) {
              setState(() {
                searchResultObject.data['results'].forEach((response) {
                  final theObject = PatientModel.fromJson(response);
                  _searchList.add(theObject);
                });
                // add to list and skip the redundant
                _searchList.forEach((element) {
                  final patientObject = patientModelList.firstWhere(
                      (theVal) => theVal.user!.id == element.user!.id,
                      orElse: () => PatientModel(user: UserModel(id: 0)));
                  if (element.user!.id == patientObject.user!.id) {
                    patientModelList.remove(element);
                    patientModelList.insert(0, element);
                  } else {
                    patientModelList.insert(0, element);
                  }
                });
              });
            }
          } catch (e) {
            infoNoOkDialogue(context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS,
                GlobalVariable.ERROR_MESSAGE_TITLE);
          }
        } else {
          infoNoOkDialogue(
              context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final mQuery = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Palette.scaffoldBackground,
        appBar: myAppBar('Patients', isAction: true, function: () {}),
        drawer: CustomDrawer(),
        body: RefreshIndicator(
          onRefresh: () async {
            _getData();
          },
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
                    errorTitle: GlobalVariable.UNKNOWN_ERROR,
                    errorDetail: _errorMessage,
                  );
                }
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.chat,
                              size: 22,
                              color: Palette.blueAppBar,
                            ),
                            SizedBox(
                              width: 3.0,
                            ),
                            Text(
                              "My Patient List",
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Text(
                          "${patientModelList.length} Patients",
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: dashedLine(Palette.lightGreen),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, right: 12.0, left: 12.0),
                    child: CupertinoSearchTextField(
                      controller: _searchPatientController,
                      placeholder: 'Search Patient',
                      onChanged: (changeVal) {
                        _searchPatient(changeVal);
                      },
                      onSuffixTap: () {
                        FocusScope.of(context).unfocus();
                        _searchPatient(_searchPatientController.text, isForSearch: true);
                      },
                      suffixIcon: Icon(
                        Icons.search,
                        size: 25,
                        color: Palette.blueAppBar,
                      ),
                    ),
                  ),
                  Expanded(
                    child: patientModelList.length <= 0
                        ? PlaceHolder(
                            title: 'No Patient Available', body: 'You patient will be listed here')
                        : ListView.builder(
                            padding: EdgeInsets.all(10.0),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            physics: PageScrollPhysics(),
                            itemCount: patientModelList.length + 1,
                            controller: _scrollController,
                            itemBuilder: (context, index) {
                              if (index < patientModelList.length) {
                                return PatientCard(
                                  patientModel: patientModelList[index],
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 25.0),
                                  child: Center(
                                    child: _itemCount <= patientModelList.length
                                        ? null
                                        : const CircularProgressIndicator(),
                                  ),
                                );
                              }
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ));
  }
}

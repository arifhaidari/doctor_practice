import 'package:auto_size_text/auto_size_text.dart';
import 'package:doctor_panel/models/model_list.dart';
import 'package:doctor_panel/providers/provider_list.dart';
import 'package:doctor_panel/widgets/widgets.dart';
import 'package:flutter/material.dart';
import '../utils/utils.dart';
import 'screens.dart';

enum NotificationFilter { all, appointment, chat, cancelAppt, clearAll }

class NotificationView extends StatefulWidget {
  @override
  _NotificationViewState createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  // String theQuery = 'All';

  List<NotificationModel> notificationList = <NotificationModel>[];

  bool _isUnknownError = false;
  bool _isConnectionError = false;
  String _errorMessage = '';
  final _scrollController = ScrollController();
  String _sortingKey = 'All';
  String _nextPage = '';
  int _itemCount = 0;

  @override
  void initState() {
    super.initState();
    _getData(_sortingKey);
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent == _scrollController.offset) {
        _itemCount <= notificationList.length
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

  Future<void> _getData(String theQuery, {bool nextPage = false}) async {
    List<NotificationModel> _temmpNotificationList = <NotificationModel>[];
    _sortingKey = theQuery;
    final _noteResponse = await HttpService().getRequest(
        endPoint: (nextPage && _nextPage != '') ? _nextPage : NOTE_GET + '?q=$theQuery');

    if (!_noteResponse.error) {
      try {
        setState(() {
          print('value fo the repaon---====');
          print(_noteResponse.data['results'].length);
          if (_noteResponse.data['results'] is List && _noteResponse.data['results'].length != 0) {
            _itemCount = _noteResponse.data['count'];
            _nextPage = _noteResponse.data['next'] ?? '';

            _noteResponse.data['results'].forEach((patient) {
              NotificationModel patientModel = NotificationModel.fromJson(patient);
              _temmpNotificationList.add(patientModel);
            });
          }
          if (!nextPage) {
            notificationList.clear();
            notificationList.addAll(_temmpNotificationList);
          } else {
            notificationList.addAll(_temmpNotificationList);
          }
        });
      } catch (e) {
        print('value of right eeeorororooror');
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
        if (_noteResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _noteResponse.errorMessage!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Notifications',
            style:
                TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Palette.blueAppBar,
          actions: [
            _notificationSorter(),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _getData(_sortingKey);
          },
          child: Builder(
            builder: (BuildContext ctx) {
              if (_isUnknownError || _isConnectionError) {
                if (_isConnectionError) {
                  return ErrorPlaceHolder(
                      isStartPage: true,
                      errorTitle: 'Internet Connection Issue',
                      errorDetail: 'Check your internet connection and try again');
                } else {
                  return ErrorPlaceHolder(
                    isStartPage: true,
                    errorTitle: 'Unknown Error. Try again later',
                    errorDetail: _errorMessage,
                  );
                }
              }
              return notificationList.length == 0
                  ? PlaceHolder(
                      title: 'Notification',
                      body: 'Notificaiton will be listed here',
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(top: 8, left: 5, right: 5),
                      itemCount: notificationList.length + 1,
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        if (index < notificationList.length) {
                          return Dismissible(
                            key: ValueKey(notificationList[index].id),
                            onDismissed: (dirction) {
                              _removeNote(notificationList[index].id ?? 0, context);
                            },
                            background: Container(
                              padding: EdgeInsets.only(right: 30),
                              color: Colors.red,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Clear Notification',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            child: Card(
                              elevation: 4,
                              color: Palette.imageBackground,
                              child: ListTile(
                                leading: Icon(
                                  _noteTypeIcon(
                                      notificationList[index].category ?? 'appt_cancelation'),
                                  size: 32,
                                  color: Colors.blue[900],
                                ),
                                title: AutoSizeText(
                                  notificationList[index].title ?? 'Unknown Title',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                  maxLines: 1,
                                  minFontSize: 14,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  notificationList[index].body ?? '',
                                  style: TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 25.0),
                            child: Center(
                              child: _itemCount <= notificationList.length
                                  ? null
                                  : const CircularProgressIndicator(),
                            ),
                          );
                        }
                      });

              // NotificationList(
              //     notificationList: notificationList,
              //   );
            },
          ),
        ));
  }

  void _removeNote(int noteId, BuildContext ctx) async {
    bool _isDialogRunning = false;
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) {
          _isDialogRunning = true;
          return const ProgressPopupDialog();
        });
    try {
      var feedbackResponse = await HttpService().deleteRequest(
        // data: body,
        endPoint: NOTE_DELETE + "$noteId/",
      );

      Navigator.of(ctx).pop();
      _isDialogRunning = false;

      if (!feedbackResponse.error) {
        toastSnackBar('Deleted Successfully');
        setState(() {
          notificationList.removeWhere((element) => element.id == noteId);
          _itemCount -= 1;
        });
      } else {
        infoNoOkDialogue(
            context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    } catch (e) {
      _isDialogRunning ? Navigator.of(ctx).pop() : null;
      infoNoOkDialogue(
          context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS, GlobalVariable.ERROR_MESSAGE_TITLE);
    }
  }

  IconData _noteTypeIcon(String category) {
    print('value fo category');
    print(category);
    switch (category) {
      case 'Appt Cancelation':
        return Icons.access_time;
      // break; // it is a dead code
      case 'Review':
        return Icons.rate_review_outlined;
      case 'Review Reply':
        return Icons.reply;
      default:
        return Icons.star_outline;
    }
  }

  PopupMenuButton _notificationSorter() {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        _getData(result);
      },
      icon: Icon(Icons.sort),
      color: Palette.imageBackground,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'All',
          child: Text('All'),
        ),
        const PopupMenuItem<String>(
          value: 'appt_cancelation',
          child: Text('Appointment'),
        ),
        const PopupMenuItem<String>(
          value: 'review',
          child: Text('Review'),
        ),
        const PopupMenuItem<String>(
          value: 'Clear',
          child: Text('Clear All'),
        ),
      ],
    );
  }
}

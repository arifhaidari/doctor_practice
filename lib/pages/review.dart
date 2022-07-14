import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:doctor_panel/models/feedback_model.dart';
import 'package:doctor_panel/models/model_list.dart';
import 'package:doctor_panel/pages/screens.dart';
import 'package:doctor_panel/providers/provider_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class DoctorReview extends StatefulWidget {
  @override
  _DoctorReviewState createState() => _DoctorReviewState();
}

class _DoctorReviewState extends State<DoctorReview> {
  bool _isUnknownError = false;
  bool _isConnectionError = false;
  String _errorMessage = '';
  final _scrollController = ScrollController();
  String _nextPage = '';
  int _itemCount = 0;

  List<FeedbackModel> feedbackModelList = <FeedbackModel>[];

  @override
  void initState() {
    super.initState();
    _getData();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent == _scrollController.offset) {
        _itemCount <= feedbackModelList.length
            ? toastSnackBar(GlobalVariable.NO_MORE_ITEM)
            : _getData(nextPage: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getData({bool nextPage = false}) async {
    List<FeedbackModel> _tempFeedbackModelList = <FeedbackModel>[];
    final _reviewResponse = await HttpService()
        .getRequest(endPoint: (nextPage && _nextPage != '') ? _nextPage : APPT_FEEDBACK_GET_POST);

    if (!_reviewResponse.error) {
      try {
        setState(() {
          if (_reviewResponse.data['results'] is List &&
              _reviewResponse.data['results'].length != 0) {
            _itemCount = _reviewResponse.data['count'];
            _nextPage = _reviewResponse.data['next'] ?? '';
            _reviewResponse.data['results'].forEach((patient) {
              FeedbackModel patientModel = FeedbackModel.fromJson(patient);
              _tempFeedbackModelList.add(patientModel);
            });

            if (!nextPage) {
              feedbackModelList.clear();
              feedbackModelList.addAll(_tempFeedbackModelList);
            } else {
              feedbackModelList.addAll(_tempFeedbackModelList);
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
        if (_reviewResponse.errorMessage == NO_INTERNET_CONNECTION) {
          _isConnectionError = true;
        } else {
          _isUnknownError = true;
          _errorMessage = _reviewResponse.errorMessage!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Reviews',
          style:
              TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Palette.blueAppBar,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _getData();
        },
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                return feedbackModelList.length == 0
                    ? PlaceHolder(
                        title: 'No Review Available',
                        body: 'Reviews will be listed here',
                      )
                    : ListView.builder(
                        itemCount: feedbackModelList.length + 1,
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          if (index < feedbackModelList.length) {
                            final userPatient = feedbackModelList[index].apptModel!.userPatient;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ProfileAvatarCircle(
                                      imageUrl: userPatient!.avatar != null
                                          ? (MEDIA_LINK_NO_SLASH + userPatient.avatar!)
                                          : null,
                                      radius: 50,
                                      borderWidth: 1.5,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: AutoSizeText(
                                                  userPatient.name ?? 'Uknown Name',
                                                  style: TextStyle(
                                                      fontSize: 17, fontWeight: FontWeight.w400),
                                                  overflow: TextOverflow.ellipsis,
                                                  minFontSize: 15,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              _editDeleteButton(
                                                replyIdTemp: feedbackModelList[index].id ?? 0,
                                                feedbackIdTemp: feedbackModelList[index].id ?? 0,
                                                theIndex: index,
                                              )
                                            ],
                                          ),
                                          Text(
                                            timeAgoConverter(feedbackModelList[index].timestamp!),
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Palette.imageBackground),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 5),
                                            child: RatingBarIndicator(
                                              rating:
                                                  feedbackModelList[index].scoreCount!.toDouble(),
                                              itemBuilder: (context, index) => Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              itemCount: 5,
                                              itemSize: 18.0,
                                              unratedColor: Colors.black45,
                                              direction: Axis.horizontal,
                                            ),
                                          ),
                                          Text(
                                            feedbackModelList[index].comment!,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            child: dashedLine(Palette.blueAppBar),
                                          ),
                                          // Reply goes here
                                          if (feedbackModelList[index].replyList!.length != 0)
                                            ...feedbackModelList[index]
                                                .replyList!
                                                .map(
                                                  (e) => Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          ProfileAvatarCircle(
                                                            imageUrl: e.author!.avatar ?? null,
                                                            radius: 45,
                                                            borderWidth: 1.3,
                                                          ),
                                                          SizedBox(
                                                            width: 8,
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment.start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                      child: AutoSizeText(
                                                                        e.author!.name ??
                                                                            'Unknown Name',
                                                                        style: TextStyle(
                                                                            fontSize: 17,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                        maxLines: 1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        minFontSize: 14,
                                                                      ),
                                                                    ),
                                                                    _editDeleteButton(
                                                                      replyIdTemp: e.id ?? 0,
                                                                      feedbackIdTemp:
                                                                          feedbackModelList[index]
                                                                                  .id ??
                                                                              0,
                                                                      theIndex: index,
                                                                      editDefaultText:
                                                                          e.reply ?? '',
                                                                    )
                                                                  ],
                                                                ),
                                                                Text(
                                                                  timeAgoConverter(e.timestamp!),
                                                                  style: TextStyle(
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w400,
                                                                      color:
                                                                          Palette.imageBackground),
                                                                ),
                                                                SizedBox(
                                                                  height: 3,
                                                                ),
                                                                Text(
                                                                  e.reply ?? '',
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 8,
                                                      )
                                                    ],
                                                  ),
                                                )
                                                .toList(),

                                          if (_theIndex == index) _replyFormField(),

                                          TextButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _theIndex = index;
                                                _feedBackId = feedbackModelList[index].id!;
                                                // _replyField = !_replyField;
                                              });
                                            },
                                            icon: Icon(
                                              CupertinoIcons.reply,
                                              color: Palette.blueAppBar,
                                              size: 18,
                                            ),
                                            label: Text(
                                              'Reply',
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w500,
                                                color: Palette.blueAppBar,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                )
                              ],
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 25.0),
                              child: Center(
                                child: _itemCount <= feedbackModelList.length
                                    ? null
                                    : const CircularProgressIndicator(),
                              ),
                            );
                          }
                        });

                // FeedbackList(
                //     feedbackList: feedbackModelList,
                //   );
              },
            )),
      ),
    );
  }

  final TextEditingController _replyTextController = TextEditingController();
  // bool _replyField = false;
  int _theIndex = -1;
  int _feedBackId = 0;
  int _replyId = 0;

  PopupMenuButton _editDeleteButton({
    String editDefaultText = 'comment',
    int replyIdTemp = 0,
    required int feedbackIdTemp,
    int theIndex = 0,
  }) {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        if (result == 'edit') {
          setState(() {
            _theIndex = theIndex;
            _replyTextController.text = editDefaultText;
            _replyId = replyIdTemp;
            _feedBackId = feedbackIdTemp;
          });
          //
        } else {
          if (editDefaultText == 'comment') {
            // delete feedback
            questionDialogue(context, 'Do you really want to delete this review?', 'Delete Review',
                () => _deleteFeedbackOrReply(replyIdTemp, feedbackIdTemp, 'feedback', context));
          } else {
            // delete reply
            questionDialogue(context, 'Do you really want to delete this reply?', 'Delete Reply',
                () => _deleteFeedbackOrReply(replyIdTemp, feedbackIdTemp, 'reply', context));
          }
          //
        }
        // delete and edit right here
      },
      icon: Icon(Icons.more_horiz),
      // color: Colors.white,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (editDefaultText != 'comment')
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(
                  Icons.edit,
                  size: 20,
                  color: Colors.blue[900],
                ),
                Text(
                  'Edit',
                  style: TextStyle(color: Colors.blue[900]),
                ),
              ],
            ),
          ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete,
                size: 20,
                color: Colors.blue[900],
              ),
              Text(
                'Delete',
                style: TextStyle(color: Colors.blue[900]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _replyFormField() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextFormField(
            controller: _replyTextController,
            autofocus: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  _replyTextController.clear();
                  setState(() {
                    _theIndex = -1;
                  });
                },
                child: Text('Cancel'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(width: 5),
              ElevatedButton(
                onPressed: () {
                  if (_replyId == 0) {
                    _replyToReview(context);
                  } else {
                    _updateReply(context);
                  }
                },
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  primary: Palette.blueAppBar,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _deleteFeedbackOrReply(
      int replyTempId, int feedbackTempId, String operation, BuildContext ctx) async {
    bool _isDialogRunning = false;
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) {
          _isDialogRunning = true;
          return const ProgressPopupDialog();
        });

    try {
      var theEndpoint = FEEDBACK_DELETE_UPDATE + "$replyTempId/";
      if (operation == 'feedback') {
        theEndpoint = FEEDBACK_DELETE_UPDATE + "$replyTempId/?q=$feedbackTempId";
      }

      var feedbackResponse = await HttpService().deleteRequest(
        // data: body,
        endPoint: theEndpoint,
      );
      Navigator.of(ctx).pop();
      _isDialogRunning = false;

      if (!feedbackResponse.error) {
        toastSnackBar('Deleted Successfully');
        setState(() {
          if (operation == 'feedback') {
            feedbackModelList.removeWhere((element) => element.id == feedbackTempId);
            _itemCount -= 1;
          } else {
            final feedbackObject =
                feedbackModelList.firstWhere((element) => element.id == feedbackTempId);
            feedbackObject.replyList!.removeWhere((element) => element.id == replyTempId);
          }
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

  Future<void> _updateReply(BuildContext ctx) async {
    if (_replyTextController.text.trim() == '') {
      toastSnackBar('Write something then submit', note: false);
      return;
    }
    bool _isDialogRunning = false;
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) {
          _isDialogRunning = true;
          return const ProgressPopupDialog();
        });

    try {
      FormData body = FormData.fromMap({
        'reply': _replyTextController.text,
      });

      var feedbackResponse = await HttpService().patchRequest(
        data: body,
        endPoint: FEEDBACK_DELETE_UPDATE + "$_replyId/",
      );

      Navigator.of(ctx).pop();
      _isDialogRunning = false;

      if (!feedbackResponse.error) {
        //add reply to the list

        var feedBackObj = feedbackModelList.firstWhere((element) => element.id == _feedBackId);
        final newReplyObject = FeedbackReplyModel.fromJson(feedbackResponse.data);
        setState(() {
          feedBackObj.replyList![feedBackObj.replyList!
              .indexWhere((element) => element.id == _replyId)] = newReplyObject;
          _theIndex = -1;
          _replyTextController.clear();
        });
        _feedBackId = 0;
        _replyId = 0;
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

  Future<void> _replyToReview(BuildContext ctx) async {
    if (_replyTextController.text.trim() == '') {
      toastSnackBar('Write something then submit', note: false);
      return;
    }

    bool _isDialogRunning = false;
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) {
          _isDialogRunning = true;
          return const ProgressPopupDialog();
        });

    try {
      final userBriefData = await SharedPref().dashboardBrief();

      FormData body = FormData.fromMap({
        'reply_text': _replyTextController.text,
        'feedback_id': _feedBackId,
      });
      var feedbackResponse = await HttpService().postRequest(
        data: body,
        endPoint: APPT_FEEDBACK_GET_POST,
      );

      Navigator.of(ctx).pop();
      _isDialogRunning = false;

      if (!feedbackResponse.error) {
        //add reply to the list

        var feedBackObj = feedbackModelList.firstWhere((element) => element.id == _feedBackId);
        final newReplyObject = FeedbackReplyModel(
          id: feedbackResponse.data['feedback_reply_id'],
          author: UserModel(
              name: userBriefData['full_name'],
              rtlName: userBriefData['rtl_full_name'],
              avatar: MEDIA_LINK_NO_SLASH + userBriefData['avatar']),
          reply: _replyTextController.text,
          timestamp: DateTime.now(),
          isMe: true,
        );
        setState(() {
          feedBackObj.replyList!.add(newReplyObject);
          _theIndex = -1;
          _feedBackId = 0;
          _replyId = 0;
          _replyTextController.clear();
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
}

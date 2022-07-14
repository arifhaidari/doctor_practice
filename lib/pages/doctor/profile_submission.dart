import 'package:dio/dio.dart';
import 'package:doctor_panel/providers/provider_list.dart';
import 'package:doctor_panel/utils/utils.dart';
import 'package:doctor_panel/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ProfileSubmission extends StatefulWidget {
  final bool isProfileOnProgress;
  final bool isProfessionalProfileCompleted;
  final Function(bool, String) theFunc;
  ProfileSubmission(
      {Key? key,
      required this.isProfileOnProgress,
      required this.isProfessionalProfileCompleted,
      required this.theFunc})
      : super(key: key);

  @override
  _ProfileSubmissionState createState() => _ProfileSubmissionState();
}

class _ProfileSubmissionState extends State<ProfileSubmission> {
  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Column(
      children: [
        Card(
          margin: EdgeInsets.only(top: 10),
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
              padding: EdgeInsets.all(8),
              width: mQuery.width * 0.90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  if (widget.isProfileOnProgress)
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: mQuery.width * 0.90,
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        'Note: Your profile is submitted for review. You can edit your info until the review is completed',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (widget.isProfessionalProfileCompleted)
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: mQuery.width * 0.90,
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        'Note: If you want to edit your profile info then you can change the status of your profile to review. But your profile will not available for booking appointment until the review is completed.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (!widget.isProfessionalProfileCompleted && !widget.isProfileOnProgress)
                    Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: mQuery.width * 0.90,
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          children: [
                            Text(
                              'Check The Following. If You Fullfil The Requirements Then Submit Your Profile For Review',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            cardDetailItem('Basic info updated', Icons.done, maxLine: 2),
                            cardDetailItem(
                                'At least one Speciality with condition and services', Icons.done,
                                maxLine: 2),
                            cardDetailItem('At least one clinic registered or selected', Icons.done,
                                maxLine: 2),
                            cardDetailItem('At least one education', Icons.done, maxLine: 2),
                            cardDetailItem('Biography in three languages', Icons.done, maxLine: 2),
                          ],
                        )),
                  SizedBox(
                    height: 15,
                  ),
                  if (!widget.isProfileOnProgress)
                    customElevatedButton(context, () {
                      widget.isProfessionalProfileCompleted
                          ? questionDialogue(
                              context,
                              'If you agree to request for editing your profile, note that your booked appointments will be canceled and your scheduling setting will be removed. You will not be able to schedule for appointment until your review of your profile is completed. Are you sure you want continue?',
                              'Request For Editing The Profile', () {
                              _submitForReview(context, 'request');
                            })
                          : _submitForReview(context, 'submit');
                      // _saveBasicInfo();
                    },
                        widget.isProfessionalProfileCompleted
                            ? 'Request for Edit'
                            : 'Submit For Review'),
                ],
              )),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Future<void> _submitForReview(BuildContext ctx, String operation) async {
    bool _isDialogRunning = false;
    // setState(() {
    if (operation == 'request') {
      widget.theFunc(false, 'request');
      // widget.isProfessionalProfileCompleted = false;
    } else {
      widget.theFunc(true, 'submit');
      // widget.isProfileOnProgress = true;
    }
    // });
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) {
          _isDialogRunning = true;
          return const ProgressPopupDialog();
        });

    try {
      FormData body = FormData.fromMap({
        'doctor_id': DRAWER_DATA['id'],
        'operation': operation,
      });
      var _reviewResponse = await HttpService().postRequest(
        data: body,
        endPoint: PROFILE_SUBMISSION,
      );

      Navigator.of(ctx).pop();
      _isDialogRunning = false;

      if (!_reviewResponse.error) {
        if (_reviewResponse.data['message'] == 'success') {
          if (operation == 'submit') {
            Navigator.pushReplacementNamed(ctx, '/');
          }
          toastSnackBar(operation == 'submit'
              ? 'Profile is submitted successfully'
              : 'Your have changed your profile status successfully');
        } else if (_reviewResponse.data['message'] == 'not_completed') {
          infoNoOkDialogue(
              ctx, _reviewResponse.data['message_content'], 'Profile Is Not Completed');
        } else {
          infoNoOkDialogue(
              ctx, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
        }
        // DefaultTabController.of(context)!.animateTo(1);
      } else {
        infoNoOkDialogue(ctx, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    } catch (e) {
      _isDialogRunning ? Navigator.of(ctx).pop() : null;
      infoNoOkDialogue(
          ctx, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS, GlobalVariable.ERROR_MESSAGE_TITLE);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/utils.dart';
import '../utils/global_widget.dart';

class ForgetPassword extends StatefulWidget {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  String _errorMessage = '';
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
      appBar: myAppBar('Forget Password'),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 15),
                          child: Text(
                            'Enter your phone number to recover your account. We will send you an OTP to your phone number that you have registered with',
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 15),
                          width: mQuery.width * 0.75,
                          height: 50.0,
                          child: TextFormField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: textFieldDesign(context, 'Phone (07XXXXXXX)'),
                          ),
                        ),
                        if (_errorMessage != '')
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: mQuery.width * 0.90,
                            padding: EdgeInsets.symmetric(horizontal: 25),
                            child: Text(
                              _errorMessage,
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        SizedBox(
                          height: 15,
                        ),
                        customElevatedButton(context, () {
                          final isFormValid = _formValidation();
                          if (isFormValid) {
                            createOTP(context, _phoneNumberController.text, 'forget_password');
                          }
                        }, 'Submit'),
                        SizedBox(
                          height: 8.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _formValidation() {
    print('valueo ffo in form validation ');
    _theSetState('');
    if (_phoneNumberController.text.trim() == '') {
      _theSetState('Please enter phone number');
      return false;
    }

    if (int.tryParse(_phoneNumberController.text) == null) {
      _theSetState('Please enter valid phone number');
      return false;
    }

    if (_phoneNumberController.text.length < 10 || _phoneNumberController.text.length > 10) {
      _theSetState('Phone number is not valid, should be 10 digits');
      return false;
    }

    return true;
  }

  void _theSetState(String theMessage) {
    setState(() {
      _errorMessage = theMessage;
    });
  }
}

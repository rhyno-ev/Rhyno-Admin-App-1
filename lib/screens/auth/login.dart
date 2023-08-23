import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rhyno_admin_app/components/custom_text_field.dart';
import 'package:rhyno_admin_app/components/loading.dart';
import 'package:rhyno_admin_app/helpers/constants.dart';
import 'package:rhyno_admin_app/firebase/database.dart';
import 'package:rhyno_admin_app/helpers/shared_prefernces.dart';
import 'package:rhyno_admin_app/screens/auth/otp.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //controller for phoneNumber
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController adminCodeController = TextEditingController();

  String adminCode = '';
  bool isLoading = true;

  @override
  void initState() {
    getAdminCode();
    super.initState();
  }

  getAdminCode() async {
    await DatabaseMethods().getConfigSettings().then((value) {
      setState(() {
        adminCode = value['adminCode'];
        isLoading = false;
      });
    });
  }

  bool validateNumber(String number) {
    String regexPattern = r'^(?:[+0][1-9])?[0-9]{10}$';
    var regExp = RegExp(regexPattern);

    if (number.isEmpty) {
      return false;
    } else if (regExp.hasMatch(number)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return isLoading
        ? const Loading()
        : Scaffold(
            backgroundColor: backgroundColor,
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Hero(
                        tag: 'logo',
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: width / 1.5,
                        )),
                  ),
                  Column(
                    children: [
                      CustomTextField(
                          controller: phoneNumberController,
                          type: TextInputType.number,
                          placeholder: 'Enter 10-digit Phone Number'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: c1.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10)),
                        child: TextField(
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          controller: adminCodeController,
                          decoration: const InputDecoration(
                              hintText: 'Enter Admin Code',
                              hintStyle: TextStyle(color: Colors.white),
                              border: InputBorder.none),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MaterialButton(
                          color: c2,
                          child: const Text('Verify'),
                          onPressed: () {
                            //update phoneNumber in localstorage and move to otp screen
                            if (validateNumber(phoneNumberController.text)) {
                              if (adminCodeController.text == adminCode) {
                                
                                Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Otp(
                                                phoneNumber:
                                                    phoneNumberController.text,
                                              )));
                              } else {
                                Fluttertoast.showToast(
                                    msg: 'Invalid Admin Code');
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg: 'Invalid Phone Number');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: width / 3,
                  )
                ],
              ),
            ),
          );
  }
}

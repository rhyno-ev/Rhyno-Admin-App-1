import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rhyno_admin_app/components/custom_text_field.dart';
import 'package:rhyno_admin_app/components/loading.dart';
import 'package:rhyno_admin_app/helpers/constants.dart';
import 'package:rhyno_admin_app/firebase/database.dart';
import 'package:rhyno_admin_app/helpers/shared_prefernces.dart';
import 'package:rhyno_admin_app/screens/home.dart';

class SetProfile extends StatefulWidget {
  const SetProfile({Key? key}) : super(key: key);

  @override
  State<SetProfile> createState() => _SetProfileState();
}

class _SetProfileState extends State<SetProfile> {
  late String phoneNumber, userId;
  bool isLoading = true;
  bool buttonDisabled = false;
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  //get data from localstorage
  void getData() async {
    phoneNumber = await SPMethods().getPhoneNumber();
    userId = await SPMethods().getUserId();
    setState(() {
      isLoading = false;
    });
  }

  void submitDetails() async {
    if (nameController.text.length < 3) {
      Fluttertoast.showToast(
          msg: 'Invalid Name. Name must be at least 3 characters long.');
      return;
    }
    setState(() {
      buttonDisabled = true;
    });

    try {
      await DatabaseMethods()
          .createAdminProfile(nameController.text, phoneNumber, userId);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Home()));
    } catch (e) {
      Fluttertoast.showToast(msg: 'Registration Failed!');
      setState(() {
        buttonDisabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    if (isLoading) {
      return const Loading();
    } else {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          title: const Text(
            'Complete Your Profile',
            style: TextStyle(color: c1),
          ),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Container(
            width: width,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomTextField(controller: nameController, type: TextInputType.text, placeholder: 'Enter Your Full Name'),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: buttonDisabled
                        ? const CircularProgressIndicator(
                            color: c2,
                          )
                        : MaterialButton(
                            color: c2,
                            child: const Text(
                              'Submit',
                              style: TextStyle(color: backgroundColor),
                            ),
                            onPressed: () {
                              submitDetails();
                            },
                          ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}

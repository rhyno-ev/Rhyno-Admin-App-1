import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rhyno_admin_app/components/custom_action_button.dart';
import 'package:rhyno_admin_app/components/custom_text_field.dart';
import 'package:rhyno_admin_app/components/filler.dart';
import 'package:rhyno_admin_app/helpers/constants.dart';
import 'package:rhyno_admin_app/firebase/database.dart';

class AddVehicle extends StatefulWidget {
  const AddVehicle({Key? key}) : super(key: key);

  @override
  State<AddVehicle> createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  bool vehicleImagePicked = false;
  late File vehicleImageFile;
  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController batteryController = TextEditingController();
  TextEditingController chargingController = TextEditingController();
  TextEditingController rangeController = TextEditingController();
  TextEditingController motorController = TextEditingController();

  bool buttonDisabled = false;

  //pick image from gallery
  void pickImage() async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 20);
    if (image != null) {
      setState(() {
        vehicleImageFile = File(image.path);
        vehicleImagePicked = true;
      });
    } else {
      Fluttertoast.showToast(msg: 'No file selected!');
    }
  }

  void submitVehicleDetails() async {
    Fluttertoast.showToast(msg: 'Uploading Images');
    setState(() {
      buttonDisabled = true;
    });
    try {
      await DatabaseMethods().addVehicle(nameController.text, codeController.text, modelController.text, motorController.text, batteryController.text, double.parse(rangeController.text), chargingController.text).then((value) async {
        await DatabaseMethods().uploadVehicleImage(value, vehicleImageFile);
        Fluttertoast.showToast(msg: 'Vehicle Added Successfully');
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      });
      
    }catch(err){
      Fluttertoast.showToast(msg: 'Task Failed!');
      setState(() {
        buttonDisabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Add Vehicle'),
        backgroundColor: appBarColor,
        
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: CustomActionButton(onPressed: (){
        submitVehicleDetails();
      }, title: 'Submit', buttonDisabled: buttonDisabled),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: width,
            child: Column(
              children: [
                GestureDetector(
                      onTap: () {
                        pickImage();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: CircleAvatar(
                            radius: width / 4,
                            backgroundColor: c2,
                            child: !vehicleImagePicked
                                ? const Text('Click to add photo',
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                        color: backgroundColor,
                                        fontWeight: FontWeight.bold))
                                : Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(width: 2, color: c2),
                                        borderRadius: BorderRadius.circular(100),
                                        image: DecorationImage(
                                            image: FileImage(vehicleImageFile),
                                            fit: BoxFit.cover)),
                                  )),
                      ),
                    ),
                    CustomTextField(controller: nameController, type: TextInputType.text, placeholder: 'Name'),
                    CustomTextField(controller: codeController, type: TextInputType.text, placeholder: 'Vehicle Code'),
                    CustomTextField(controller: modelController, type: TextInputType.text, placeholder: 'Model'),
                    CustomTextField(controller: motorController, type: TextInputType.text, placeholder: 'Motor Type'),
                    CustomTextField(controller: batteryController, type: TextInputType.number, placeholder: 'Battery Capacity (Ah)'),
                    CustomTextField(controller: rangeController, type: TextInputType.number, placeholder: 'Range (km)'),
                    CustomTextField(controller: chargingController, type: TextInputType.number, placeholder: 'Charging Time (hr)'),

                    const Filler()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

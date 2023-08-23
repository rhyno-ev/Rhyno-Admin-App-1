import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rhyno_admin_app/components/filler.dart';
import 'package:rhyno_admin_app/components/loading.dart';
import 'package:rhyno_admin_app/helpers/constants.dart';
import 'package:rhyno_admin_app/firebase/database.dart';
import 'package:rhyno_admin_app/helpers/helper_functions.dart';

class UpdateVehicle extends StatefulWidget {
  final String vehicleId;
  const UpdateVehicle({Key? key, required this.vehicleId}) : super(key: key);

  @override
  State<UpdateVehicle> createState() => _UpdateVehicleState();
}

class _UpdateVehicleState extends State<UpdateVehicle> {
  // bool available = false;
  double chargeLeft = 0;
  double kmsLeft = 0;
  // String status = 'unavailable';
  bool buttonDisabled = false;
  bool isLoading = true;
  Map vehicle = {};
  DateTime availableBy = DateTime.now();
  TextEditingController chargeLeftController = TextEditingController();
  TextEditingController kmsLeftController = TextEditingController();

  @override
  void initState() {
    getVehicleDetails();
    super.initState();
  }

  getVehicleDetails() async {
    await DatabaseMethods().getVehicleDetails(widget.vehicleId).then((value) {
      setState(() {
        vehicle = value;
        // available = value['available'];
        chargeLeft = value['chargeLeft'];
        kmsLeft = value['kmsLeft'];
        // status = value['status'];
        availableBy = value['availableBy'].toDate();
        isLoading = false;
      });
    });
  }

  // void updateVehicleStatus(vehicleStatus) {
  //   setState(() {
  //     status = vehicleStatus;
  //   });

  //   Navigator.pop(context);
  // }

  void submitDetails() async {
    setState(() {
      buttonDisabled = true;
    });
    await DatabaseMethods()
        .updateVehicleDetails(
            widget.vehicleId, chargeLeft, kmsLeft, availableBy)
        .then((v) {
      Fluttertoast.showToast(msg: 'Vehicle details updated');
      Navigator.pop(context);
    });
    setState(() {
      buttonDisabled = false;
    });
  }

  updateButton(double width) {
    return Container(
        width: width,
        height: width / 6,
        color: c2,
        child: buttonDisabled
            ? const Center(
                child: CircularProgressIndicator(color: backgroundColor),
              )
            : TextButton(
                onPressed: () {
                  submitDetails();
                },
                child: const Text(
                  'Update',
                  style: TextStyle(color: backgroundColor),
                ),
              ));
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return isLoading
        ? const Loading()
        : Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              title: const Text('Update Vehicle Details'),
              backgroundColor: appBarColor,
            ),
            floatingActionButton: updateButton(width),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            body: SafeArea(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: width,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: width / 2,
                          width: width / 2,
                          decoration: BoxDecoration(
                              border: Border.all(width: 2, color: c2),
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                  image: NetworkImage(vehicle['vehicleImage']),
                                  fit: BoxFit.cover)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                vehicle['name'],
                                style: const TextStyle(
                                    color: c2,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                vehicle['code'],
                                style: const TextStyle(
                                    color: c1,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        // Container(
                        //   decoration: BoxDecoration(
                        //       color: appBarColor,
                        //       borderRadius: BorderRadius.circular(10)),
                        //   margin: const EdgeInsets.all(8),
                        //   padding: const EdgeInsets.all(8),
                        //   child: ListTile(
                        //     onTap: () {
                        //       vehicleStatusModal();
                        //     },
                        //     title: const Text(
                        //       'Vehicle Status',
                        //       style: TextStyle(color: c2),
                        //     ),
                        //     subtitle: Text(
                        //       status,
                        //       style: const TextStyle(color: c1),
                        //       overflow: TextOverflow.ellipsis,
                        //     ),
                        //     trailing: const Icon(
                        //       Icons.edit,
                        //       color: c2,
                        //     ),
                        //   ),
                        // ),
                        Container(
                          decoration: BoxDecoration(
                              color: appBarColor,
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          child: ListTile(
                            onTap: () {
                              vehicleAvailable();
                            },
                            title: const Text(
                              'Vehicle Availability',
                              style: TextStyle(color: c2),
                            ),
                            subtitle: Text(
                              convertDateTime(availableBy),
                              style: const TextStyle(color: c1),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(
                              Icons.edit,
                              color: c2,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: appBarColor,
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          child: ListTile(
                            onTap: () {
                              chargeLeftModal();
                            },
                            title: const Text(
                              'Charge Left',
                              style: TextStyle(color: c2),
                            ),
                            subtitle: Text(
                              '$chargeLeft %',
                              style: const TextStyle(color: c1),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(
                              Icons.edit,
                              color: c2,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: appBarColor,
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          child: ListTile(
                            onTap: () {
                              kmsLeftModal();
                            },
                            title: const Text(
                              'Kms Left',
                              style: TextStyle(color: c2),
                            ),
                            subtitle: Text(
                              '$kmsLeft kms',
                              style: const TextStyle(color: c1),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(
                              Icons.edit,
                              color: c2,
                            ),
                          ),
                        ),
                        const Filler()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  newTextField(controller, type, placeholder, {obscureText = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
          color: c1.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
      child: TextField(
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        keyboardType: type,
        controller: controller,
        decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Colors.white),
            border: InputBorder.none),
      ),
    );
  }

  // vehicleStatusModal() {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return SimpleDialog(
  //           backgroundColor: backgroundColor,
  //           title: const Center(
  //             child: Text(
  //               'Update Vehicle Status',
  //               style: TextStyle(color: c1),
  //             ),
  //           ),
  //           children: [
  //             TextButton(
  //                 onPressed: () {
  //                   updateVehicleStatus('available');
  //                 },
  //                 child: const Text(
  //                   'Available',
  //                   style: TextStyle(color: c2),
  //                 )),
  //             TextButton(
  //                 onPressed: () {
  //                   updateVehicleStatus('charging');
  //                 },
  //                 child: const Text(
  //                   'Charging',
  //                   style: TextStyle(color: c2),
  //                 )),
  //             TextButton(
  //                 onPressed: () {
  //                   updateVehicleStatus('unavailable');
  //                 },
  //                 child: const Text(
  //                   'Unavailable',
  //                   style: TextStyle(color: c2),
  //                 )),
  //           ],
  //         );
  //       });
  // }

  vehicleAvailable() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
                primary: backgroundColor, onPrimary: c2),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: backgroundColor, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    ).then((date) {
      showTimePicker(
          context: context,
          initialTime: TimeOfDay(
              hour: DateTime.now().hour, minute: DateTime.now().minute),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                    primary: backgroundColor, onPrimary: c2),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    primary: backgroundColor, // button text color
                  ),
                ),
              ),
              child: child!,
            );
          }).then((time) {
        final newDate =
            date!.add(Duration(hours: time!.hour, minutes: time.minute));
        setState(() {
          availableBy = newDate;
        });
      });
    });
  }

  chargeLeftModal() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: backgroundColor,
            title: const Text(
              'Charge Left',
              style: TextStyle(color: c2),
            ),
            content: newTextField(chargeLeftController, TextInputType.number,
                'Enter charge left'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: c1))),
              TextButton(
                  onPressed: () {
                    setState(() {
                      chargeLeft = double.parse(chargeLeftController.text);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(color: c2))),
            ],
          );
        });
  }

  kmsLeftModal() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: backgroundColor,
            title: const Text(
              'Kms Left',
              style: TextStyle(color: c2),
            ),
            content: newTextField(
                kmsLeftController, TextInputType.number, 'Enter kms left'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: c1))),
              TextButton(
                  onPressed: () {
                    setState(() {
                      kmsLeft = double.parse(kmsLeftController.text);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(color: c2))),
            ],
          );
        });
  }
}

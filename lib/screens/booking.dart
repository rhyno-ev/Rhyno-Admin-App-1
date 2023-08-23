import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rhyno_admin_app/components/custom_modal.dart';
import 'package:rhyno_admin_app/components/loading.dart';
import 'package:rhyno_admin_app/helpers/constants.dart';
import 'package:rhyno_admin_app/firebase/database.dart';
import 'package:rhyno_admin_app/helpers/helper_functions.dart';
import 'package:rhyno_admin_app/screens/update_vehicle.dart';
import 'package:rhyno_admin_app/screens/user_location.dart';
import 'package:url_launcher/url_launcher.dart';

class Booking extends StatefulWidget {
  final Map booking;
  final String bookingId;
  const Booking({Key? key, required this.booking, required this.bookingId})
      : super(key: key);

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  Map user = {};
  Map vehicle = {};
  bool isLoading = true;
  bool approved = false;
  String status = 'active';
  double fare = 0;
  List currentRate = [];

  @override
  void initState() {
    setState(() {
      approved = widget.booking['approved'];
      status = widget.booking['status'];
      fare = widget.booking['fare'];
    });
    getCurrentRate();
    getUserDetails();
    getVehicleDetails();
    super.initState();
  }

  void getCurrentRate() async {
    await DatabaseMethods().getCurrentRate().then((value) {
      setState(() {
        currentRate = value;
      });
    });
  }

  void getUserDetails() async {
    await DatabaseMethods()
        .getUserDetails(widget.booking['userId'])
        .then((value) {
      setState(() {
        user = value;
      });
    });
  }

  void getVehicleDetails() async {
    await DatabaseMethods()
        .getVehicleDetails(widget.booking['vehicleId'])
        .then((value) {
      setState(() {
        vehicle = value;
        isLoading = false;
      });
    });
  }


  void calculateFare() async {
    final prevEndTime = widget.booking['endTime'].toDate();
    final endTime = DateTime.now();
    if (endTime.isBefore(prevEndTime.add(const Duration(minutes: 10)))) {
      final timeDifference =
          endTime.difference(widget.booking['startTime'].toDate()).inMinutes;
      int rateIndex = ((timeDifference / 60) * 2).round() - 1;
      if (rateIndex < 0) rateIndex = 0;
      double newFare = 0;
      if (rateIndex < currentRate.length) {
        newFare = currentRate[rateIndex].toDouble();
      } else {
        newFare = fare;
      }

      setState(() {
        fare = newFare;
      });
      await DatabaseMethods().endRide(widget.bookingId, newFare, endTime,
          widget.booking['userId'], widget.booking['vehicleId']);
    } else {
      final timeDifference = endTime.difference(prevEndTime).inMinutes;
      int rateIndex = ((timeDifference / 60) * 2).round() - 1;
      if (rateIndex < 0) rateIndex = 0;
      double newFare = 0;
      if (rateIndex < currentRate.length) {
        newFare = fare + currentRate[rateIndex].toDouble();
      } else {
        newFare = fare;
      }

      setState(() {
        fare = newFare;
      });
      await DatabaseMethods().endRide(widget.bookingId, newFare, endTime,
          widget.booking['userId'], widget.booking['vehicleId']);
    }
  }

  startRideModal() {
    showDialog(
        context: context,
        builder: (context) {
          return CustomModal(
              onSubmit: () async {
                await DatabaseMethods().startRide(widget.bookingId);
                setState(() {
                  approved = true;
                });
                Fluttertoast.showToast(msg: 'Ride started');
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              onCancel: () {
                Navigator.pop(context);
              },
              title: 'Start Ride',
              content: 'Are you sure you want to start the ride?');
        });
  }

  endRideModal() {
    showDialog(
        context: context,
        builder: (context) {
          return CustomModal(
              onSubmit: () {
                calculateFare();
                setState(() {
                  status = 'completed';
                });
                Navigator.pop(context);
              },
              onCancel: () {
                Navigator.pop(context);
              },
              title: 'End Ride',
              content: 'Are you sure you want to end the ride?');
        });
  }

  // cancelRideModal() {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return CustomModal(onSubmit: () async {
  //                   await DatabaseMethods().cancelBooking(widget.bookingId, widget.booking);
  //                   Fluttertoast.showToast(msg: 'Ride started');
  //                   // ignore: use_build_context_synchronously
  //                   Navigator.pop(context);
  //                 }, onCancel: () {
  //                   Navigator.pop(context);
  //                 }, title: 'Cancel Ride', content: 'Are you sure you want to cancel the ride?');
          
  //       });
  // }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return isLoading
        ? const Loading()
        : Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: appBarColor,
              title: const Text(
                'Booking',
                style: TextStyle(color: c1),
              ),
              actions: [
                IconButton(
                    onPressed: () async {
                      Uri url = Uri.parse('tel:${user['phoneNumber']}');
                      if (!await launchUrl(url)) {
                        throw 'Could not launch $url';
                      }
                    },
                    icon: const Icon(
                      Icons.call,
                      color: c2,
                    )),
                if (approved && status == 'active')
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserLocation(
                                    userId: widget.booking['userId'])));
                      },
                      icon: const Icon(
                        Icons.location_on,
                        color: c2,
                      ))
              ],
            ),
            body: SafeArea(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        userDetails(),
                        vehicleDetails(),
                        bookingDetails(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        status == 'active'
                            ? MaterialButton(
                                onPressed: () {
                                  if (!approved) {
                                    startRideModal();
                                  } else {
                                    endRideModal();
                                  }
                                },
                                color: !approved ? Colors.green : Colors.red,
                                child: !approved
                                    ? const Text(
                                        'Start Ride',
                                        style:
                                            TextStyle(color: backgroundColor),
                                      )
                                    : const Text(
                                        'End Ride',
                                        style:
                                            TextStyle(color: backgroundColor),
                                      ),
                              )
                            : MaterialButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UpdateVehicle(
                                              vehicleId: widget
                                                  .booking['vehicleId'])));
                                },
                                color: c2,
                                child: const Text(
                                  'Update Vehicle Details',
                                  style: TextStyle(color: backgroundColor),
                                ),
                              ),
                        // if (!approved)
                        //   MaterialButton(
                        //     onPressed: () {
                        //       cancelRideModal();
                        //     },
                        //     color: Colors.red,
                        //     child: const Text(
                        //       'Cancel Ride',
                        //       style: TextStyle(color: backgroundColor),
                        //     ),
                        //   )
                      ],
                    ),
                  ),
                ],
              ),
            )),
          );
  }

  Table bookingDetails() {
    return Table(
      children: [
        rowSpacer,
        TableRow(children: [
          const Text('Request Time',
              style: TextStyle(
                  color: c1, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            convertTimestamp(widget.booking['requestTime']),
            style: const TextStyle(
                color: c2, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          )
        ]),
        rowSpacer,
        TableRow(children: [
          const Text('Start Time',
              style: TextStyle(
                  color: c1, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            convertTimestamp(widget.booking['startTime']),
            style: const TextStyle(
                color: c2, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          )
        ]),
        rowSpacer,
        TableRow(children: [
          const Text('End Time',
              style: TextStyle(
                  color: c1, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            convertTimestamp(widget.booking['endTime']),
            style: const TextStyle(
                color: c2, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          )
        ]),
        rowSpacer,
        TableRow(children: [
          const Text('Duration',
              style: TextStyle(
                  color: c1, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            '${widget.booking['duration']} hr',
            style: const TextStyle(
                color: c2, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          )
        ]),
        rowSpacer,
        TableRow(children: [
          const Text('Fare',
              style: TextStyle(
                  color: c1, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            '\u{20B9} $fare',
            style: const TextStyle(
                color: c2, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          )
        ]),
        rowSpacer,
      ],
    );
  }

  Table vehicleDetails() {
    return Table(
      children: [
        rowSpacer,
        TableRow(children: [
          const Text('Vehicle Name',
              style: TextStyle(
                  color: c1, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            vehicle['name'],
            style: const TextStyle(
                color: c2, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          )
        ]),
        rowSpacer,
        TableRow(children: [
          const Text('Vehicle Code',
              style: TextStyle(
                  color: c1, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            '${vehicle['code']}',
            style: const TextStyle(
                color: c2, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          )
        ]),
        rowSpacer,
      ],
    );
  }

  Table userDetails() {
    return Table(
      children: [
        rowSpacer,
        TableRow(children: [
          const Text('Booked by',
              style: TextStyle(
                  color: c1, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            user['name'],
            style: const TextStyle(
                color: c2, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          )
        ]),
        rowSpacer,
        TableRow(children: [
          const Text('Phone Number',
              style: TextStyle(
                  color: c1, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            '${user['phoneNumber']}',
            style: const TextStyle(
                color: c2, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          )
        ]),
        rowSpacer,
      ],
    );
  }

  final rowSpacer = const TableRow(children: [
    SizedBox(
      height: 16,
    ),
    SizedBox(
      height: 16,
    )
  ]);
}

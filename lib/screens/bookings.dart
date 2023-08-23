import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rhyno_admin_app/components/custom_text_field.dart';
import 'package:rhyno_admin_app/components/loading.dart';
import 'package:rhyno_admin_app/helpers/constants.dart';
import 'package:rhyno_admin_app/firebase/database.dart';
import 'package:rhyno_admin_app/helpers/helper_functions.dart';
import 'package:rhyno_admin_app/screens/booking.dart';

class Bookings extends StatefulWidget {
  const Bookings({Key? key}) : super(key: key);

  @override
  State<Bookings> createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  String bookingType = 'pending';
  String phoneNumber = '';


  @override
  void initState() {
    super.initState();
  }


  Widget bookingTypeButton(width) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: width / 8,
      width: width,
      decoration:
          BoxDecoration(color: c2, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                bookingType = 'pending';
              });
            },
            child: Container(
              alignment: Alignment.center,
              height: width / 10,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: bookingType == 'pending'
                      ? backgroundColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Pending',
                style: TextStyle(
                    color: bookingType == 'pending' ? c2 : backgroundColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                bookingType = 'active';
              });
            },
            child: Container(
              alignment: Alignment.center,
              height: width / 10,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: bookingType == 'active'
                      ? backgroundColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Active',
                style: TextStyle(
                    color: bookingType == 'active' ? c2 : backgroundColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                bookingType = 'completed';
              });
            },
            child: Container(
              alignment: Alignment.center,
              height: width / 10,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: bookingType == 'completed'
                      ? backgroundColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Completed',
                style: TextStyle(
                    color: bookingType == 'completed' ? c2 : backgroundColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget pendingBookingsList(width) {
    return StreamBuilder(
      stream: DatabaseMethods().getPendingBookings(phoneNumber),
      builder: (context, AsyncSnapshot snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Loading();
        }
        return snapshot.hasData
            ? snapshot.data.docs.length > 0
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      Map booking = snapshot.data.docs[index].data();
                      return bookingListTile(width, booking, snapshot.data.docs[index].id);
                    },
                  )
                : Center(
                    child: Column(
                      children: const [
                        Icon(
                          Icons.notes_rounded,
                          color: c1,
                          size: 100,
                        ),
                        Text(
                          'No pending bookings',
                          style: TextStyle(color: c1),
                        ),
                      ],
                    ),
                  )
            : const Loading();
      },
    );
  }

  Widget activeBookingsList(width) {
    return StreamBuilder(
      stream: DatabaseMethods().getActiveBookings(phoneNumber),
      builder: (context, AsyncSnapshot snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Loading();
        }
        return snapshot.hasData
            ? snapshot.data.docs.length > 0
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      Map booking = snapshot.data.docs[index].data();
                      return bookingListTile(width, booking, snapshot.data.docs[index].id);
                    },
                  )
                : Center(
                    child: Column(
                      children: const [
                        Icon(
                          Icons.notes_rounded,
                          color: c1,
                          size: 100,
                        ),
                        Text(
                          'No active bookings',
                          style: TextStyle(color: c1),
                        ),
                      ],
                    ),
                  )
            : const Loading();
      },
    );
  }

  Widget completedBookingsList(width) {
    return StreamBuilder(
      stream: DatabaseMethods().getCompletedBookings(phoneNumber),
      builder: (context, AsyncSnapshot snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Loading();
        }
        return snapshot.hasData
            ? snapshot.data.docs.length > 0
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      Map booking = snapshot.data.docs[index].data();
                      return bookingListTile(width, booking, snapshot.data.docs[index].id);
                    },
                  )
                : Center(
                    child: Column(
                      children: const [
                        Icon(
                          Icons.notes_rounded,
                          color: c1,
                          size: 100,
                        ),
                        Text(
                          'No completed bookings',
                          style: TextStyle(color: c1),
                        ),
                      ],
                    ),
                  )
            : const Loading();
      },
    );
  }

  Widget bookingListTile(width, booking, bookingId) {
    return FutureBuilder(
      future: DatabaseMethods().getVehicleDetails(booking['vehicleId']),
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => Booking(booking: booking, bookingId: bookingId,)));
              },
              child: Container(
                  height: width / 3,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: appBarColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${snapshot.data['name']} - ${snapshot.data['code']}',
                                style: const TextStyle(
                                    color: c2,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              Text(
                                convertTimestamp(booking['startTime']),
                                style: const TextStyle(
                                    color: c2,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                              Text(
                                '${booking['phoneNumber']}',
                                style: const TextStyle(
                                    color: c2,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Duration: ${booking['duration']} hr',
                                style: const TextStyle(
                                    color: c1,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                              Text(
                                'Fare: \u{20B9}${booking['fare']}',
                                style: const TextStyle(
                                    color: c1,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              )
                            ],
                          )
                        ],
                      ),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            snapshot.data['vehicleImage'],
                            height: width / 5,
                            width: width / 5,
                          ))
                    ],
                  ),
                ),
            )
            : const SizedBox();
      },
    );
  }

  selectBookingType(width) {
    if (bookingType == 'pending') {
      return pendingBookingsList(width);
    } else if (bookingType == 'active') {
      return activeBookingsList(width);
    } else {
      return completedBookingsList(width);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 8),
            child: Text(
              'Booking Status',
              style: TextStyle(color: c2, fontWeight: FontWeight.bold),
            ),
          ),
          bookingTypeButton(width),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: c1.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10)),
            child: TextField(
              onChanged: (text){
                setState(() {
                  phoneNumber = text;
                });
              },
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  hintText: 'Search by phone number',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none),
            ),
          ),
          Expanded(child: selectBookingType(width))
        ],
      )),
    );
  }
}

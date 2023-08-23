import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rhyno_admin_app/components/loading.dart';
import 'package:rhyno_admin_app/helpers/constants.dart';
import 'package:rhyno_admin_app/firebase/database.dart';
import 'package:rhyno_admin_app/helpers/helper_functions.dart';
import 'package:rhyno_admin_app/screens/booking.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {

  bool seen = false;

  selectNotificationTypeButton(width) {
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
                seen = false;
              });
            },
            child: Container(
              alignment: Alignment.center,
              height: width / 10,
              width: width / 3,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: !seen
                      ? backgroundColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                'New',
                style: TextStyle(
                    color: !seen ? c2 : backgroundColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                seen = true;
              });
            },
            child: Container(
              alignment: Alignment.center,
              height: width / 10,
              width: width / 3,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: seen
                      ? backgroundColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Older',
                style: TextStyle(
                    color: seen ? c2 : backgroundColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }


  notificationBuilder(seen){
    return StreamBuilder(
      stream: DatabaseMethods().getRideRequest(seen),
      builder: (context, AsyncSnapshot snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(color: c2,),
            ),
          );
        }
        return snapshot.hasData && snapshot.data.docs.length > 0 ? ListView.builder(
        itemCount: snapshot.data.docs.length,
        shrinkWrap: true,
        itemBuilder: (context, index){
          final notification = snapshot.data.docs[index];
          return Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appBarColor,
              borderRadius: BorderRadius.circular(10)
            ),
            child: ListTile(
              title: Text(notification['body'], style: TextStyle(color: c2)),
              trailing: Text(convertTimestamp(notification['time']), textAlign: TextAlign.center, style: TextStyle(fontSize: 8, color: c1),),
              onTap: () async {
                final booking = await DatabaseMethods().getBookingByBookingId(notification['bookingId']);
                // ignore: use_build_context_synchronously
                Navigator.push(context, MaterialPageRoute(builder: (context) => Booking(booking: booking, bookingId: notification['bookingId'],)));
                await DatabaseMethods().stopRideRequest(notification.id);
              },
            ),
          );
        },
      ): Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(seen ? 'No previous notifications.' : 'No new notifications.', style: TextStyle(color: c1),),
        ),
      );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: appBarColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 8),
            child: Text('Notification Type', style: TextStyle(color: c2, fontWeight: FontWeight.bold),),
          ),
          selectNotificationTypeButton(width),
          Expanded(child: seen ? notificationBuilder(true) : notificationBuilder(false))
        ],
      )
    );
  }
}
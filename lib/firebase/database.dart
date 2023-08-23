import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DatabaseMethods {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  Future createAdminProfile(name, phoneNumber, userId) async {
    Map<String, dynamic> admin = {
      "name": name,
      "phoneNumber": phoneNumber,
    };

    await firestore.collection('admins').doc(userId).set(admin).then((value) {
      Fluttertoast.showToast(msg: 'Admin Registered Successfully');
    }).onError((error, stackTrace) {
      Fluttertoast.showToast(msg: 'Admin Registration Failed!');
    });
  }

  updateProfileImage(userId, file) async {
    final filePath = 'users/$userId/profileImage';
    // await storage.ref(filePath).delete().catchError((onError){
    //   print('deletion failed');
    // });

    await storage.ref(filePath).putFile(file);

    await storage.ref(filePath).getDownloadURL().then((value) async {
      await firestore
          .collection('users')
          .doc(userId)
          .update({"profileImage": value});
    });
  }

  updateLicenseImage(userId, file) async {
    final filePath = 'users/$userId/licenseImage';
    // await storage.ref(filePath).delete().catchError((onError){
    //   print('deletion failed');
    // });

    await storage.ref(filePath).putFile(file);

    await storage.ref(filePath).getDownloadURL().then((value) async {
      await firestore
          .collection('users')
          .doc(userId)
          .update({"licenseImage": value});
    });
  }

  findAdminWithPhoneNumber(phoneNumber) async {
    var admin = {};
    await firestore
        .collection('admins')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        admin = value.docs[0].data();
      }
    });
    return admin;
  }

  findUserWithPhoneNumber(phoneNumber) async {
    var user = {};
    await firestore
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        user = value.docs[0].data();
      }
    });
    return user;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getAdminSnapshots(userId) {
    return firestore.collection('admins').doc(userId).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserSnapshots(userId) {
    return firestore.collection('users').doc(userId).snapshots();
  }

  getVerificationStatus(userId) async {
    return (await firestore.collection('users').doc(userId).get())
        .data()!['verifiedItems'];
  }

  addVehicle(String name, String code, String model, String motorType, String batteryCapacity, double range,
      String chargingTime) async {
    final vehicle = {
      'name': name,
      'code': code,
      'model': model,
      'motorType': motorType,
      'batteryCapacity': batteryCapacity,
      'range': range,
      'chargingTime': chargingTime,
      'vehicleImage': '',
      // 'available': true,
      'availableBy': DateTime.now(),
      // 'status': 'available',
      'chargeLeft': 100.0,
      'kmsLeft': range,
    };

    final docRef = firestore.collection('vehicles').doc();

    await docRef.set(vehicle);
    return docRef.id;
  }

  uploadVehicleImage(vehicleId, file) async {
    final filePath = 'vehicles/$vehicleId/vehicleImage';

    await storage.ref(filePath).putFile(file);

    await storage.ref(filePath).getDownloadURL().then((value) async {
      await firestore
          .collection('vehicles')
          .doc(vehicleId)
          .update({"vehicleImage": value});
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getVehiclesList(vehicleCode) {
    if(vehicleCode != ''){
      return firestore
        .collection('vehicles')
        .where('code', isEqualTo: vehicleCode)
        .snapshots();
    }
    return firestore
        .collection('vehicles')
        .orderBy('availableBy', descending: true)
        .snapshots();
  }

  getActiveBookings(phoneNumber) {
    if (phoneNumber != '') {
      return firestore
          .collection('bookings')
          .where('status', isEqualTo: 'active')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .where('approved', isEqualTo: true)
          .orderBy('startTime', descending: true)
          .snapshots();
    }
    return firestore
        .collection('bookings')
        .where('status', isEqualTo: 'active')
        .where('approved', isEqualTo: true)
        .orderBy('startTime', descending: true)
        .snapshots();
  }

  getCompletedBookings(phoneNumber) {
    if (phoneNumber != '') {
      return firestore
          .collection('bookings')
          .where('status', isEqualTo: 'completed')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .orderBy('startTime', descending: true)
          .snapshots();
    }
    return firestore
        .collection('bookings')
        .where('status', isEqualTo: 'completed')
        .orderBy('startTime', descending: true)
        .snapshots();
  }

  getPendingBookings(phoneNumber) {
    if (phoneNumber != '') {
      return firestore
          .collection('bookings')
          .where('approved', isEqualTo: false)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .orderBy('startTime', descending: true)
          .snapshots();
    }
    return firestore
        .collection('bookings')
        .where('approved', isEqualTo: false)
        .orderBy('startTime', descending: true)
        .snapshots();
  }

  getBookingByPhoneNumber(phoneNumber) {
    return firestore
        .collection('bookings')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .orderBy('startTime', descending: true)
        .snapshots();
  }

  getBookingByBookingId(bookingId) async {
    return (await firestore.collection('bookings').doc(bookingId).get()).data();
  }

  getVerifiedUsers(phoneNumber) {
    if (phoneNumber != '') {
      return firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .where('verification', isEqualTo: 'verified')
          .orderBy('name')
          .snapshots();
    }
    return firestore
        .collection('users')
        .where('verification', isEqualTo: 'verified')
        .orderBy('name')
        .snapshots();
  }

  getUnverifiedUsers(phoneNumber) {
    if (phoneNumber != '') {
      return firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .where('verification', whereIn: ['pending', 'discarded'])
          .orderBy('name')
          .snapshots();
    }
    return firestore
        .collection('users')
        .where('verification', whereIn: ['pending', 'discarded'])
        .orderBy('name')
        .snapshots();
  }

  updateVerificationStatus(userId, verifiedItems) async {
    String verification = 'pending';
    if (verifiedItems['drivingLicense'] == 'verified' &&
        verifiedItems['identityCard'] == 'verified') {
      verification = 'verified';
    } else if (verifiedItems['drivingLicense'] == 'discarded' ||
        verifiedItems['identityCard'] == 'discarded') {
      verification = 'discarded';
    }
    await firestore
        .collection('users')
        .doc(userId)
        .update({'verifiedItems': verifiedItems, 'verification': verification});
  }

  getUserDetails(userId) async {
    return (await firestore.collection('users').doc(userId).get()).data();
  }

  getAdminDetails(userId) async {
    return (await firestore.collection('admins').doc(userId).get()).data();
  }

  getVehicleDetails(vehicleId) async {
    return (await firestore.collection('vehicles').doc(vehicleId).get()).data();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getVehicleSnapshots(
      String vehicleId) {
    return firestore.collection('vehicles').doc(vehicleId).snapshots();
  }

  getConfigSettings() async {
    return (await firestore.collection('config').get()).docs[0].data();
  }

  updateCongifSettings(configSettings) async {
    final configId = (await firestore.collection('config').get()).docs[0].id;
    await firestore.collection('config').doc(configId).update(configSettings);
  }

  startRide(bookingId) async {
    await firestore
        .collection('bookings')
        .doc(bookingId)
        .update({'approved': true, 'startTime': DateTime.now()});
  }

  endRide(bookingId, fare, endTime, userId, vehicleId) async {
    final bufferTime =
        (await firestore.collection('config').get()).docs[0]['bufferTime'];

    await firestore
        .collection('bookings')
        .doc(bookingId)
        .update({'status': 'completed', 'fare': fare, 'endTime': endTime});

    await firestore
        .collection('vehicles/$vehicleId/bookings')
        .doc(bookingId)
        .delete();

    await firestore
        .collection('vehicles')
        .doc(vehicleId)
        .update({'availableBy': endTime.add(Duration(minutes: bufferTime))});

    final userBalance = (await firestore.collection('users').doc(userId).get())
        .data()!['balance'];
    final securityDeposit =
        (await firestore.collection('users').doc(userId).get())
            .data()!['securityDeposit'];
    if (userBalance < fare) {
      final due = fare - userBalance;
      await firestore
          .collection('users')
          .doc(userId)
          .update({'balance': 0, 'securityDeposit': securityDeposit - due, 'isRiding': false});
    } else {
      await firestore
          .collection('users')
          .doc(userId)
          .update({'balance': userBalance - fare, 'isRiding': false});
    }
  }

  Future getCurrentRate() async {
    return (await firestore.collection('config').get()).docs[0]['currentRate'];
  }

  updateVehicleDetails(vehicleId, chargeLeft, kmsLeft, availableBy) async {
    // if (status == 'available') {
      await firestore.collection('vehicles').doc(vehicleId).update({
        // 'status': status,
        'chargeLeft': chargeLeft,
        // 'available': true,
        'kmsLeft': kmsLeft,
        'availableBy': availableBy
      });
    // } else {
    //   await firestore.collection('vehicles').doc(vehicleId).update({
    //     'status': status,
    //     'chargeLeft': chargeLeft,
    //     // 'available': false,
    //     'kmsLeft': kmsLeft,
    //     'availableBy': availableBy
    //   });
    // }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getEndRideRequest(seen){
    return firestore.collection('requests').where('type', isEqualTo: 'end').where('seen', isEqualTo: seen).orderBy('time', descending: true).snapshots();
  }
  

  Stream<QuerySnapshot<Map<String, dynamic>>> getStartRideRequest(seen){
    return firestore.collection('requests').where('type', isEqualTo: 'start').where('seen', isEqualTo: seen).orderBy('time', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRideRequest(seen){
    return firestore.collection('requests').where('seen', isEqualTo: seen).orderBy('time', descending: true).snapshots();
  }

  stopRideRequest(requestId) async {
    await firestore.collection('requests').doc(requestId).update({
      'seen': true
    });
  }

  Future getBufferTime() async {
    return (await firestore.collection('config').get()).docs[0]['bufferTime'];
  }
  
  cancelBooking(bookingId, booking) async {
    int timeLeft = booking['endTime']
        .toDate()
        .difference(DateTime.now())
        .inMinutes
        .toInt();
    int bufferTime = await getBufferTime();
    DateTime availableBy = booking['endTime']
        .toDate()
        .subtract(Duration(minutes: timeLeft))
        .subtract(Duration(minutes: bufferTime));

    await firestore
        .collection('vehicles')
        .doc(booking['vehicleId'])
        .update({'availableBy': availableBy});

    await firestore
        .collection('users')
        .doc(booking['userId'])
        .update({'isRiding': false});
    await firestore.collection('bookings').doc(bookingId).delete();

    await firestore
        .collection('vehicles')
        .doc(booking['vehicleId'])
        .collection('bookings')
        .doc(bookingId)
        .delete();
  }
}

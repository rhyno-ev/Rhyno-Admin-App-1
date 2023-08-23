import 'package:flutter/material.dart';
import 'package:rhyno_admin_app/components/loading.dart';
import 'package:rhyno_admin_app/helpers/constants.dart';
import 'package:rhyno_admin_app/firebase/auth.dart';
import 'package:rhyno_admin_app/firebase/database.dart';
import 'package:rhyno_admin_app/helpers/shared_prefernces.dart';
import 'package:rhyno_admin_app/screens/auth/login.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading = true;
  Map admin = {};

  @override
  void initState() {
    getAdminDetails();
    super.initState();
  }

  getAdminDetails() async {
    final adminId = await SPMethods().getUserId();
    await DatabaseMethods().getAdminDetails(adminId).then((value) {
      setState(() {
        admin = value;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Loading()
        : Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: appBarColor,
              title: const Text('Profile'),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                      onPressed: () async {
                        await AuthMethods().signout();
                        await SPMethods().removeAllData();

                        // ignore: use_build_context_synchronously
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()),
                            (route) => false);
                      },
                      child: const Text(
                        'Signout',
                        style: TextStyle(color: c2),
                      )),
                )
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: adminDetails(),
                )
              ],
            ),
          );
  }

  Table adminDetails() {
    return Table(
      children: [
        rowSpacer,
        TableRow(children: [
          const Text('Name',
              style: TextStyle(
                  color: c1, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            admin['name'],
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
            '${admin['phoneNumber']}',
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

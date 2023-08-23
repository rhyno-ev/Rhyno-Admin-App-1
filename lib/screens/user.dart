import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rhyno_admin_app/components/custom_action_button.dart';
import 'package:rhyno_admin_app/components/filler.dart';
import 'package:rhyno_admin_app/components/loading.dart';
import 'package:rhyno_admin_app/helpers/constants.dart';
import 'package:rhyno_admin_app/firebase/database.dart';

class User extends StatefulWidget {
  final String userId;
  final Map user;
  const User({Key? key, required this.userId, required this.user})
      : super(key: key);

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  // Map user = {};
  bool isLoading = true;
  Map verifiedItems = {
    'drivingLicense': 'pending',
    'identityCard': 'pending',
  };

  @override
  void initState() {
    super.initState();
    getVerificationStatus();
  }

  void getVerificationStatus() async {
    await DatabaseMethods().getVerificationStatus(widget.userId).then((value) {
      setState(() {
        verifiedItems = value;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return isLoading
        ? const Loading()
        : Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: appBarColor,
              title: const Text('User Profile'),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: CustomActionButton(
                onPressed: () async {
                  await DatabaseMethods()
                      .updateVerificationStatus(widget.userId, verifiedItems);
                  Fluttertoast.showToast(msg: 'Details updated');
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                buttonDisabled: false,
                title: 'Update'),
            body: SafeArea(
                child: SingleChildScrollView(
              child: Container(
                  padding: const EdgeInsets.all(16),
                  width: width,
                  child: Column(
                    children: [
                      Container(
                        width: width / 2.5,
                        height: width / 2.5,
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: c2),
                            borderRadius: BorderRadius.circular(100),
                            image: DecorationImage(
                                image:
                                    NetworkImage(widget.user['profileImage']),
                                fit: BoxFit.cover)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.user['name'],
                          style: const TextStyle(
                              color: c2,
                              fontWeight: FontWeight.bold,
                              fontSize: 24),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Information',
                            style: TextStyle(
                                color: c1,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          )),
                      userDetails(),
                      verifiedImages(width),
                      const Filler()
                    ],
                  )),
            )),
          );
  }

  verifiedImages(width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Driving License',
          style: TextStyle(color: c2, fontWeight: FontWeight.bold),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                showImageModal(widget.user['licenseImage'], width);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: width / 2,
                height: width / 3,
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: c2),
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: NetworkImage(widget.user['licenseImage']),
                        fit: BoxFit.cover)),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: verifiedItems['drivingLicense'] == 'pending'
                    ? Column(
                        children: [
                          Text('Verify',
                              style: TextStyle(
                                  color: c2, fontWeight: FontWeight.bold)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      verifiedItems['drivingLicense'] =
                                          'verified';
                                    });
                                  },
                                  icon: Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 32,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      verifiedItems['drivingLicense'] =
                                          'discarded';
                                    });
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 32,
                                  )),
                            ],
                          )
                        ],
                      )
                    : Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: appBarColor,
                        ),
                        child: verifiedItems['drivingLicense'] == 'verified'
                            ? Text(
                                'Verified',
                                style: TextStyle(color: Colors.green),
                              )
                            : Text(
                                'Discarded',
                                style: TextStyle(color: Colors.red),
                              ),
                      ),
              ),
            )
          ],
        ),
        const Text(
          'Indentity Card',
          style: TextStyle(color: c2, fontWeight: FontWeight.bold),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                showImageModal(widget.user['identityCardImage'], width);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: width / 2,
                height: width / 3,
                decoration: BoxDecoration(
                    border: Border.all(width: 2, color: c2),
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: NetworkImage(widget.user['identityCardImage']),
                        fit: BoxFit.cover)),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: verifiedItems['identityCard'] == 'pending'
                    ? Column(
                        children: [
                          Text('Verify',
                              style: TextStyle(
                                  color: c2, fontWeight: FontWeight.bold)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      verifiedItems['identityCard'] =
                                          'verified';
                                    });
                                  },
                                  icon: Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 32,
                                  )),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      verifiedItems['identityCard'] =
                                          'discarded';
                                    });
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 32,
                                  )),
                            ],
                          )
                        ],
                      )
                    : Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: appBarColor,
                        ),
                        child: verifiedItems['identityCard'] == 'verified'
                            ? Text(
                                'Verified',
                                style: TextStyle(color: Colors.green),
                              )
                            : Text(
                                'Discarded',
                                style: TextStyle(color: Colors.red),
                              ),
                      ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Table userDetails() {
    return Table(
      children: [
        rowSpacer,
        TableRow(children: [
          const Text('Phone Number',
              style: TextStyle(
                  color: c1, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            widget.user['phoneNumber'],
            style: const TextStyle(
                color: c2, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          )
        ]),
        rowSpacer,
        TableRow(children: [
          const Text('Balance',
              style: TextStyle(
                  color: c1, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            '\u{20B9} ${widget.user['balance']}',
            style: const TextStyle(
                color: c2, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          )
        ]),
        rowSpacer,
        TableRow(children: [
          const Text('Security Deposit',
              style: TextStyle(
                  color: c1, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            '\u{20B9} ${widget.user['securityDeposit']}',
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

  void showImageModal(imageUrl, width) {
    showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: appBarColor.withOpacity(0.8),
        builder: (context) {
          return InteractiveViewer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      imageUrl,
                      width: width,
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Go Back'))
              ],
            ),
          );
        });
  }
}

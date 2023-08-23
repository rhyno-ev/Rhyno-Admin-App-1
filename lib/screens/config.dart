import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rhyno_admin_app/components/custom_text_field.dart';
import 'package:rhyno_admin_app/components/loading.dart';
import 'package:rhyno_admin_app/helpers/constants.dart';
import 'package:rhyno_admin_app/firebase/database.dart';

class Config extends StatefulWidget {
  const Config({Key? key}) : super(key: key);

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  bool isLoading = true;
  Map config = {};
  bool buttonDisabled = false;
  List fareRateList = [];

  TextEditingController fareRateController = TextEditingController();
  TextEditingController bufferTimeController = TextEditingController();
  TextEditingController minSecurityDepositController = TextEditingController();
  TextEditingController newAdminCodeController = TextEditingController();
  TextEditingController currentAdminCodeController = TextEditingController();
  TextEditingController userLimitController = TextEditingController();
  TextEditingController adminNumberController = TextEditingController();

  @override
  void initState() {
    getConfigSettings();
    super.initState();
  }

  getConfigSettings() async {
    await DatabaseMethods().getConfigSettings().then((value) {
      setState(() {
        config = value;
        fareRateList = value['currentRate'];
        isLoading = false;
      });
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
          : Center(
              child: TextButton(
                onPressed: () async {
                  setState(() {
                    buttonDisabled = true;
                  });
                  await DatabaseMethods()
                      .updateCongifSettings(config)
                      .then((v) {
                    Fluttertoast.showToast(msg: 'Config Settings Updated');
                  });
                  setState(() {
                    buttonDisabled = false;
                  });
                },
                child: const Text('Update',
                    style: TextStyle(color: backgroundColor)),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return isLoading
        ? const Loading()
        : Scaffold(
            backgroundColor: backgroundColor,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: updateButton(width),
            body: SafeArea(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: appBarColor,
                        borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      onTap: () {
                        adminNumberModal();
                      },
                      title: const Text(
                        'Admin Phone Number',
                        style: TextStyle(color: c2),
                      ),
                      subtitle: Text(
                        '${config['adminNumber']}',
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
                        fareRateModal();
                      },
                      title: const Text(
                        'Fare rate (half hourly basis)',
                        style: TextStyle(color: c2),
                      ),
                      subtitle: Text(
                        '${config['currentRate']}',
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
                        bufferTimeModal();
                      },
                      title: const Text(
                        'Buffer Time',
                        style: TextStyle(color: c2),
                      ),
                      subtitle: Text(
                        '${config['bufferTime']} min',
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
                        minSecurityDepositModal();
                      },
                      title: const Text(
                        'Min Security Deposit',
                        style: TextStyle(color: c2),
                      ),
                      subtitle: Text(
                        '\u{20B9} ${config['minSecurityDeposit']}',
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
                        adminCodeModal();
                      },
                      title: const Text(
                        'Admin Code',
                        style: TextStyle(color: c2),
                      ),
                      subtitle: const Text(
                        '******',
                        style: TextStyle(color: c1),
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
                        userLimitModal();
                      },
                      title: const Text(
                        'User Limit',
                        style: TextStyle(color: c2),
                      ),
                      subtitle: Text(
                        '${config['userLimit']}',
                        style: const TextStyle(color: c1),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(
                        Icons.edit,
                        color: c2,
                      ),
                    ),
                  ),
                  SizedBox(height: width,)
                ],
              ),
            )),
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

  // fareRateModal() {
  //   showDialog(
  //       context: context,
  //       builder: (context) {
  //         return SimpleDialog(
  //           backgroundColor: backgroundColor,
  //           title: const Text(
  //             'Fare Rate',
  //             style: TextStyle(color: c2),
  //           ),
  //           children: [
  //             const Padding(
  //               padding: EdgeInsets.symmetric(horizontal: 24),
  //               child: Text(
  //                 'Enter half hourly rates (space separated)',
  //                 style: TextStyle(color: c1),
  //               ),
  //             ),
  //             Padding(
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  //               child: Text(
  //                 'Current Rate : ${config['currentRate']}',
  //                 style: const TextStyle(color: c1),
  //               ),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 16),
  //               child: newTextField(fareRateController, TextInputType.number,
  //                   'Enter fare rates'),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: [
  //                   TextButton(
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                       },
  //                       child:
  //                           const Text('Cancel', style: TextStyle(color: c1))),
  //                   TextButton(
  //                       onPressed: () {
  //                         List fareList =
  //                             fareRateController.text.toString().split(' ');
  //                         List<int> fareRateList = [];
  //                         for (int i = 0; i < fareList.length; i++) {
  //                           fareRateList.add(int.parse(fareList[i]));
  //                         }
  //                         setState(() {
  //                           config['currentRate'] = fareRateList;
  //                         });
  //                         Navigator.pop(context);
  //                       },
  //                       child: const Text('Save', style: TextStyle(color: c2))),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         );
  //       });
  // }
  fareRateModal() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: backgroundColor,
            title: const Text(
              'Fare Rate',
              style: TextStyle(color: c2),
            ),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Enter half hourly rates (space separated)',
                  style: TextStyle(color: c1),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(
                  'Current Rate : ${config['currentRate']}',
                  style: const TextStyle(color: c1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: newTextField(fareRateController, TextInputType.number,
                    'Enter fare rates'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child:
                            const Text('Cancel', style: TextStyle(color: c1))),
                    TextButton(
                        onPressed: () {
                          List fareList =
                              fareRateController.text.toString().split(' ');
                          List<int> fareRateList = [];
                          for (int i = 0; i < fareList.length; i++) {
                            fareRateList.add(int.parse(fareList[i]));
                          }
                          setState(() {
                            config['currentRate'] = fareRateList;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Save', style: TextStyle(color: c2))),
                  ],
                ),
              ),
            ],
          );
        });
  }

  bufferTimeModal() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: backgroundColor,
            title: const Text(
              'Buffer Time',
              style: TextStyle(color: c2),
            ),
            content: newTextField(bufferTimeController, TextInputType.number,
                'Enter buffer time (minutes)'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: c1))),
              TextButton(
                  onPressed: () {
                    setState(() {
                      config['bufferTime'] =
                          int.parse(bufferTimeController.text);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(color: c2))),
            ],
          );
        });
  }

  minSecurityDepositModal() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: backgroundColor,
            title: const Text(
              'Min Security Deposit',
              style: TextStyle(color: c2),
            ),
            content: newTextField(minSecurityDepositController, TextInputType.number,
                'Enter minimum security deposit'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: c1))),
              TextButton(
                  onPressed: () {
                    setState(() {
                      config['minSecurityDeposit'] =
                          double.parse(minSecurityDepositController.text);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(color: c2))),
            ],
          );
        });
  }

  adminCodeModal() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: backgroundColor,
            title: const Text(
              'Admin Code',
              style: TextStyle(color: c2),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: newTextField(currentAdminCodeController,
                    TextInputType.number, 'Enter current admin code',
                    obscureText: true),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: newTextField(newAdminCodeController,
                    TextInputType.number, 'Enter new admin code',
                    obscureText: true),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child:
                            const Text('Cancel', style: TextStyle(color: c1))),
                    TextButton(
                        onPressed: () {
                          if (config['adminCode'] ==
                              currentAdminCodeController.text) {
                            setState(() {
                              config['adminCode'] = newAdminCodeController.text;
                            });
                            Navigator.pop(context);
                          } else {
                            Fluttertoast.showToast(msg: 'Wrong Admin Code');
                          }
                        },
                        child: const Text('Save', style: TextStyle(color: c2))),
                  ],
                ),
              ),
            ],
          );
        });
  }

  userLimitModal() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: backgroundColor,
            title: const Text(
              'User Limit',
              style: TextStyle(color: c2),
            ),
            content: newTextField(
                userLimitController, TextInputType.number, 'Enter user limit'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: c1))),
              TextButton(
                  onPressed: () {
                    setState(() {
                      config['userLimit'] = int.parse(userLimitController.text);
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(color: c2))),
            ],
          );
        });
  }

  adminNumberModal() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: backgroundColor,
            title: const Text(
              'Admin Phone Number',
              style: TextStyle(color: c2),
            ),
            content: newTextField(adminNumberController, TextInputType.number,
                'Enter phone number'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: c1))),
              TextButton(
                  onPressed: () {
                    setState(() {
                      config['adminNumber'] = adminNumberController.text;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(color: c2))),
            ],
          );
        });
  }
}

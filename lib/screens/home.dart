import 'package:flutter/material.dart';
import 'package:rhyno_admin_app/components/loading.dart';
import 'package:rhyno_admin_app/components/notification_dot.dart';
import 'package:rhyno_admin_app/helpers/constants.dart';
import 'package:rhyno_admin_app/firebase/auth.dart';
import 'package:rhyno_admin_app/firebase/database.dart';
import 'package:rhyno_admin_app/helpers/shared_prefernces.dart';
import 'package:rhyno_admin_app/screens/auth/login.dart';
import 'package:rhyno_admin_app/screens/bookings.dart';
import 'package:rhyno_admin_app/screens/config.dart';
import 'package:rhyno_admin_app/screens/notifications.dart';
import 'package:rhyno_admin_app/screens/profile.dart';
import 'package:rhyno_admin_app/screens/users.dart';
import 'package:rhyno_admin_app/screens/vehicles.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this, initialIndex: 0);
    super.initState();
  }

  Widget userNotificationBadge() {
    return StreamBuilder(
      stream: DatabaseMethods().getUnverifiedUsers(''),
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData && snapshot.data.docs.length > 0
            ? const NotifationDot()
            : Container();
      },
    );
  }

  Widget bookingNotificationBadge() {
    return StreamBuilder(
      stream: DatabaseMethods().getPendingBookings(''),
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData && snapshot.data.docs.length > 0
            ? const NotifationDot()
            : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(5))),
          backgroundColor: appBarColor,
          elevation: 0,
          title: Image.asset(
            'assets/images/logo.png',
            height: width / 8,
          ),
          actions: [
            Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      children: [
                        StreamBuilder(
                          stream: DatabaseMethods().getRideRequest(false),
                          builder: (context, AsyncSnapshot snapshot) {
                            return snapshot.hasData &&
                                    snapshot.data.docs.length > 0
                                ? Stack(
                                    children: [
                                      IconButton(
                                          onPressed: () async {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => const Notifications()));
                                          },
                                          icon: const Icon(
                                            Icons.notifications,
                                            color: c2,
                                          )),
                                      const Positioned(
                                          right: 10,
                                          top: 10,
                                          child: NotifationDot())
                                    ],
                                  )
                                : IconButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Notifications()));
                                    },
                                    icon: const Icon(
                                      Icons.notifications,
                                      color: c2,
                                    ));
                          },
                        ),
                        IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Profile()),
                    );
                  },
                  icon: const Icon(
                    Icons.person,
                    color: c2,
                  )),
                      ],
                    ),
                  ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  labelColor: backgroundColor,
                  unselectedLabelColor: c1,
                  padding: const EdgeInsets.all(8),
                  isScrollable: true,
                  indicatorSize: TabBarIndicatorSize.tab,
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: c2,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  tabs: [
                    Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: 30,
                          child: const Text(
                            'Bookings',
                          ),
                        ),
                        Positioned(right: 0, top: 5,child: bookingNotificationBadge())
                      ],
                    ),
                    Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: 30,
                          child: const Text(
                            'Users',
                          ),
                        ),
                        Positioned(right: 0, top: 5,child: userNotificationBadge())
                      ],
                    ),
                    Container(
                        alignment: Alignment.center,
                        height: 30,
                        child: const Text(
                          'Vehicles',
                        )),
                    Container(
                        alignment: Alignment.center,
                        height: 30,
                        child: const Text(
                          'Config',
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [Bookings(), Users(), Vehicles(), Config()],
        ),
      ),
    );
  }
}

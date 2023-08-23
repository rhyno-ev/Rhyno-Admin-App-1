import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:rhyno_admin_app/helpers/constants.dart';

class LocationMarker extends StatelessWidget {
  final String address;
  final Map user;
  const LocationMarker({Key? key, required this.user, required this.address})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      elevation: 5,
      icon: Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 2, color: backgroundColor),
            image: DecorationImage(
                image: NetworkImage(user['profileImage']), fit: BoxFit.cover)),
      ),
      itemBuilder: (context) => <PopupMenuEntry>[
        PopupMenuItem(
          enabled: true,
          onTap: () {},
          child: SelectableText(
            address,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}

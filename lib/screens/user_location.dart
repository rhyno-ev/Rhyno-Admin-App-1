import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:rhyno_admin_app/components/loading.dart';
import 'package:rhyno_admin_app/components/marker.dart';
import 'package:rhyno_admin_app/helpers/constants.dart';
import 'package:rhyno_admin_app/firebase/database.dart';

class UserLocation extends StatefulWidget {
  final String userId;
  const UserLocation({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserLocation> createState() => _UserLocationState();
}

class _UserLocationState extends State<UserLocation> {
  late Map<String, dynamic> user;
  late Map<String, dynamic> location;
  bool isLoading = true;
  String address = "";

  @override
  void initState() {
    getUserLocation();
    super.initState();
  }

  void getUserLocation() async {
    DatabaseMethods().getUserSnapshots(widget.userId).listen((event) {
      if (mounted) {
        setState(() {
          user = event.data()!;
          location = event.data()!['location'];
          isLoading = false;
        });
        getAddress();
      }
    });
  }

  getAddress() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        location['latitude'].toDouble(), location['longitude'].toDouble());

    setState(() {
      address =
          '${placemarks.first.name}, ${placemarks.first.subLocality}, ${placemarks.first.locality}, ${placemarks.first.subAdministrativeArea}, ${placemarks.first.administrativeArea}, ${placemarks.first.postalCode}';
    });
  }

  locationMap() {
    return FlutterMap(
      options: MapOptions(
        interactiveFlags: InteractiveFlag.all,
        center: LatLng(
            location['latitude'].toDouble(), location['longitude'].toDouble()),
        zoom: 15,
      ),
      children: <Widget>[
        TileLayerWidget(
            options: TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'])),
        MarkerLayerWidget(
            options: MarkerLayerOptions(
          markers: [
            Marker(
              height: 40,
              width: 40,
              point: LatLng(location['latitude'].toDouble(),
                  location['longitude'].toDouble()),
              builder: (ctx) => LocationMarker(
                user: user,
                address: address,
              ),
            ),
          ],
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Loading()
        : Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: appBarColor,
              title: Text('Location', style: TextStyle(color: c2),),
            ),
            body: locationMap(),
            floatingActionButton: MaterialButton(
              onPressed: () {
                MapsLauncher.launchCoordinates(
                    location['latitude'], location['longitude']);
              },
              color: backgroundColor,
              child: const Text(
                'Open in maps',
                style: TextStyle(color: c2),
              ),
            ));
  }
}

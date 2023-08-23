import 'package:flutter/material.dart';
import 'package:rhyno_admin_app/components/loading.dart';
import 'package:rhyno_admin_app/helpers/constants.dart';
import 'package:rhyno_admin_app/firebase/database.dart';
import 'package:rhyno_admin_app/screens/add_vehicle.dart';
import 'package:rhyno_admin_app/screens/vehicle.dart';

class Vehicles extends StatefulWidget {
  const Vehicles({Key? key}) : super(key: key);

  @override
  State<Vehicles> createState() => _VehiclesState();
}

class _VehiclesState extends State<Vehicles> {
  bool isLoading = true;
  String vehicleCode = '';

  @override
  void initState() {
    setState(() {
      isLoading = false;
    });
    super.initState();
  }

  Widget vehicleTile(name, code, model, vehicleImage, vehicleId) {
    return ListTile(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => Vehicle(vehicleId: vehicleId)));
      },
      leading: CircleAvatar(backgroundImage: NetworkImage(vehicleImage),),
      // trailing: Icon(Icons.circle, size: 10, color: available ? Colors.green : Colors.red,),
      title: Text(name, style: const TextStyle(color: c2),),
      subtitle: Text(code, style: const TextStyle(color: c1),),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Loading()
        : Scaffold(
            backgroundColor: backgroundColor,
            floatingActionButton: FloatingActionButton(
              backgroundColor: c2,
              child: const Icon(
                Icons.add,
                color: backgroundColor,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddVehicle()));
              },
            ),
            body: Column(
              children: [
                Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: c1.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10)),
            child: TextField(
              onChanged: (text){
                setState(() {
                  vehicleCode = text;
                });
              },
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  hintText: 'Search by vehicle code',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none),
            ),
          ),
                Expanded(
                  child: StreamBuilder(
                    stream: DatabaseMethods().getVehiclesList(vehicleCode),
                    builder: (context, AsyncSnapshot snapshot) {
                      return snapshot.hasData
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (context, index) {
                                final vehicle = snapshot.data.docs[index];
                                return vehicleTile(vehicle['name'], vehicle['code'], vehicle['model'], vehicle['vehicleImage'], vehicle.id);
                              },
                            )
                          : const Loading();
                    },
                  ),
                ),
              ],
            ),
          );
  }
}

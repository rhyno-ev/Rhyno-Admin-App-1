import 'package:flutter/material.dart';
import 'package:rhyno_admin_app/components/loading.dart';
import 'package:rhyno_admin_app/helpers/constants.dart';
import 'package:rhyno_admin_app/firebase/database.dart';
import 'package:rhyno_admin_app/screens/user.dart';

class Users extends StatefulWidget {
  const Users({Key? key}) : super(key: key);

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  String userVerified = 'pending';
  String phoneNumber = '';

  selectUserTypeButton(width) {
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
                userVerified = 'pending';
              });
            },
            child: Container(
              alignment: Alignment.center,
              height: width / 10,
              width: width / 3,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: userVerified == 'pending'
                      ? backgroundColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Unverified',
                style: TextStyle(
                    color: userVerified == 'pending' ? c2 : backgroundColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                userVerified = 'verified';
              });
            },
            child: Container(
              alignment: Alignment.center,
              height: width / 10,
              width: width / 3,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: userVerified == 'verified'
                      ? backgroundColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Verified',
                style: TextStyle(
                    color: userVerified == 'verified' ? c2 : backgroundColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  unverifiedUsersList() {
    return StreamBuilder(
      stream: DatabaseMethods().getUnverifiedUsers(phoneNumber),
      builder: (context, AsyncSnapshot snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Loading();
        }
        return snapshot.hasData
            ? snapshot.data.docs.length > 0
                ? ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      String userId = snapshot.data.docs[index].id;
                      Map user = snapshot.data.docs[index].data();
                      return userListTile(userId, user);
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
                          'No unverified users',
                          style: TextStyle(color: c1),
                        ),
                      ],
                    ),
                  )
            : const Loading();
      },
    );
  }

  verifiedUsersList() {
    return StreamBuilder(
      stream: DatabaseMethods().getVerifiedUsers(phoneNumber),
      builder: (context, AsyncSnapshot snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Loading();
        }
        return snapshot.hasData
            ? snapshot.data.docs.length > 0
                ? ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      String userId = snapshot.data.docs[index].id;
                      Map user = snapshot.data.docs[index].data();
                      return userListTile(userId, user);
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
                          'No unverified users',
                          style: TextStyle(color: c1),
                        ),
                      ],
                    ),
                  )
            : const Loading();
      },
    );
  }

  userListTile(userId, user) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => User(userId: userId, user: user,)));
      },
      child: Container(
        decoration: BoxDecoration(
            color: appBarColor, borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user['profileImage']),
          ),
          title: Text('${user['name']}', style: const TextStyle(color: c2, fontWeight: FontWeight.bold),),
          subtitle: Text('${user['phoneNumber']}', style: const TextStyle(color: c1),),
          trailing: user['verification'] == 'verified' ? const SizedBox() : user['verification'] == 'pending' ? const Icon(Icons.pending_actions_rounded, color: c2,) : const Icon(Icons.person_off, color: Colors.red,),
        ),
      ),
    );
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
            child: Text('User Type', style: TextStyle(color: c2, fontWeight: FontWeight.bold),),
          ),
          selectUserTypeButton(width),
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
          Expanded(
            child: userVerified == 'verified' ? verifiedUsersList() : unverifiedUsersList(),
          )
        ],
      )),
    );
  }
}

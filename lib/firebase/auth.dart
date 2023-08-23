import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return auth.currentUser;
  }

  signout() async {
    auth.signOut();
  }

}

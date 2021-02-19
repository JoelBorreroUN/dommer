import 'database.dart';
import 'package:dommer/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Create User object from FirebaseUser
  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  //Auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  //Sign email
  Future signInEmail(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  //Register email
  Future registerEmail(
      String email,
      String password,
      String name,
      String lastName,
      String phone,
      String role,
      String store,
      String token) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      if (role == 'Cliente') {
        await DatabaseService(uid: user.uid).updateDommerData(
            name, '', phone, role, store, lastName, 0, false, token);
      } else {
        await DatabaseService(uid: user.uid).updateDommerData(
            name, lastName, phone, role, store, '', 0, false, token);
      }
      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  //Create client
  Future registerClient(String name, String phone, String address, String store,
      String role) async {
    try {
      return await DatabaseService()
          .updateClientData(name, phone, address, store, role, '')
          .whenComplete(() => true);
    } catch (e) {
      return null;
    }
  }

  //Sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }
}

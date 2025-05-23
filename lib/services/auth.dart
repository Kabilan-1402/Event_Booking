import 'package:booking_event/services/database.dart';
import 'package:booking_event/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    return auth.currentUser;
  }

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        // User cancelled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      UserCredential result = await auth.signInWithCredential(credential);
      User? userDetails = result.user;

      if (userDetails != null) {
        // Save to SharedPreferences
        await SharedPreferenceHelper().saveUserEmail(userDetails.email ?? '');
        await SharedPreferenceHelper().saveUserName(userDetails.displayName ?? '');
        await SharedPreferenceHelper().saveUserImage(userDetails.photoURL ?? '');
        await SharedPreferenceHelper().saveUserId(userDetails.uid);

        // Save to Firestore
        Map<String, dynamic> userInfoMap = {
          "Name": userDetails.displayName ?? '',
          "Image": userDetails.photoURL ?? '',
          "Id": userDetails.uid,
        };

        await DatabaseMethods().addUserDetail(userInfoMap, userDetails.uid);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Registered Successfully!!!"),
          ),
        );
      }

      return userDetails;
    } catch (e) {
      await GoogleSignIn().signOut();
      print("Error signing in with Google: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Google Sign-In Failed: $e"),
        ),
      );
      return null;
    }
  }
  Future Signout()async{
    await FirebaseAuth.instance.signOut();
  }
  Future deleteuser()async{
    User? user= await FirebaseAuth.instance.currentUser;
    user?.delete();
  }
}

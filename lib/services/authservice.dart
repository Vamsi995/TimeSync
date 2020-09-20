import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/globalvars.dart';
import 'package:flutter_app/models/AuthUser.dart';
import 'package:flutter_app/models/CloudUser.dart';
import 'package:flutter_app/models/LocalUser.dart';
import 'package:flutter_app/services/databaseservice.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthUser _mapFirebaseUser(User user) {
    AuthUser curUser;
    if (user != null) {
      curUser = AuthUser(
          uid: user.uid, name: user.displayName, creationTime: user.metadata.creationTime, photoURL: user.photoURL);
      return curUser;
    }
    return null;
  }

  Stream<AuthUser> get authUser {
    return _auth.authStateChanges().map(_mapFirebaseUser);
  }

  AuthUser getCurrentUser() {
    return _mapFirebaseUser(_auth.currentUser);
  }

  Future signInAnonymous(String username, bool isFriend, [String helpName]) async {
    AuthUser curUser;
    try {
      UserCredential user = await _auth.signInAnonymously();

      if (user.additionalUserInfo.isNewUser) {
        await user.user.updateProfile(displayName: username, photoURL: null);
        await user.user.reload();
        if (!isFriend) {
          await DataBaseService().addFriend(helpName, username);
        } else {
          await DataBaseService().addFirstUser(username, user.user.uid);
        }
      }
      curUser = _mapFirebaseUser(user.user);
      return curUser;
    } catch (e) {
      return null;
    }
  }

  Future<int> googleLoginAgain([bool isFriend, String helpName]) async {
    try {
      AuthUser curUser;
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      AuthCredential authCredential =
          GoogleAuthProvider.credential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
      UserCredential authUser = await _auth.signInWithCredential(authCredential);
      if (authUser.additionalUserInfo.isNewUser) {
        return 2;
      } else {
        DataBaseService _dbs = DataBaseService();
        _dbs.initUid(authUser.user.uid);
        curUser = _mapFirebaseUser(authUser.user);
        CloudUser user = await _dbs.getUserDetails();
        if (isFriend) {
          if (user == null) {
            return 1;
          } else {
            LocalUser.setUid(authUser.user.uid);
            LocalUser.setSeen(true);
            await OneSignal.shared.setExternalUserId(authUser.user.uid);
            return 0;
          }
        } else {
          if (user == null) {
            return 1;
          } else {
            QuerySnapshot friend = await _dbs.socialCollection.where({"name": helpName}).get();
            CloudUser fuser = _dbs.mapFireBasetoCloud(await _dbs.socialCollection.doc(friend.docs[0].get("uid")).get());
            await _dbs.socialCollection.doc(authUser.user.uid).update({"fname": helpName, "fuid": fuser.uid});
            LocalUser.setUid(authUser.user.uid);
            LocalUser.setSeen(true);
            await OneSignal.shared.setExternalUserId(authUser.user.uid);
            return 0;
          }
        }
      }
    } catch (e) {
      return -1;
    }
  }

  Future googleSignIn([String username, bool isFriend, String helpName]) async {
    try {
      AuthUser curUser;
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      AuthCredential authCredential =
          GoogleAuthProvider.credential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
      UserCredential authUser = await _auth.signInWithCredential(authCredential);
      LocalUser.setUid(authUser.user.uid);
      LocalUser.setSeen(true);
      if (authUser.additionalUserInfo.isNewUser) {
        await authUser.user.updateProfile(displayName: username, photoURL: null);
        await authUser.user.reload();
        if (!isFriend) {
          await DataBaseService().addFriend(helpName, username);
        } else {
          await DataBaseService().addFirstUser(username, authUser.user.uid);
        }
        curUser = _mapFirebaseUser(authUser.user);
        return curUser;
      } else {
        await OneSignal.shared.setExternalUserId(authUser.user.uid);
      }
    } catch (e) {
      return null;
    }
  }

  Future deleteUser() async {
    await DataBaseService().deleteUserFromCollection();
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    AuthCredential authCredential =
        GoogleAuthProvider.credential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    User user = _auth.currentUser;
    UserCredential curUser = await user.reauthenticateWithCredential(authCredential);
    await OneSignal.shared.removeExternalUserId();
    await curUser.user.delete();
  }

  Future googleSignOut() async {
    await _auth.signOut();
    LocalStorage.localStorage.remove("seen");
    await _googleSignIn.signOut();
  }
}

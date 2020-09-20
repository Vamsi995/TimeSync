import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/globalvars.dart';
import 'package:flutter_app/models/AuthUser.dart';
import 'package:flutter_app/models/CloudUser.dart';
import 'package:flutter_app/models/LocalUser.dart';
import 'package:flutter_app/services/authservice.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class DataBaseService {
  String uid;

  DataBaseService() {
    this.uid = LocalUser.uid;
  }

  void initUid(String uid) {
    this.uid = uid;
  }

  final CollectionReference socialCollection = FirebaseFirestore.instance.collection("social");

  Future addUserExtID() async {
    return OneSignal.shared.setExternalUserId(uid);
  }

  bool isVaildUser(DocumentSnapshot user) {
    return user != null && user.data() != null && user.data().keys.length != 0;
  }

  CloudUser mapFireBasetoCloud(DocumentSnapshot user) {
    if (!isVaildUser(user)) return null;
    DateTime deadline = DateTime.fromMillisecondsSinceEpoch(user.get("deadline").seconds * 1000);
    List<dynamic> transactions = user.get("allTransactions").toList();
    List<TimeRequest> allTransactions = transactions.map((element) {
      return TimeRequest.fromJson(element);
    }).toList();
    return CloudUser(
        uid: user.get("uid"),
        fuid: user.get("fuid"),
        name: user.get("name"),
        fname: user.get("fname"),
        isAddict: user.get("isAddict"),
        vault: user.get("vault"),
        requestCompleted: user.get("requestCompleted"),
        transaction: TimeRequest.toRequest(user.get("transaction")),
        deadline: deadline,
        allTransactions: allTransactions,
        dailyLimit: user.get("dailyLimit"),
        photoURL: user.get("photoURL"));
  }

  Stream<DocumentSnapshot> get userDetails {
    return socialCollection.doc(uid).snapshots();
  }

  Stream<CloudUser> get friendDetails {
    if (LocalUser.fuid == null) {
      return null;
    }
    return socialCollection.doc(LocalUser.fuid).snapshots().map(mapFireBasetoCloud);
  }

  Future addFirstUser(String name, String uid) async {
    AuthUser user = AuthService().getCurrentUser();
    uid = user.uid;
    addUserExtID();
    return await socialCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'fuid': "",
      'fname': "",
      'isAddict': false,
      "requestCompleted": true,
      "vault": 0,
      "transaction": TimeRequest(reqAmount: 0, reqDate: DateTime.now(), reason: "", accAmount: 0).toMap(),
      "deadline": DateTime.now(),
      "allTransactions": [],
      "trophies": 0,
      "dailyLimit": 0,
      "photoURL": user.photoURL
    });
  }

  Future addFriend(String fname, String name) async {
    QuerySnapshot users = await socialCollection.get();
    AuthUser user = AuthService().getCurrentUser();
    uid = user.uid;
    addUserExtID();
    QueryDocumentSnapshot friend = users.docs.singleWhere((element) => element.get("name") == fname);
    await socialCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'fuid': friend.id,
      'fname': fname,
      'isAddict': true,
      "requestCompleted": true,
      "vault": 0,
      "transaction": TimeRequest(reqAmount: 0, reqDate: DateTime.now(), reason: "", accAmount: 0).toMap(),
      "deadline": DateTime.now(),
      "allTransactions": [],
      "trophies": 0,
      "dailyLimit": 0,
      "photoURL": user.photoURL
    });
    return socialCollection.doc(friend.id).update({'fuid': uid, 'fname': name});
  }

  Future deleteUserFromCollection() async {
    QuerySnapshot users = await socialCollection.get();
    QueryDocumentSnapshot user = users.docs.singleWhere((element) => element.get("uid") == uid);
    try {
      await socialCollection.doc(user.get("fuid")).update({'fuid': "", 'fname': ""});
      LocalStorage.localStorage.clear();
    } catch (e) {}
    return socialCollection.doc(uid).delete();
  }

  Future<CloudUser> getUserDetails() async {
    if (uid == null) return null;
    return mapFireBasetoCloud(await socialCollection.doc(uid).get());
  }

  Future<CloudUser> getFriendDetails() async {
    DocumentSnapshot user = await socialCollection.doc(uid).get();
    if (!isVaildUser(user)) return null;
    if (user.get("fuid") == "") return null;
    return mapFireBasetoCloud(await socialCollection.doc(user.get("fuid")).get());
  }

  Future initUserVault(int value) async {
    await socialCollection.doc(uid).update({"vault": value});
  }

  Future<void> addTransaction(TimeRequest timeRequest) async {
    DocumentSnapshot user = await socialCollection.doc(uid).get();
    DocumentSnapshot friend = await socialCollection.doc(LocalUser.fuid).get();
    Map<String, dynamic> transaction = timeRequest.toMap();
    List<dynamic> clTransaction = user.get("allTransactions");
    clTransaction.add(transaction);
    await socialCollection.doc(uid).update({"allTransactions": clTransaction});
    await socialCollection.doc(LocalUser.fuid).update({"allTransactions": clTransaction});
  }

  Future writeRequest(TimeRequest transaction) async {
    DocumentSnapshot user = await socialCollection.doc(uid).get();
    await socialCollection.doc(uid).update({"transaction": transaction.toMap(), "requestCompleted": false});
    await socialCollection
        .doc(user.get("fuid"))
        .update({"transaction": transaction.toMap(), "requestCompleted": false});
  }

  Future updateRequest(int value) async {
    DocumentSnapshot user = await socialCollection.doc(uid).get();
    TimeRequest t = TimeRequest.toRequest(user.get("transaction"));
    t.accAmount = value;
    await socialCollection.doc(uid).update({"transaction": t.toMap()});
    await socialCollection.doc(user.get("fuid")).update({"transaction": t.toMap()});
  }

  Future completeRequest() async {
    DocumentSnapshot user = await socialCollection.doc(uid).get();
    await socialCollection.doc(uid).update({"requestCompleted": true});
    await socialCollection.doc(user.get("fuid")).update({"requestCompleted": true});
  }

  Future<TimeRequest> getRequestDetails() async {
    DocumentSnapshot user = await socialCollection.doc(uid).get();
    return TimeRequest.toRequest(user.get("transaction"));
  }

  Future updateAddictVault(int value) async {
    DocumentSnapshot addict;
    addict = await socialCollection.doc(uid).get();
    if (!addict.get("isAddict")) {
      addict = await socialCollection.doc(addict.get("fuid")).get();
    }
    await socialCollection.doc(addict.get("uid")).update({"vault": value});
  }

  Future updateFriendVault(int value) async {
    DocumentSnapshot friend;
    friend = await socialCollection.doc(uid).get();
    if (friend.get("isAddict")) {
      friend = await socialCollection.doc(friend.get("fuid")).get();
    }
    await socialCollection.doc(friend.get("uid")).update({"vault": value});
  }

  Future updateVault(int value, bool isAddict) {
    return isAddict ? updateAddictVault(value) : updateFriendVault(value);
  }

  Future updateField(Map<String, dynamic> data) {
    return socialCollection.doc(uid).update(data);
  }

  Future<List<TimeRequest>> getTransactions() async {
    DocumentSnapshot user = await socialCollection.doc(uid).get();
    List<dynamic> ls = user.get("allTransactions");
    ls.map(TimeRequest.toRequest);
    return ls;
  }
}

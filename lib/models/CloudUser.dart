import 'package:flutter_app/services/databaseservice.dart';

class TimeRequest {
  DateTime reqDate;
  String reason;
  int reqAmount;
  int accAmount;

  TimeRequest({this.reqAmount, this.reason, this.reqDate, this.accAmount});

  @override
  String toString() {
    return "Amount: $reqAmount\nRemarks: $reason\nDate: $reqDate\nAccepted amount: $accAmount";
  }

  factory TimeRequest.fromJson(dynamic json) {
    DateTime reqDate = DateTime.fromMillisecondsSinceEpoch(json['reqDate'].seconds * 1000);
    return TimeRequest(
        reqDate: reqDate, reason: json['reason'], reqAmount: json['reqAmount'], accAmount: json['accAmount']);
  }

  Map<String, dynamic> toMap() {
    return {'reqDate': this.reqDate, 'reason': this.reason, 'reqAmount': this.reqAmount, 'accAmount': this.accAmount};
  }

  static TimeRequest toRequest(dynamic obj) {
    DateTime reqDate = DateTime.fromMillisecondsSinceEpoch(obj['reqDate'].seconds * 1000);
    return TimeRequest(
        reqAmount: obj['reqAmount'], reqDate: reqDate, reason: obj['reason'], accAmount: obj['accAmount']);
  }
}

class CloudUser {
  String uid;
  String fuid;
  String name;
  String fname;
  int vault;
  bool isAddict;
  bool requestCompleted;
  TimeRequest transaction;
  DateTime deadline;
  int trophies;
  List<TimeRequest> allTransactions;
  int dailyLimit;

  final DataBaseService _dbs = DataBaseService();

  CloudUser(
      {this.uid,
      this.name,
      this.fname,
      this.fuid,
      this.isAddict,
      this.transaction,
      this.requestCompleted,
      this.vault,
      this.deadline,
      this.allTransactions,
      this.trophies,
      this.dailyLimit});

  Map<String, dynamic> initCloudUser() {
    return {
      'uid': "",
      'fuid': "",
      'name': "",
      'fname': "",
      "vault": 0,
      "isAddict": false,
      "requestCompleted": true,
      "transaction": TimeRequest(reason: "", reqAmount: 0, reqDate: DateTime.now(), accAmount: 0),
      "deadline": DateTime.now(),
      "allTransactions": [],
      "trophies": 0,
      "dailyLimit": 0
    };
  }

  static Future<void> addToTransaction(TimeRequest timeRequest) {
    DataBaseService _dbs = DataBaseService();
    return _dbs.addTransaction(timeRequest);
  }

  static Future<void> setTrophies(int trophies) {
    DataBaseService _dbs = DataBaseService();
    return _dbs.updateField({"trophies": trophies});
  }

  static Future<void> setDeadline(DateTime deadline) {
    DataBaseService _dbs = DataBaseService();
    return _dbs.updateField({"deadline": deadline});
  }

  static Future<void> setTransaction(TimeRequest timeRequest) {
    DataBaseService _dbs = DataBaseService();
    return _dbs.updateField({"timeRequest": timeRequest});
  }

  static Future<void> completeRequest() {
    DataBaseService _dbs = DataBaseService();
    return _dbs.completeRequest();
  }

  static Future<void> setAddict(bool isAddict) {
    DataBaseService _dbs = DataBaseService();
    return _dbs.updateField({"isAddict": isAddict});
  }

  static Future<void> setVault(int vault) {
    DataBaseService _dbs = DataBaseService();
    return _dbs.updateField({"vault": vault});
  }

  static Future<void> setDailyLimit(int limit) {
    DataBaseService _dbs = DataBaseService();
    return _dbs.updateField({"dailyLimit": limit});
  }
}

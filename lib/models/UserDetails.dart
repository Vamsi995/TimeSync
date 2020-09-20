import 'dart:math';

import 'package:app_usage/app_usage.dart';
import 'package:flutter_app/globalvars.dart';
import 'package:flutter_app/services/databaseservice.dart';

import '../widgets/home_page.dart';
import 'CloudUser.dart';
import 'LocalUser.dart';

const VaultDeprecation = 0.9;
const InterestRate = 0.1;

class UserDetails {
  String uid;
  String name;
  String fuid;
  String OSpid;

  bool isAddict;

  UserDetails({this.uid, this.name, this.fuid, this.isAddict});
}

class Vault {
  static void dailySaving() async {
    DataBaseService _dbs = DataBaseService();
    CloudUser user = await _dbs.getUserDetails();
    int temp = user.vault;
    int usage = await getDailyUsage();
    temp += user.dailyLimit - usage;
    CloudUser.setVault(temp);
  }

  static void goalEnd() async {
    DataBaseService _dbs = DataBaseService();
    CloudUser user = await _dbs.getUserDetails();
    int temp = (user.vault * VaultDeprecation).round();
    UtilFunctions.printf(temp);
    CloudUser.setVault(user.vault - temp);
    CloudUser.setTrophies(user.trophies + temp);
  }

  static void borrow(TimeRequest t) async {
    DataBaseService _dbs = DataBaseService();
    CloudUser user = await _dbs.getUserDetails();
    CloudUser friend = await _dbs.getFriendDetails();
    int vault = user.vault;
    int fvault = friend.vault;
    vault = vault - t.accAmount;
    fvault = fvault - (t.accAmount + t.accAmount * InterestRate).round();
    await CloudUser.addToTransaction(t);
    await _dbs.updateAddictVault(fvault);
    await _dbs.updateFriendVault(vault);
  }

  static void decayCompute(double prevAvg, int dur) async {
    int limit = (await DataBaseService().getUserDetails()).dailyLimit;
    double decay = (1 / dur) * log(prevAvg / limit);
    LocalUser.setTimeDecay(decay);
  }

  static void timeDecay() async {
    int limit = (await DataBaseService().getUserDetails()).dailyLimit;
    double decay = LocalUser.timeDecay;
    int temp = (limit * exp(-decay)).round();
    CloudUser.setDailyLimit(temp);
  }
}

Future<int> getDailyUsage() async {
  DateTime date = DateTime.now();

  DateTime startDate = date.subtract(new Duration(days: 1));
  DateTime _today = startDate.add(new Duration(days: 1));

  List<AppUsageInfo> today = await AppUsage.getAppUsage(startDate, _today);

  double avg = total(today) / today.length;
  return avg.toInt();
}

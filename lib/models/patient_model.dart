import 'model_list.dart';

class PatientModel {
  UserModel? user;
  String? bloodGroup;
  int? totalBookedAppt;
  String? lastCompletedAppt;

  PatientModel({this.user, this.bloodGroup, this.totalBookedAppt, this.lastCompletedAppt});

  Map<String, dynamic> toJson() {
    return {
      'user': user != null ? user!.toJson() : null,
      'blood_group': bloodGroup,
      'total_booked_appt': totalBookedAppt,
      'last_completed_appt': lastCompletedAppt,
    };
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      bloodGroup: json['blood_group'],
      totalBookedAppt: json['total_booked_appt'],
      lastCompletedAppt: json['last_completed_appt'],
    );
  }
}

import 'package:intl/intl.dart';

import 'dummy_data.dart';
import 'model_list.dart';

class ApptModel {
  int? id;
  UserModel? userPatient;
  PatientModel? patient;
  ClinicModel? clinic;
  DaySchedulePatternModel? dayPattern;
  String? startApptTime;
  String? endApptTime;
  String? status;
  String? remark;
  String? review;
  double? feedback;
  // Map<String, dynamic>? status;
  bool? feedBackStatus;
  bool active;
  String? apptDate;
  String? bookedAt;
  List<ApptConditionTreatModel>? conditionTreated;

  ApptModel({
    this.id,
    this.userPatient,
    this.patient,
    this.clinic,
    this.dayPattern,
    this.startApptTime,
    this.endApptTime,
    this.status,
    this.remark,
    this.review,
    this.feedback,
    this.feedBackStatus,
    this.active = true,
    this.apptDate,
    this.bookedAt,
    this.conditionTreated,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_patient': userPatient != null ? userPatient!.toJson() : null,
      'patient': patient != null ? patient!.toJson() : null,
      'clinic': clinic != null ? clinic!.toJson() : null,
      'day_pattern': dayPattern != null ? dayPattern!.toJson() : null,
      'start_appt_time': startApptTime,
      'end_appt_time': endApptTime,
      'status': status,
      'remark': remark,
      'review': review,
      'feedback': feedback,
      'feedback_status': feedBackStatus,
      'active': active,
      'appt_date': apptDate,
      'booked_at': bookedAt,
      'condition_treated': conditionTreated != null
          ? conditionTreated!.map((conditionObject) {
              return conditionObject.toJson();
            }).toList()
          : null,
    };
  }

  factory ApptModel.fromJson(Map<String, dynamic> json) {
    print('value fo review =====');
    print(json['review']);
    return ApptModel(
      id: json['id'],
      userPatient: json['user_patient'] != null ? UserModel.fromJson(json['user_patient']) : null,
      patient: json['patient'] != null ? PatientModel.fromJson(json['patient']) : null,
      clinic: json['clinic'] != null ? ClinicModel.fromJson(json['clinic']) : null,
      dayPattern: json['day_pattern'] != null
          ? DaySchedulePatternModel.fromJson(json['day_pattern'])
          : null,
      startApptTime: json['start_appt_time'],
      remark: json['remark'],
      review: json['review'],
      feedback: json['feedback'] != null ? json['feedback'] : 3.5,
      endApptTime: json['end_appt_time'],
      status: GlobalDummyData.CAPITUALIZE[json['status']],
      feedBackStatus: json['feedback_status'],
      active: json['active'],
      apptDate: json['appt_date'],
      bookedAt: json['booked_at'],
      conditionTreated: json['condition_treated'] != null
          ? json['condition_treated'].forEach((val) {
              return ApptConditionTreatModel.fromJson(val);
            })
          : null,
    );
  }
}

// Appt Condition Model
class ApptConditionTreatModel {
  int? id;
  String? name;
  String? farsiName;
  String? pashtoName;

  ApptConditionTreatModel({this.id, this.name, this.farsiName, this.pashtoName});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'farsi_name': farsiName,
      'pashto_name': pashtoName,
    };
  }

  factory ApptConditionTreatModel.fromJson(Map<String, dynamic> json) {
    return ApptConditionTreatModel(
      id: json['id'],
      name: json['name'],
      farsiName: json['farsi_name'],
      pashtoName: json['pashto_name'],
    );
  }
}

// Day Schedule Pattern
class DaySchedulePatternModel {
  int? id;
  WeekDayModel? weekDay;
  String? startDayTime;
  String? endDayTime;
  ClinicModel? clinic;
  bool active;

  DaySchedulePatternModel(
      {this.id, this.weekDay, this.startDayTime, this.endDayTime, this.clinic, this.active = true});

  Map<String, dynamic> toJson() {
    return {
      'week_day': WeekDayModel().toJson(),
      'start_day_time': startDayTime,
      'end_day_time': endDayTime,
      'clinic': clinic != null ? clinic!.toJson() : null,
      'active': active,
    };
  }

  factory DaySchedulePatternModel.fromJson(Map<String, dynamic> json) {
    return DaySchedulePatternModel(
      id: json['id'],
      weekDay: json['week_day'] != null ? WeekDayModel.fromJson(json['week_day']) : null,
      startDayTime: json['start_day_time'],
      endDayTime: json['end_day_time'],
      clinic: json['clinic'] != null ? ClinicModel.fromJson(json['clinic']) : null,
      active: json['active'],
    );
  }
}

// Week Days Model
class WeekDayModel {
  int? id;
  String? weekDay;
  String? rtlWeekDay;

  WeekDayModel({this.id, this.weekDay, this.rtlWeekDay});

  Map<String, dynamic> toJson() {
    return {
      'week_day': weekDay,
      'rtl_week_day': rtlWeekDay,
    };
  }

  factory WeekDayModel.fromJson(Map<String, dynamic> json) {
    return WeekDayModel(
      id: json['id'],
      weekDay: json['week_day'],
      rtlWeekDay: json['rtl_week_day'],
    );
  }
}

class BookedApptModel {
  int? id;
  int? patientId;
  int? clinicId;
  String? patientName;
  String? rtlPatientName;
  String? phone;
  String? age;
  String? avatar;
  String? gender;
  String? clinicName;
  String? rtlClinicName;
  String? city;
  String? district;
  String? rtlCity;
  String? rtlDistrict;
  String? weekDay;
  String? rtlWeekDay;
  String? startApptTime;
  String? endApptTime;
  String? apptDate;
  String? bookedAt;

  BookedApptModel({
    this.id,
    this.patientId,
    this.clinicId,
    this.patientName,
    this.rtlPatientName,
    this.phone,
    this.age,
    this.avatar,
    this.gender,
    this.clinicName,
    this.rtlClinicName,
    this.city,
    this.district,
    this.rtlCity,
    this.rtlDistrict,
    this.weekDay,
    this.rtlWeekDay,
    this.startApptTime,
    this.endApptTime,
    this.apptDate,
    this.bookedAt,
  });

  factory BookedApptModel.fromJson(Map<String, dynamic> json) {
    return BookedApptModel(
      id: json['appt_id'],
      patientId: json['patient_id'],
      clinicId: json['clinic_id'],
      patientName: json['patient_name'],
      rtlPatientName: json['rtl_patient_name'],
      phone: json['patient_phone'],
      age: json['patient_age'],
      avatar: json['avatar'],
      gender: json['gender'] == null ? 'Male' : json['gender'],
      clinicName: json['clinic_name'],
      rtlClinicName: json['rtl_clinic_name'],
      city: json['city'],
      district: json['district'],
      rtlCity: json['rtl_city'],
      rtlDistrict: json['rtl_district'],
      weekDay: json['week_day'],
      rtlWeekDay: json['rtl_week_day'],
      startApptTime: json['start_appt_time'],
      endApptTime: json['end_appt_time'],
      apptDate: json['appt_date'] != null
          ? DateFormat.yMMMMd().format(DateTime.parse(json['appt_date'])).toString()
          : '',
      bookedAt: json['booked_at'] != null
          ? DateFormat.yMMMMd().format(DateTime.parse(json['booked_at'])).toString()
          : '',
    );
  }
}

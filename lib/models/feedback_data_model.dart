import 'dart:core';

class FeedbackDataModel {
  int? feedbackNo;
  double? averageStar;
  double? overallExperience;
  double? doctorCheckup;
  double? staffBehavior;
  double? clinicEnvironment;
  int? patientNo;
  int? completedApptNo;
  int? experienceYear;

  FeedbackDataModel({
    this.feedbackNo,
    this.averageStar,
    this.overallExperience,
    this.doctorCheckup,
    this.staffBehavior,
    this.clinicEnvironment,
    this.patientNo,
    this.completedApptNo,
    this.experienceYear,
  });

  factory FeedbackDataModel.fromJson(Map<String, dynamic> json) {
    return FeedbackDataModel(
      feedbackNo: json['feedback_no'],
      averageStar: double.tryParse(json['average_star']),
      overallExperience: double.tryParse(json['overall_experience']),
      doctorCheckup: double.tryParse(json['doctor_checkup']),
      staffBehavior: double.tryParse(json['staff_behavior']),
      clinicEnvironment: double.tryParse(json['clinic_environment']),
      patientNo: json['patient_no'],
      completedApptNo: json['completed_appt_no'],
      experienceYear: json['experience_year'],
      // how to convert a dynamic list to integer list
      // how to know the type of a variable in flutter
    );
  }
}

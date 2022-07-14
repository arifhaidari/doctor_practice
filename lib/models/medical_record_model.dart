import 'package:doctor_panel/models/model_list.dart';
import 'package:intl/intl.dart';

class MedicalRecordModel {
  int? id;
  PatientModel? patientModel;
  int? doctorId;
  String? title;
  List<MedicalRecordFileModel>? fileModel;
  bool? doctorAccess;
  bool? generalAccess;
  String? timeStamp;

  MedicalRecordModel(
      {this.id,
      this.patientModel,
      this.doctorId,
      this.title,
      this.fileModel,
      this.doctorAccess,
      this.generalAccess,
      this.timeStamp});

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    MedicalRecordModel medicalRecordModelObject = MedicalRecordModel(
      id: json['id'],
      patientModel: json['patient'] != null ? PatientModel.fromJson(json['patient']) : null,
      doctorId: json['doctor'],
      title: json['title'],

      // fileModel: json['file'] != null ? MedicalRecordFileModel.fromJson(json['file']) : null,
      doctorAccess: json['doctor_access'],
      generalAccess: json['general_access'],
      timeStamp: json['timestamp'] != null
          ? DateFormat("yyyy-MM-dd").format(DateTime.parse(json['timestamp'])).toString()
          : '',
    );

    if (json['file'] != null) {
      List<MedicalRecordFileModel> theList = <MedicalRecordFileModel>[];
      json['file'].forEach((element) {
        theList.add(MedicalRecordFileModel.fromJson(element));
      });
      medicalRecordModelObject.fileModel = theList;
    }

    return medicalRecordModelObject;
  }
}

class MedicalRecordFileModel {
  int? id;
  MedicalRecordModel? medicalRecordModel;
  String? file;

  MedicalRecordFileModel({this.id, this.medicalRecordModel, this.file});

  factory MedicalRecordFileModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordFileModel(
      id: json['id'],
      medicalRecordModel: json['medical_record'],
      file: json['file'],
    );
  }
}

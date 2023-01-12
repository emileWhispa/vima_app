import 'company.dart';

class Job {
  int id;
  String name;
  String employmentType;
  String location;
  String locationId;
  num minSalary;
  num maxSalary;
  String? benefits;
  String? minExperience;
  String? minEducation;
  String? careerLevel;
  String? neighbourhood;
  String gender;
  String language;
  String? description;
  bool remote;
  Company company;
  DateTime expireDate;

  Job.fromJson(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'] ?? "",
        gender = map['gender'],
        minSalary = map['minSalary'],
        maxSalary = map['maxSalary'],
  expireDate = DateTime.fromMicrosecondsSinceEpoch(map['expireDate']),
        benefits = map['benefits'],
        company = Company.fromJson(map['company']),
        minExperience = map['minExperience'],
        minEducation = map['minEducation'],
        careerLevel = map['careerLevel'],
        remote = map['remote'],
        neighbourhood = map['neighbourhood'],
        language = map['language'],
        description = map['description'],
        location = map['location'],
        locationId = map['locationId'],
        employmentType = map['employmentType'];
}

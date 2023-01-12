import 'dart:io';

import 'package:date_field/date_field.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vima_app/super_base.dart';

import 'authentication.dart';
import 'json/job.dart';
import 'json/user.dart';

class JobApplication extends StatefulWidget{
  final Job job;
  const JobApplication({super.key, required this.job});

  @override
  State<JobApplication> createState() => _JobApplicationState();
}

class _JobApplicationState extends Superbase<JobApplication> {

  DateTime? _birthDate;
  String? _commitmentLevel;
  final _nationalityController = TextEditingController();
  final _locationController = TextEditingController();
  final _positionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _experienceController = TextEditingController();
  String? _education;
  String? _careerLevel;
  String? _gender;
  String? _noticePeriod;
  String? _visaStatus;
  final _cvSummaryController = TextEditingController();
  File? _attachment;


  void pickFile()async{
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _attachment = File(result.files.single.path??"");
      });
    } else {
      // User canceled the picker
    }
  }

  final _key = GlobalKey<FormState>();
  bool _saving = false;

  void apply()async{
    if(_key.currentState?.validate()??false){

      if(await _attachment?.exists() != true){
        showSnack("File not found !");
        return;
      }

      if(User.user == null){
        await push(Authentication(fromAdd: true,loginSuccessCallback: goBack,));

        if(User.user == null){
          showSnack("Login first");
          return;
        }

      }

      setState(() {
        _saving = true;
      });
      await ajax(url:"user/create/application",method: "POST",data: FormData.fromMap({
        'attachment': await MultipartFile.fromFile(_attachment!.path),
        "visaStatus":_visaStatus,
        "cvSummary":_cvSummaryController.text,
        "noticePeriod":_noticePeriod,
        "gender":_gender,
        "careerLevel":_careerLevel,
        "minEducation":_education,
        "minExperience":_experienceController.text,
        "salaryExpectation":_salaryController.text,
        "position":_positionController.text,
        "location":_locationController.text,
        "nationality":_nationalityController.text,
        "commitmentLevel":_commitmentLevel,
        "birthDate":_birthDate?.toString()
      }),onValue: (s,v){
        goBack();
        showSnack(s['message']??"");
      },error: (s,v){
        if(s is Map){
          showSnack(s['message']??"");
        }
      });
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Apply : ${widget.job.name}"),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 15)
          )
      ),
        child: Form(
          key: _key,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DateTimeFormField(
                    validator: (s)=>s == null ? "Birth date is required !!" : null,
                    initialValue: _birthDate,
                    mode: DateTimeFieldPickerMode.date,
                    onDateSelected: (date){
                      setState(() {
                        _birthDate = date;
                      });
                    },
                    decoration: const InputDecoration(labelText: "Birth date"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DropdownButtonFormField<String>(
                    items: [
                      "Full Time",
                      "Part Time",
                      "Seasonal Employees",
                      "Temporary Employees",
                    ].map((e) => DropdownMenuItem(value: e,child: Text(e),)).toList(),
                    validator: (s)=>s == null ? "Commitment level is required !!" : null,
                    value: _commitmentLevel,
                    onChanged: (commit){
                      setState(() {
                        _commitmentLevel = commit;
                      });
                    },
                    decoration: const InputDecoration(labelText: "Commitment Level"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    validator: (s)=>s?.trim().isEmpty == true ? "Nationality is required !!" : null,
                    controller: _nationalityController,
                    decoration: const InputDecoration(labelText: "Nationality"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    validator: (s)=>s?.trim().isEmpty == true ? "Current location is required !!" : null,
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: "Current Location"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    validator: (s)=>s?.trim().isEmpty == true ? "Position is required !!" : null,
                    controller: _positionController,
                    decoration: const InputDecoration(labelText: "Applied Position"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    validator: (s)=>s?.trim().isEmpty == true ? "Salary Expectations is required !!" : null,
                    controller: _salaryController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: "Salary Expectations"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    validator: (s)=>s?.trim().isEmpty == true ? "Experience is required !!" : null,
                    controller: _experienceController,
                    decoration: const InputDecoration(labelText: "Experience (Years)"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DropdownButtonFormField(
                    items: [
                      "PhD",
                      "Masters Degree",
                      "Bachelor's degree",
                      "A1",
                      "A2",
                      "Primary School",
                      "Not Applicable",
                    ].map((e) => DropdownMenuItem(value: e,child: Text(e))).toList(),
                    validator: (s)=>s == null ? "Experience is required !!" : null,
                    value: _education,
                    onChanged: (ed){
                      setState(() {
                        _education = ed;
                      });
                    },
                    decoration: const InputDecoration(labelText: "Education"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DropdownButtonFormField(
                    items: [
                      "Senior",
                      "Mid-Level",
                      "Junior",
                      "Any",
                      "A2",
                    ].map((e) => DropdownMenuItem(value: e,child: Text(e))).toList(),
                    validator: (s)=>s == null ? "Career Level is required !!" : null,
                    value: _careerLevel,
                    onChanged: (ed){
                      setState(() {
                        _careerLevel = ed;
                      });
                    },
                    decoration: const InputDecoration(labelText: "Career Level"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DropdownButtonFormField(
                    items: [
                      "MALE",
                      "FEMALE",
                    ].map((e) => DropdownMenuItem(value: e,child: Text(e))).toList(),
                    validator: (s)=>s == null ? "Gender is required !!" : null,
                    value: _gender,
                    onChanged: (ed){
                      setState(() {
                        _gender = ed;
                      });
                    },
                    decoration: const InputDecoration(labelText: "Gender"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DropdownButtonFormField(
                    items: [
                      "None",
                      "1 Week",
                      "2 Week",
                      "3 Week",
                      "1 Month",
                      "2 Months",
                      "More than 2 Months",
                    ].map((e) => DropdownMenuItem(value: e,child: Text(e))).toList(),
                    validator: (s)=>s == null ? "Notice period is required !!" : null,
                    value: _noticePeriod,
                    onChanged: (ed){
                      setState(() {
                        _noticePeriod = ed;
                      });
                    },
                    decoration: const InputDecoration(labelText: "Notice period"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DropdownButtonFormField(
                    items: [
                      "Not Applicable",
                      "Business",
                      "Employment",
                      "Residence",
                      "Spouse",
                      "Student",
                      "Tourist",
                      "Visit",
                    ].map((e) => DropdownMenuItem(value: e,child: Text(e))).toList(),
                    validator: (s)=>s == null ? "Visa status is required !!" : null,
                    value: _visaStatus,
                    onChanged: (ed){
                      setState(() {
                        _visaStatus = ed;
                      });
                    },
                    decoration: const InputDecoration(labelText: "Visa status"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    validator: (s)=>s?.trim().isEmpty == true ? "C.V Summary is required !!" : null,
                    controller: _cvSummaryController,
                    minLines: 4,
                    maxLines: 5,
                    decoration: const InputDecoration(labelText: "C.V Summary"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FormField<File>(
                    builder: (field){
                      var btn = OutlinedButton.icon(onPressed: pickFile,style: OutlinedButton.styleFrom(
                        side: field.hasError ? BorderSide(
                            color: Theme.of(context).colorScheme.error
                        ) : null,
                        foregroundColor: field.hasError ?  Theme.of(context).colorScheme.error
                         : null,
                        padding: const EdgeInsets.all(10)
                      ), label: const Text("Upload Attachment"),icon: const Icon(Icons.cloud_upload_outlined),);

                      return field.hasError ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          btn,
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(field.errorText!,style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 11.5
                            ),),
                          )
                        ],
                      ) : btn;
                    },
                    initialValue: _attachment,
                    validator: (s)=> _attachment == null ? "C.V Attachment is required !!" : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _saving ? const Center(
                    child: CircularProgressIndicator(),
                  ) : ElevatedButton(onPressed: apply,style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15)
                  ), child: const Text("Apply Now")),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
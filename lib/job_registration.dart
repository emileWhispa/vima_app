import 'package:date_field/date_field.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:place_picker/place_picker.dart';
import 'package:vima_app/super_base.dart';

import 'json/category.dart';
import 'json/sub_category.dart';

class JobRegistration extends StatefulWidget{
  const JobRegistration({super.key});

  @override
  State<JobRegistration> createState() => _JobRegistrationState();
}

class _JobRegistrationState extends Superbase<JobRegistration> {

  final _companyNameController = TextEditingController();
  final _companyTypeController = TextEditingController();
  final _companySizeController = TextEditingController();
  final _companyBioController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();

  final _titleController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  final _benefitsController = TextEditingController();
  final _minExperienceController = TextEditingController();
  final _maxExperienceController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool? _remote;
  String? _employmentType;
  String? _minEducation;
  String? _careerLevel;
  String? _gender;
  final List<String> _languages = [];
  DateTime? _expireDate;

  Category? _category;
  SubCategory? _subCategory;
  List<Category> _list = [];
  bool _saving = false;
  final _key = GlobalKey<FormState>();
  LocationResult? _locationResult;


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadCategories();
      loadMyCompany();
    });
    super.initState();
  }


  void loadMyCompany(){
    ajax(url: "user/my/company",server: false,onValue: (obj,url){
      _companyNameController.text = obj['data']['companyName'];
      _companyBioController.text = obj['data']['companyBio'];
      _companyTypeController.text = obj['data']['companyType'];
      _companySizeController.text = obj['data']['companySize'];
      _contactPhoneController.text = obj['data']['phone'];
      _contactEmailController.text = obj['data']['email'];
    });
  }


  void loadCategories() {
    ajax(
        url: "public/categories/all",
        server: false,
        onValue: (source, url) {
          setState(() {
            _category = null;
            _subCategory = null;
            _list = (source['data'] as Iterable)
                .map((e) => Category.fromJson(e))
            .where((element) => element.job)
                .toList();
          });
        });
  }


  void create()async{

    if(_key.currentState?.validate()??false) {


      setState(() {
        _saving = true;
      });

      await ajax(url: "user/create/job",
          method: "POST",
          data: FormData.fromMap({
            "expireDate":_expireDate?.toString(),
            "category.id":_subCategory?.id,
            "name":_titleController.text,
            "company.phone":_contactPhoneController.text,
            "company.email":_contactEmailController.text,
            "company.companySize":_companySizeController.text,
            "company.companyBio":_companyBioController.text,
            "company.companyType":_companyTypeController.text,
            "company.companyName":_companyNameController.text,
            "language":_languages.join(","),
            "gender":_gender,
            "careerLevel":_careerLevel,
            "minEducation":_minEducation,
            "employmentType":_employmentType,
            "remote":_remote == true ? 1 : 0,
            "minSalary":_salaryMinController.text,
            "maxSalary":_salaryMaxController.text,
            "minExperience":"${_minExperienceController.text}-${_maxExperienceController.text}",
            "benefits":_benefitsController.text,
            "description":_descriptionController.text,
            "location":_locationResult?.name,
            "locationId":_locationResult?.placeId,
          }),onValue: (s,v){
            goBack();
            showSnack(s['message']??"");
          },error: (s,v){
            if(s is Map){
              showSnack(s['message']??"");
            }else{
              showSnack("$s");
            }
          });
      setState(() {
        _saving = false;
      });
    }
  }

  void showPlacePicker() async {
    _locationResult = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PlacePicker(mapKey)));

    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Job"),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
            inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 15))),
        child: Form(
          key: _key,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    validator: (s)=>s?.trim().isEmpty == true ? "Job name/title is required !!" : null,
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Job name/title"),
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
                    validator: (s)=>s == null ? "Employment Type is required !!" : null,
                    value: _employmentType,
                    onChanged: (commit){
                      setState(() {
                        _employmentType = commit;
                      });
                    },
                    decoration: const InputDecoration(labelText: "Commitment Level"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DropdownButtonFormField<bool>(
                    items: [
                      true,
                      false
                    ].map((e) => DropdownMenuItem(value: e,child: Text(e ? "Yes" : "No"),)).toList(),
                    validator: (s)=>s == null ? " Remote job is required !!" : null,
                    value: _remote,
                    onChanged: (commit){
                      setState(() {
                        _remote = commit;
                      });
                    },
                    decoration: const InputDecoration(labelText: "Remote Job"),
                  ),
                ),
                Row(
                  children: [
                    Expanded(child:
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        // validator: (s)=>s?.trim().isEmpty == true ? "Salary(Min) is required !!" : null,
                        controller: _salaryMinController,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Salary(Min)"),
                      ),
                    ),),
                    const SizedBox(width: 10,),
                    Expanded(child:
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        // validator: (s)=>s?.trim().isEmpty == true ? "Salary(Max) is required !!" : null,
                        controller: _salaryMaxController,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Salary(Max)"),
                      ),
                    ),),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child:
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        validator: (s)=>s?.trim().isEmpty == true ? "Salary(Min) is required !!" : null,
                        controller: _minExperienceController,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Experience From"),
                      ),
                    ),),
                    const SizedBox(width: 10,),
                    Expanded(child:
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        validator: (s)=>s?.trim().isEmpty == true ? "To is required !!" : null,
                        controller: _maxExperienceController,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "To"),
                      ),
                    ),),
                  ],
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
                      "ANY",
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
                  child: DropdownButtonFormField<Category>(
                    value: _category,
                    validator: (s)=>s == null ? "Category is required !!!" : null,
                    onChanged: (v) {
                      setState(() {
                        _subCategory = null;
                        _category = v;
                      });
                    },
                    items: _list
                        .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                        .toList(),
                    decoration: const InputDecoration(labelText: "Category"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DropdownButtonFormField<SubCategory>(
                    value: _subCategory,
                    validator: (s)=>s == null ? "Sub Category is required !!!" : null,
                    onChanged: (v) {
                      setState(() {
                        _subCategory = v;
                      });
                    },
                    items: _category?.subs
                        .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                        .toList(),
                    decoration: const InputDecoration(labelText: "Sub Category"),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    maxLines: 5,
                    minLines: 4,
                    controller: _descriptionController,
                    decoration:
                    const InputDecoration(labelText: "Job Description"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DateTimeFormField(
                    validator: (s)=>s == null ? "Expire date is required !!" : null,
                    initialValue: _expireDate,
                    mode: DateTimeFieldPickerMode.date,
                    onDateSelected: (date){
                      setState(() {
                        _expireDate = date;
                      });
                    },
                    decoration: const InputDecoration(labelText: "Expire date"),
                  ),
                ),
                const Text("Select Languages"),
                Wrap(
                  children: ["English","French","Kinyarwanda","Any"].asMap().map((key, value) => MapEntry(key, Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(value: _languages.contains(value), onChanged: (v){
                        if(_languages.contains(value)){
                          setState(() {
                            _languages.remove(value);
                          });
                        }else{
                          setState(() {
                            _languages.add(value);
                          });
                        }
                      }),
                      Text(value)
                    ],
                  ))).values.toList(),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FormField<LocationResult>(
                    builder: (field) {
                      var btn = OutlinedButton.icon(
                        onPressed: showPlacePicker,
                        style: OutlinedButton.styleFrom(
                            side: field.hasError
                                ? BorderSide(
                                color: Theme.of(context).colorScheme.error)
                                : null,
                            foregroundColor: field.hasError
                                ? Theme.of(context).colorScheme.error
                                : null,
                            padding: const EdgeInsets.all(10)),
                        label: const Text("Select job location"),
                        icon: const Icon(Icons.location_on),
                      );

                      return field.hasError
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          btn,
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              field.errorText!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 11.5),
                            ),
                          )
                        ],
                      )
                          : btn;
                    },
                    initialValue: _locationResult,
                    validator: (s) =>
                    _locationResult == null ? "Location is required !!" : null,
                  ),
                ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text("Company Information",style: Theme.of(context).textTheme.titleLarge,),
          ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    validator: (s)=>s?.trim().isEmpty == true ? "Company name is required !!" : null,
                    controller: _companyNameController,
                    decoration: const InputDecoration(labelText: "Company name"),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 10),
                //   child: TextFormField(
                //     validator: (s)=>s?.trim().isEmpty == true ? "Company type is required !!" : null,
                //     controller: _companyTypeController,
                //     decoration: const InputDecoration(labelText: "Company type"),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    validator: (s)=>s?.trim().isEmpty == true ? "Company size is required !!" : null,
                    controller: _companySizeController,
                    decoration: const InputDecoration(labelText: "Company Size (No of Employees)"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    validator: (s)=>s?.trim().isEmpty == true ? "Company bio is required !!" : null,
                    controller: _companyBioController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(labelText: "Company Bio (No of Employees)"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    validator: validateEmail,
                    controller: _contactEmailController,
                    decoration: const InputDecoration(labelText: "Contact email"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    validator: validateMobile,
                    controller: _contactPhoneController,
                    decoration: const InputDecoration(labelText: "Contact phone"),
                  ),
                ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _saving
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : ElevatedButton(
                onPressed: create,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15)),
                child: const Text("Apply Now"))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
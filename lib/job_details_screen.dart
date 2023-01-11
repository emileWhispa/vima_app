import 'package:flutter/material.dart';
import 'package:vima_app/job_application.dart';
import 'package:vima_app/map_widget.dart';
import 'package:vima_app/super_base.dart';

import 'json/job.dart';

class JobDetailsScreen extends StatefulWidget{
  final Job job;
  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends Superbase<JobDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job.name),
      ),
      body: ListView(padding: const EdgeInsets.all(20),children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Expanded(child: Text("Employment Type")),
              const SizedBox(width: 10,),
              Expanded(child: Text(widget.job.employmentType,style: const TextStyle(
                fontWeight: FontWeight.bold
              ),)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Expanded(child: Text("Remote Job")),
              const SizedBox(width: 10,),
              Expanded(child: Text(widget.job.remote ? "Yes" : "No",style: const TextStyle(
                fontWeight: FontWeight.bold
              ),)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Expanded(child: Text("Benefits")),
              const SizedBox(width: 10,),
              Expanded(child: Text(widget.job.benefits??"",style: const TextStyle(
                fontWeight: FontWeight.bold
              ),)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Expanded(child: Text("Career Level")),
              const SizedBox(width: 10,),
              Expanded(child: Text(widget.job.careerLevel??"",style: const TextStyle(
                fontWeight: FontWeight.bold
              ),)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Expanded(child: Text("Monthly Salary")),
              const SizedBox(width: 10,),
              Expanded(child: Text("${fmtNbr(widget.job.minSalary)} - ${fmtNbr(widget.job.maxSalary)}",style: const TextStyle(
                fontWeight: FontWeight.bold
              ),)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Expanded(child: Text("Minimum Work Experience")),
              const SizedBox(width: 10,),
              Expanded(child: Text(widget.job.minExperience??"",style: const TextStyle(
                fontWeight: FontWeight.bold
              ),)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Expanded(child: Text("Minimum Education Level")),
              const SizedBox(width: 10,),
              Expanded(child: Text(widget.job.minEducation??"",style: const TextStyle(
                fontWeight: FontWeight.bold
              ),)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Expanded(child: Text("Preferred Languages")),
              const SizedBox(width: 10,),
              Expanded(child: Text(widget.job.language,style: const TextStyle(
                fontWeight: FontWeight.bold
              ),)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Expanded(child: Text("Location")),
              const SizedBox(width: 10,),
              Expanded(child: Text(widget.job.location,style: const TextStyle(
                fontWeight: FontWeight.bold
              ),)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Expanded(child: Text("Gender")),
              const SizedBox(width: 10,),
              Expanded(child: Text(widget.job.gender,style: const TextStyle(
                fontWeight: FontWeight.bold
              ),)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Expanded(child: Text("Expire Date")),
              const SizedBox(width: 10,),
              Expanded(child: Text(fmtDate2(widget.job.expireDate),style: const TextStyle(
                fontWeight: FontWeight.bold
              ),)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Description"),
              const SizedBox(width: 10,),
              Text(widget.job.description??"",style: const TextStyle(
                fontWeight: FontWeight.bold
              ),),
            ],
          ),
        ),
        Padding(padding: const EdgeInsets.only(bottom: 10),child: MapWidget(locationId: widget.job.locationId),),
        ElevatedButton(onPressed: (){
          push(JobApplication(job: widget.job,),fullscreenDialog: true);
        }, child: const Text("Apply Now")),
      ],),
    );
  }
}
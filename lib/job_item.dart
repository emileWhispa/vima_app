import 'package:flutter/material.dart';
import 'package:vima_app/job_details_screen.dart';
import 'package:vima_app/super_base.dart';

import 'json/job.dart';

class JobItem extends StatefulWidget{
  final Job job;

  const JobItem({super.key, required this.job});

  @override
  State<JobItem> createState() => _JobItemState();
}

class _JobItemState extends Superbase<JobItem> {
  @override
  Widget build(BuildContext context) {
    var color = Colors.grey.shade600;
    return SizedBox(
      width: MediaQuery.of(context).size.width-50,
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: InkWell(
          onTap: (){
            push(JobDetailsScreen(job: widget.job));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.job.name,style: Theme.of(context).textTheme.titleLarge,),
                Text(widget.job.company.companyName,style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor
                ),),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text("RWF ${fmtNbr(widget.job.minSalary)} - ${fmtNbr(widget.job.maxSalary)} per month"),
                ),
                RichText(text: TextSpan(
                  style: TextStyle(
                    color: color
                  ),
                  children: [
                     WidgetSpan(child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(Icons.access_time,size: 16,color: color,),
                    )),
                    TextSpan(text: widget.job.employmentType),
                     WidgetSpan(child: Padding(
                      padding: const EdgeInsets.only(right: 5,left: 5),
                      child: Icon(Icons.cases_outlined,size: 16,color: color,),
                    )),
                    TextSpan(text: "${widget.job.minExperience??""} Years"),
                     WidgetSpan(child: Padding(
                      padding: const EdgeInsets.only(right: 5,left: 5),
                      child: Icon(Icons.book,size: 16,color: color,),
                    )),
                    TextSpan(text: widget.job.minEducation??""),
                     WidgetSpan(child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(Icons.location_on_outlined,size: 16,color: color,),
                    )),
                    TextSpan(text: widget.job.location),
                  ]
                )),
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text("Posted at ${fmtDate(widget.job.expireDate)}",style: Theme.of(context).textTheme.bodyLarge,),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:vima_app/job_item.dart';
import 'package:vima_app/super_base.dart';

import 'json/job.dart';

class MyJobsScreen extends StatefulWidget{
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends Superbase<MyJobsScreen> {

  List<Job> _list = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadData();
    });
    super.initState();
  }

  Future<void> loadData(){
    return ajax(url: "user/jobs",onValue: (s,v){
      setState(() {
        _list = (s['data'] as Iterable).map((e) => Job.fromJson(e)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView.builder(itemCount: _list.length, itemBuilder: (context,index){
        return JobItem(job: _list[index]);
      }),
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:timetracker/constants.dart';
import 'package:http/http.dart' as http;




class teamView extends StatefulWidget
{
  String user;

  @override
  teamViewState createState()
  {
    return new teamViewState();
  }
  teamView(this.user);
}

class teamViewState extends State<teamView>
{
  @override
  void initState() {

    fetchEmployees();
    super.initState();
    setState(() {
      fetchEmployees();
    });
  }

  List<Employee> _employees = List<Employee>();


  /*Future<String> getProject(String db,String projectID) async{
    final response = await http.post('https://192.168.0.217/s4timesheets/flutter/mySQLConnections/test2.php',body: {
      "db":db.trim(),
      "id":projectID.trim()
    });

    if (response.statusCode == responseCodes.SUCCESS.result) {


      return response.body;

    }
    return "null";
  }*/

  Future<List<Employee>> fetchEmployees() async{


    Map<String, dynamic> userInJasonFormat = jsonDecode(widget.user);

    //var url = 'http://localhost/mySQLConnections/index2.php';
    var url = 'http://localhost/mySQLConnections/team.php';
    var response = await http.post('http://localhost/mySQLConnections/team.php', body:
    {
      "supervisorID":userInJasonFormat['UUID']
    });

    var employees = List<Employee>();

    //print(response.statusCode);
    print(userInJasonFormat['UUID']);
    print(response.body);

    if(response.statusCode == responseCodes.SUCCESS.result)
    {
      var employeesJson = json.decode(response.body);

      for(var employeeJson in employeesJson)
      {
        employees.add(Employee.fromJson(employeeJson));
      }
    }

    //print(_employees.length);
    //print("Employees added to list");
    //print(employees.length);

    return employees;
  }


  Widget bodyData() => DataTable(
      onSelectAll: (b){},
      sortColumnIndex: 0,
      sortAscending: true,
      columns: <DataColumn>[
        DataColumn(
          label: Text("Full Name"),
          numeric: false,
          /*onSort: (i, b){
          print("$i $b");
          setState(() {
            _employees.sort((a, b)=>a.name.compareTo(b.name));
          });
        },*/
          tooltip: "Team members' full name",

        ),
        DataColumn(
            label: Text("Latest Activity"),
            numeric: false,

            tooltip: "Team members' latest activity"
        ),

        DataColumn(
            label: Text("Recorded Time of Latest Activity"),
            numeric: false,

            tooltip: "Team members' recorded time for last activity"
        ),

        DataColumn(
            label: Text("Last Recorded"),
            numeric: false,

            tooltip: "Team members' last activity recording status"
        ),

        DataColumn(
            label: Text("Total Time Tracked (this week)"),
            numeric: false,

            tooltip: "Team members' total time"
        ),

      ],
      rows: _employees.map((teamMember) => DataRow(

        cells: [
          DataCell(
              Text(teamMember.name + " " + teamMember.surname),
              showEditIcon: false,
              placeholder: false
          ),
          DataCell(
              Text(teamMember.latestActivity),
              showEditIcon: false,
              placeholder: false
          ),
          DataCell(
            /*Text((teamMember.hours).toString()),*/
              Text(teamMember.timeOfActivity),
              showEditIcon: false,
              placeholder: false
          ),
          DataCell(
              Text(teamMember.lastRecorded), showEditIcon: false, placeholder: false
          ),
          DataCell(
              Text(teamMember.totalRecorded), showEditIcon: false, placeholder: false //todo: added totalRecorded
          ),
        ],
      ))
          .toList());


  @override
  Widget build(BuildContext context) {
    fetchEmployees().then((value)
    {
      //todo empty employees list on build
      _employees.clear();
      _employees.addAll(value);
    });


    return Scaffold(
      appBar: AppBar(
        title: Text("Team Members"),
          backgroundColor: Color.fromRGBO(20, 70, 119, 1),

      ),
      body: Container(
          child: SingleChildScrollView(

            child: bodyData(),
          )



      ),
    );
  }
}


class Employee
{
  String name;
  String surname;
  String latestActivity;
  String timeOfActivity;
  String lastRecorded;
  String totalRecorded; //TODO: totalRecorded added

  Employee(this.name, this.surname, this.latestActivity, this.timeOfActivity, this.lastRecorded, this.totalRecorded); //TODO: totalRecorded added

  Employee.fromJson(Map<String, dynamic> json)
  {
    name = json['name'];
    surname = json['surname'];
    latestActivity = json['latestActivity'];
    timeOfActivity = json['timeOfActivity'].toString();
    lastRecorded = json['datediff'];
    totalRecorded = json['sumOfHours'].toString(); //TODO: totalRecorded added
  }
}
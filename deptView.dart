import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:timetracker/constants.dart';
import 'package:http/http.dart' as http;


class deptView extends StatefulWidget
{
  String user;
  deptView(this.user);
  @override
  deptViewState createState()
  {
    return new deptViewState();
  }
}

class deptViewState extends State<deptView>
{
  List<Employee> _employees = List<Employee>();

  void initState() {
    fetchEmployees();
    super.initState();

    //   getProjects();
  }

  Future<List<Employee>> fetchEmployees() async{

    //var url = 'http://localhost/mySQLConnections/index.php';
    var url = 'http://localhost/mySQLConnections/dept.php';
    Map<String,dynamic> userInJasonFormat=jsonDecode(widget.user);
    var response = await http.post('http://localhost/mySQLConnections/dept.php',body: {
      "managerID":userInJasonFormat['UUID']
    });

    var employees = List<Employee>();


    print(userInJasonFormat['UUID']);
    print(response.body);

    if(response.statusCode == responseCodes.SUCCESS.result)
    {
      
      var employeesJson = json.decode(response.body);
      if(employeesJson.contains("null")){
        return employees;
      }

      for(var employeeJson in employeesJson)
      {
        employees.add(Employee.fromJson(employeeJson)); //TODO: change _employees to employees
      }
    }

    print("EMPLOYEES POPULATED");
    print(employees.length);


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

          tooltip: "Dept. members' full name",

        ),
        DataColumn(
            label: Text("Latest Activity"),
            numeric: false,

            tooltip: "Dept. members' latest activity"
        ),

        DataColumn(
            label: Text("Recorded Time of Latest Activity"),
            numeric: false,

            tooltip: "Dept. members' recorded time for last activity"
        ),

        DataColumn(
            label: Text("Last Recorded"),
            numeric: false,

            tooltip: "Dept. members' last activity recording status"
        ),

        DataColumn(
            label: Text("Total Time Tracked (this week)"),
            numeric: false,

            tooltip: "Dept. members' total time"
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
              Text(teamMember.totalRecorded), showEditIcon: false, placeholder: false //TODO: totalRecorded added
          ),
        ],
      ))
          .toList());


  @override
  Widget build(BuildContext context) {
    fetchEmployees().then((value)
    {
      //TODO: clear list on build
      _employees.clear();
      _employees.addAll(value);
    });


    return Scaffold(
      appBar: AppBar(
        title: Text("Department Employees"),
        backgroundColor: Color.fromRGBO(20, 70, 119, 1),

      ),
      body: Container(

        child: SingleChildScrollView(

          child: bodyData(),
        )
        ,
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
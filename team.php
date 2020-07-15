<?php
header('Access-Control-Allow-Origin: *');

$DB_SERVER="192.168.0.217";
$DB_USERNAME="s4mysql";
$DB_PASSWORD="mysql";

$S4STAFFDB_NAME="S4Staff";
$S4TIMESHEETDB_NAME="S4TimeSheets";
$DATATABLEDB_NAME="datatables";

//$reportsTo = 16; /////////////newly added//////////////////

//$supervisorID = $_GET["supervisorID"]; //Pass the UUID of logged in user to this variable

$supervisorID = $_POST["supervisorID"];

$con = new mysqli($DB_SERVER, $DB_USERNAME, $DB_PASSWORD);
mysqli_select_db($con, $S4STAFFDB_NAME);
$con->set_charset("utf8");




$SQL_SELECT_ALL="SELECT name, surname,
MAX(S4TimeSheets.ts_entries.datetime) AS datetime,
SUM(CASE WHEN (WEEK(datetime) = SUBSTRING(YEARWEEK(CURDATE()), 5)) 
AND (YEAR(CURDATE()) = YEAR(datetime)) THEN S4TimeSheets.ts_entries.hours ELSE 0 END) as sumOfHours,
S4TimeSheets.ts_entries.hours, S4TimeSheets.TimesheetCategories.Category_Name, UUID as UUID
FROM staffindex
JOIN S4TimeSheets.ts_entries ON S4Staff.staffindex.UUID = S4TimeSheets.ts_entries.staffIndex
JOIN S4TimeSheets.TimesheetCategories ON S4TimeSheets.ts_entries.task = S4TimeSheets.TimesheetCategories.id
JOIN S4Staff.staffdepartmentsubdepartment ON staffindex.UUID = S4Staff.staffdepartmentsubdepartment.staffIndexID
JOIN S4Staff.staffsubdepartment ON S4Staff.staffdepartmentsubdepartment.subDepartment = S4Staff.staffsubdepartment.id
WHERE S4Staff.staffsubdepartment.supervisorID = ?
GROUP BY name, surname";

$SORT="SELECT DISTINCT S4TimeSheets.ts_entries.staffIndex, S4TimeSheets.ts_entries.datetime, S4TimeSheets.ts_entries.task as taskNumber, 
S4TimeSheets.TimesheetCategories.Category_Name as taskName,
S4TimeSheets.ts_entries.hours
FROM S4TimeSheets.ts_entries
JOIN S4TimeSheets.TimesheetCategories ON S4TimeSheets.ts_entries.task = S4TimeSheets.TimesheetCategories.id
WHERE S4TimeSheets.ts_entries.staffIndex = ?
ORDER BY S4TimeSheets.ts_entries.datetime DESC
LIMIT 1";



    
    //echo "Connected";
    if($con != null)
    {
        $stmt = $con->prepare($SQL_SELECT_ALL); /////////////newly added//////////////
        $stmt->bind_param('i', $supervisorID);         /////////////newly added//////////////

        $stmt->execute();                                  /////////////newly added//////////////


        //$result=$con->query(Constants::$SQL_SELECT_ALL);   /////////////commented out//////////////////
        $result = $stmt->get_result();                         /////////////newly added//////////////
        if($result->num_rows>0)
        {
            $stmtTask = $con->prepare($SORT);

            $projects = array();
            
            while($row=$result->fetch_array())
            {
                $stmtTask->bind_param('s', $row['UUID']);

                $stmtTask->execute();

                $task = $stmtTask->get_result();

                $taskArray=$task->fetch_array();

                $taskValue = $taskArray['taskName'];

                $hourValue = $taskArray['hours'];

                /*echo $taskValue;
                echo $hourValue;
                echo "<br>";*/
                
                array_push($projects, array("name"=>$row['name'], 
                "surname"=>$row['surname'], "latestActivity"=>$taskValue, 
                "timeOfActivity"=>$hourValue, "datediff"=>$row['datetime'], "sumOfHours"=>$row['sumOfHours']));
                /*Added sumOfHours*/


                /*echo $row['currentWeek'];
                echo "<br>";*/
                
            }

            

            //echo sizeof($projects);

            $prefix = '';                                           //ADDED CODE FROM THIS POINT
            echo '[';

            foreach($projects as $row)
            {
                //echo $prefix, json_encode($row, JSON_INVALID_UTF8_SUBSTITUTE);
                echo $prefix, json_encode($row);
                $prefix = ',';
            }

            echo ']';                                     //TO THIS POINT AND COMMENTED OUT JSON_ENCODE

            //print(json_encode($projects));
        }
        else
        {
            print(json_encode(array("PHP EXCEPTION: CAN'T RETRIEVE FROM MYSQL")));
        }

        $con->close();
    }
    else
    {
        print(json_encode(array("NULL CONNECTION")));
    }

    
        
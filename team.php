<?php
header('Access-Control-Allow-Origin: *');

$DB_SERVER="192.168.0.217";
$DB_USERNAME="s4mysql";
$DB_PASSWORD="mysql";

$S4STAFFDB_NAME="S4Staff";
$S4TIMESHEETDB_NAME="S4TimeSheets";
$DATATABLEDB_NAME="datatables";

//$reportsTo = 16; /////////////newly added//////////////////

$supervisorID = $_POST["supervisorID"]; //Pass the UUID of logged in user to this variable
//$supervisorID = $_GET["supervisorID"];


$con = new mysqli($DB_SERVER, $DB_USERNAME, $DB_PASSWORD);
mysqli_select_db($con, $S4STAFFDB_NAME);
$con->set_charset("utf8");

static $SQL_SELECT_ALL="SELECT name, surname, S4TimeSheets.ts_entries.hours, S4TimeSheets.TimesheetCategories.Category_Name,  
MAX(S4TimeSheets.ts_entries.datetime) AS datetime, DATEDIFF(CURDATE(), datetime) AS datediff,
SUM(CASE WHEN (WEEK(datetime) = SUBSTRING(YEARWEEK(CURDATE()), 5)) 
AND (YEAR(CURDATE()) = YEAR(datetime)) THEN S4TimeSheets.ts_entries.hours ELSE 0 END) as sumOfHours /*updated SUM*/
FROM staffindex
INNER JOIN S4TimeSheets.ts_entries ON S4Staff.staffindex.UUID = S4TimeSheets.ts_entries.staffIndex
INNER JOIN S4TimeSheets.TimesheetCategories ON S4TimeSheets.ts_entries.task = S4TimeSheets.TimesheetCategories.id
INNER JOIN S4Staff.staffdepartmentsubdepartment ON staffindex.UUID = S4Staff.staffdepartmentsubdepartment.staffIndexID
INNER JOIN S4Staff.staffsubdepartment ON S4Staff.staffdepartmentsubdepartment.subDepartment = S4Staff.staffsubdepartment.id
WHERE S4Staff.staffsubdepartment.supervisorID = ?
GROUP BY name, surname";
    
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
            $projects = array();
            while($row=$result->fetch_array())
            {
                
                
                array_push($projects, array("name"=>$row['name'], 
                "surname"=>$row['surname'], "latestActivity"=>$row['Category_Name'], 
                "timeOfActivity"=>$row['hours'], "datediff"=>$row['datetime'], "sumOfHours"=>$row['sumOfHours']));
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

    
        
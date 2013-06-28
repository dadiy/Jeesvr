#!/usr/bin/php -q
<?php
//////////////////////////////////////////////////////////////////////////\\
//                                                                        \\
//             Purpose:  Read serial port and process incoming data       \\
//                                                                        \\
//        Script Name :  serial_read.sh                                   \\
//                                                                        \\
//              Author:  David Abbishaw (David@Abbishaw.com)              \\
//        Last Updated:                                                   \\
//                                                                        \\
//  Revision History                                                      \\
//  ^^^^^^^^^^^^^^^^                                                      \\
//                                                                        \\
//   3 December 2012 - Initial version                                    \\
//                                                                        \\
//////////////////////////////////////////////////////////////////////////\\

include '/remotecommands/jeesvr/jeesvr_include.php';

//Location of file that contains commands to send.
$jeesvr_sendcommand = '/tmp/jeesvr_sendcommand.tmp';


$datelastsent = 0 ;

$arrNodeLastSeen = array();
$arrMSGLastSent = array();


//echo date("YmdHis");
//echo $date;

//////////////
// Run "screen /dev/ttyUSB0 57600" to test serial port and to reset speed setting after reboot.
// To exit screen screen press CTRL + A + K
// I wonder if // screen /dev/ttyUSB0 57600 & and then pkill screen would be enough?


// Set the Serial port settings.
exec("stty 57600 raw -echo <" . $SerialPort);


$fp = fopen ($SerialPort, "r"); // open read/write
    if (!$fp) {
        echo "Uh-oh. Port not opened.";
    } else {

     while(!feof($fp)) { 
        set_time_limit(0);
        $serline = fgets($fp);

        //echo "RAW $serline\n";


//fwrite is wrong syntax is fwrite ( resource $handle , string $string [, int $length ] )

        ///////////////////////////////////////
        // Send any waiting commands.
        if (file_exists($jeesvr_sendcommand )) {
          $command_to_send = "";
          $command_to_send = read_file($jeesvr_sendcommand);
          write_to_raw_evtlog("SC " . $command_to_send );
          fwrite($fp);
          unlink($jeesvr_sendcommand);
        }

        process_serial_data($serline);

      }
            fclose ($fp);
    }


function checklastsent ($node , $lastsent ) {
// 100 = 1hour
//need to check last sent for each node.

//echo "last sent " . $lastsent . "\n\n";
//echo "last sent plus " . ($lastsent  + 100)  . "\n\n";

  if ( $lastsent  + 10000 < date("YmdHis") ) {
    return true;
  } else {
    return false;
  }

}

function process_serial_data($serdata) {

global $datelastsent;
global $arrNodeLastSeen, $arrMSGLastSent;


/* 
/////////////////////////
// Devices

3.1 Inside Fridge
3.2 Outside Fridge
3.3 Bed
3.4 Car

*/

  $Known_Nodes = array('N1.10', 'N1.12', 'N2.1', 'N2.2', 'N3.1', 'N3.2', 'N3.3', 'N3.4', 'N3.5',  'N3.6','N3.20', 'N4.1' , 'N4.2', 'N5.1');

  write_to_raw_evtlog($serdata);
  //list($crc, $node, $datatype, $datavalue) = split(' ', $serdata);


  /////////////////
  //  New code for changes to node and serial number
  ////////////////
  list($crc, $node, $serial, $datatype, $datavalue, $tmpbat , $bat, $tmpseq, $seq) = split(' ', $serdata);

//echo "node $node\n";
//echo "Serial $serial\n\n";

  (string) $node = "N".(string)$node .".". (string)$serial ;

//echo "node $node\n";

   if (in_array($node, $Known_Nodes) && $crc == "OK" ) {

//check low battery flag here  // need to setup vairiabes for last msg from each node.

  if ( $bat == "1" ) {
        exec("/remotecommands/boxcar/provider/House_Errors/send_to_user.rb \"david@abbishaw.com\" \"Low Battery $node\" &");
    }


  //Save when we last saw this node
  $arrNodeLastSeen[$node] = time();

        switch ($node)
          {

  // #//////////////////////////////////////////////////////          
  //           case '68':
  //             //echo "Node 68 found\n";

  //               switch ($datatype)
  //                 {
  //                   case 'T':
  //                     echo "Process Temperature $node $datavalue\n";
  //                     if ( validate_ds18b20($datavalue)) {
  //                       #Do something with the temperature
  //                       #system('/wherever/logtemp' . $datatype)
  //                       //debug("Node ".$node." datatype ". $datatype." value ". $datavalue);



  //                       if ( $datavalue < 8 ) {

  //                         if ( checklastsent($node , $datelastsent)) {
  //                           exec("/remotecommands/boxcar/provider/House_Notifications/broadcast.rb \"Office Cold Alert $datavalue °C\" &");
  //                           $datelastsent = date("YmdHis");
  //                         }

  //                       }
  //                     }
  //                     break;

  //                   case 'H':
  //                     echo "Process Humidity $node $datavalue\n";
  //                     //debug("Node ".$node." datatype ". $datatype." value ". $datavalue);
  //                     break;


  //                 }
  //             break;



  //////////////////////////////////////////////////////          
            case 'N1.10':
              //echo "Node 110 found\n";

                switch ($datatype)
                  {
                    case 'C':
                      echo "Process Count $node $datavalue\n";
                        #Do something with the temperature
                        #system('/wherever/logtemp' . $datatype)
                        //debug("Node ".$node." datatype ". $datatype." value ". $datavalue);
                        break;


                  }
              break;

  //////////////////////////////////////////////////////          
            // case '1.12':
            //   //echo "Node 112 found\n";

            //     switch ($datatype)
            //       {
            //         case 'T':
            //           echo "Process Temperature $node $datavalue\n";
            //             if ( validate_ds18b20($datavalue)) {
            //             #Do something with the temperature
            //             #system('/wherever/logtemp' . $datatype)
            //             //debug("Node ".$node." datatype ". $datatype." value ". $datavalue);

            //             if ( $datavalue > 7 ) {

            //               if ( checklastsent($node , $datelastsent)) {
            //                 exec("/remotecommands/notify_DA.sh Fridge Temperature $node Alert $datavalue °C &");
            //                 $datelastsent = date("YmdHis");
            //               }
                          
            //             }
            //             }
            //           break;

            //         case 'L':
            //           echo "Low Battery $node $datavalue\n";
            //           //debug("Node ".$node." datatype ". $datatype." value ". $datavalue);
            //               if ( checklastsent($node , $datelastsent)) {
            //                 exec("/remotecommands/notify_DA.sh Low Battery $node &");
            //                 $datelastsent = date("YmdHis");
            //               }
            //           break;

            //       }
            //   break;



//////////////////////////////////////////////////////          
            case 'N2.1':
              //echo "Node 2.1 Motion at Front Door\n";

                switch ($datatype)
                  {
                    case 'B':
                      echo "Process Motoin $node $datavalue\n";
                            exec("/remotecommands/mot-hsefront2.sh $datavalue &");
                        
                      break;


                  }
              break;


//////////////////////////////////////////////////////          
            case 'N2.2':
              //echo "Node 2.2 Motion in Green Box\n";

                switch ($datatype)
                  {
                    case 'B':
                      echo "Process Motoin $node $datavalue\n";
                            exec("/remotecommands/mot-greenbox.sh $datavalue &");
                        
                      break;


                  }
              break;






//////////////////////////////////////////////////////          
            case 'N3.1':
              //echo "Node 3.1 Internal Fridge found\n";

                switch ($datatype)
                  {
                    case 'T':
                      echo "Process Temperature $node $datavalue\n";
                        if ( validate_ds18b20($datavalue)) {
                        exec("/remotecommands/temperature/Kitchen_Fridge/log_data $datavalue &");




                        if ( $datavalue > 7 ) {

                          if ( checklastsent($node , $datelastsent)) {
                            //exec("/remotecommands/notify_DA.sh Inside Fridge Temp $node Alert $datavalue °C &");
                            exec("/remotecommands/boxcar/provider/House_Notifications/broadcast.rb \"Inside Fridge Temp ($node) Alert $datavalue °C\" &");

                            $datelastsent = date("YmdHis");
                          }
                          
                        }
                        }
                      break;


                  }
              break;

//////////////////////////////////////////////////////          
            case 'N3.2':
              //echo "Node 3.1 Garage Fridge found\n";

                switch ($datatype)
                  {
                    case 'T':
                      echo "Process Temperature $node $datavalue\n";
                        if ( validate_ds18b20($datavalue)) {
                        exec("/remotecommands/temperature/Garage_Fridge/log_data $datavalue &");

                        if ( $datavalue > 7 ) {

                          if ( checklastsent($node , $datelastsent)) {
                           // exec("/remotecommands/notify_DA.sh Outside Fridge Temp $node Alert $datavalue °C &");
                            exec("/remotecommands/boxcar/provider/House_Notifications/broadcast.rb \"Outside Fridge Temp ($node) Alert $datavalue °C\" &");



                            $datelastsent = date("YmdHis");
                          }
                          
                        }
                        }
                      break;


                  }
              break;


//////////////////////////////////////////////////////          
            case 'N3.3':
              //echo "Node 3.3 Bed\n";

                switch ($datatype)
                  {
                    case 'T':
                      echo "Process Temperature $node $datavalue\n";
                        if ( validate_ds18b20($datavalue)) {
                            exec("/remotecommands/temperature/Bed/log_data $datavalue &");
                        }
                        
                      break;


                  }
              break;



//////////////////////////////////////////////////////          
            case 'N3.4':
              //echo "Node 3.3 Car\n";

                switch ($datatype)
                  {
                    case 'T':
                      echo "Process Temperature $node $datavalue\n";
                        if ( validate_ds18b20($datavalue)) {
                            exec("/remotecommands/temperature/Car/log_data $datavalue &");


                        if ( $datavalue <0 ) {

                          if ( checklastsent($node , $datelastsent)) {
                              exec("/remotecommands/boxcar/provider/House_Notifications/broadcast.rb \"Car Freeze Warning ($node) $datavalue °C\" &");
                              $datelastsent = date("YmdHis");
                          }
                          
                        }




                        }
                        
                      break;


                  }
              break;



//////////////////////////////////////////////////////          
            case 'N3.5':
              //echo "Node 3.5 ShowerWaste\n";

                switch ($datatype)
                  {
                    case 'T':
                      echo "Process Temperature $node $datavalue\n";
                        if ( validate_ds18b20($datavalue)) {
                            exec("/remotecommands/temperature/ShowerWaste/log_data $datavalue &");
                        }
                        
                      break;


                  }
              break;



//////////////////////////////////////////////////////
            case 'N3.6':
              //echo "Node 3.6 HotTub\n";

                switch ($datatype)
                  {
                    case 'T':
                      echo "Process Temperature $node $datavalue\n";
                        if ( validate_ds18b20($datavalue)) {
                            exec("/remotecommands/temperature/HotTub/log_data $datavalue &");
                        }

                      break;


                  }
              break;







//////////////////////////////////////////////////////          
            case 'N3.20':
              //echo "Node 3.20 Mobile Sensor found\n";

                switch ($datatype)
                  {
                    case 'T':
                      echo "Process Temperature $node $datavalue\n";
                        if ( validate_ds18b20($datavalue)) {
                        exec("/remotecommands/temperature/MobileSensor/log_data $datavalue &");

                        }
                      break;


                  }
              break;




//////////////////////////////////////////////////////          
            case 'N4.1':
              //echo "Node 4.1 Outside Light\n";

                switch ($datatype)
                  {
                    case 'L':
                      echo "Process Light $node $datavalue\n";
                            exec("/remotecommands/temperature/OutsideLight/log_data $datavalue &");
                      break;


                  }
              break;




//////////////////////////////////////////////////////          
            case 'N4.2':
              //echo "Node 4.2 Lux Light\n";

                switch ($datatype)
                  {
                    case 'L':
                      echo "Process Light $node $datavalue\n";
                            exec("/remotecommands/temperature/OutsideLuxL/log_data $datavalue &");
                      break;

                    case 'H':
                      echo "Process Light $node $datavalue\n";
                            exec("/remotecommands/temperature/OutsideLuxH/log_data $datavalue &");
                      break;
                  }
              break;


//////////////////////////////////////////////////////          
            case 'N5.1':
              //echo "Node 5.1 Electricity Meter\n";

                switch ($datatype)
                  {
                    case 'W':
                      echo "Process Watts $node $datavalue\n";
                            exec("/remotecommands/temperature/Electricity/log_data $datavalue &");
                       
                      break;


                  }
              break;




  ////////////////////////////////////////////////////// 
           default:
              //echo "An error occured - Err# " . $rval;
          }


    }
}




?>






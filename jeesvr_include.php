<?php

$SerialPort = "/dev/ttyUSB0";

function write_to_file ($infilen , $value) {
		$fp = fopen($infilen, 'a');
		fwrite($fp, $value);
		fclose($fp);

}

function read_file ($filename) {
		$handle = fopen($filename, "r");
		$contents = fread($handle, filesize($filename));
		fclose($handle);
		return $contents;
}



function validate_ds18b20 ($val) {
// DS18b20 Range -55°C to +125°C excluding +85
if ( $val > -55 && $val < 125 && $val <> 85 ) {
  return true; 
} else {
  return false;
}

}



function debug ($value) {
$debug="yes";

if ( strtolower($debug) == "yes" ) {

$filename = "/tmp/debug_serial.log";
        $fp = fopen($filename, 'a');
        fwrite($fp, date('D, d M Y H:i:s T') . " - " . $value );
        fclose($fp);

    }

echo "$value\n";

}




function write_to_raw_evtlog($strMessage) {
    $log_hse_evt="/tmp/serial_raw_event_log";
    write_to_file( $log_hse_evt ,  "[" . date('d/m/y H:i:s') . "] " . $strMessage);

}




function write_to_evtlog($strMessage) {
    $log_hse_evt="/tmp/serial_event_log";
    write_to_file( $log_hse_evt ,  "[" . date('d/m/y H:i:s') . "] " . $strMessage);

}

?>
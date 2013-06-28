#!/usr/bin/php -q
<?php
include '/remotecommands/jeesvr/jeesvr_include.php';

///////////////////////////////////////////////
//TODO

if (isset($argv[1]) && isset($argv[2])  && isset($argv[3])  ) {
	echo "Sending " . $argv[1] . " " . $argv[2] . " " . $argv[3] . "\n" ;

	write_to_raw_evtlog("SC " . $argv[1] . " " . $argv[2] . " " . $argv[3] . " " . $argv[4] );

	$fp = fopen ($SerialPort, "w"); // open read/write
	fwrite($fp, $argv[1] . " " . $argv[2] . " " . $argv[3] . " " . "7 G");
	fclose ($fp);

}
else{
	echo "\nUsage: ./jee_sendcmd.sh Command\n ie ./jee_sendcmd.sh A B C\n";
	echo "Where....\n";
	echo "          A = Node to Send to\n";
	echo "          B = Command Send to\n";
	echo "          C = Serial Number to\n";
}

?>

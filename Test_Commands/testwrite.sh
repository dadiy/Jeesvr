#!/usr/bin/php -q
<?php


///////////////////////////////////////////////
//TODO
// Move serial port to include file
// include include file
// write to ser log
// use argv[] to get command
// validate argv before trying to send




$fp = fopen ("/dev/ttyUSB0", "w"); // open read/write

fwrite($fp, "9 1 A A G\n");

fclose ($fp);


?>

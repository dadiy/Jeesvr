echo "Queueing Test Command"
echo -e "9 A 1 G\n" >/tmp/jeesvr_sendcommand.tmp;echo "[`date +"%d/%m/%y %H:%M:%S"`] Command Queued ">>/tmp/serial_raw_event_log

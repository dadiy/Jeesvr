######################################
# Crude way to handle a crash and restart the collection.
until /remotecommands/jeesvr/jeesvr.sh > /dev/null 2>&1; do
    echo "Crashed with exit code $?.  Respawning.." >/tmp/jeesvr_errorlog.txt
    sleep 1
done


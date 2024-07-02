#!/bin/bash

#Install python dependencies
pip3 install -r requirements.txt

# Create the run.sh file with the desired content
echo '#!/bin/bash' > .runProg.sh
echo 'cd "$(dirname "$0")"' >> .runProg.sh
echo '/usr/local/bin/gunicorn -b 0.0.0.0:5000 app:app' >> .runProg.sh

# Provide execute permissions to run.sh (if needed)
chmod +x .runProg.sh

clear
current_directory=$(pwd)
echo "After 10 seconds a new tab will open add the below given line in the last of it , save and close it"
echo ""
echo "@reboot $current_directory/.runProg.sh >> $current_directory/logs/logfile.log 2>&1"
sleep 10
crontab -e
/usr/local/bin/gunicorn -b 0.0.0.0:5000 app:app

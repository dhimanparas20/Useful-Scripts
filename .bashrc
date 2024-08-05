neofetch
alias down="cd && cd Downloa*"
alias desk="cd && cd Desktop"
#alias server='sshpass -p "Luffykiid@2069" ssh paras@'
alias server='ssh -i /home/paras/Downloads/server.pem  ubuntu@'
alias server2='ssh -i /home/paras/Downloads/mstkey.pem  ubuntu@'
export PATH="$PATH:$HOME/bin"
alias runf="time python3 ~/bin/run.py -f"
alias python="python3"
alias activate="python3 -m venv venv && source venv/bin/activate"
alias runserver="python3 manage.py runserver 0.0.0.0:5000  "
alias migrate="python3 manage.py migrate"
alias makemigrations="python3 manage.py makemigrations"

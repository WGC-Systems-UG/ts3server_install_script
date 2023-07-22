#!/bin/bash
#Created By: WGC-Systems UG (haftungsbeschränkt)
#Version: 1.0.0
#Erstellt am: 22-07-2023
#Aktualisierung vom: 22-07-2023
#Beschreibung: Installation eines Teamspeak³ Servers getestet unter folgenden Systemen: Debian/Ubuntu/RockyLinux

if ! which sudo >/dev/null; then
    echo "Bitte installieren Sie sudo manuell und führen Sie das Skript erneut aus."
    exit 1
fi
if ! which wget >/dev/null; then
    echo "wget ist nicht installiert."

    OS=$(uname -s)

    case $OS in
        "Linux")
            LINUX_DISTRO=$(cat /etc/os-release | grep NAME | head -n1 | cut -d'=' -f2 | tr -d '"')

            if [[ $LINUX_DISTRO == *"Ubuntu"* ]] || [[ $LINUX_DISTRO == *"Debian"* ]]; then
                INSTALL_CMD="sudo apt-get install wget"
            elif [[ $LINUX_DISTRO =~ *"Fedora"* ]]; then
                INSTALL_CMD="sudo dnf install wget"
            elif [[ $LINUX_DISTRO =~ *"CentOS"* ]] || [[ $LINUX_DISTRO =~ *"RHEL"* ]] || [[ $LINUX_DISTRO =~ *"Rocky Linux"* ]]; then
                INSTALL_CMD="sudo yum install wget"
            else
                echo "Ihr Linux-Distribution wird derzeit nicht unterstützt. Bitte installieren Sie wget manuell."
                exit 1
            fi
            ;;
        *"Darwin"*)
            INSTALL_CMD="brew install wget"
            ;;
        *)
            echo "Ihr Betriebssystem wird derzeit nicht unterstützt. Bitte installieren Sie wget manuell."
            exit 1
    esac

    read -p "Möchten Sie wget mit dem folgenden Befehl installieren: '$INSTALL_CMD' (y/n)? " RESPONSE

    if [[ $RESPONSE =~ ^[Yy]$ ]]; then
        eval $INSTALL_CMD
    else
        echo "Bitte installieren Sie wget manuell und führen Sie das Skript erneut aus."
        exit 1
    fi
fi

echo "wget ist installiert."

if ! which tar >/dev/null; then
    echo "tar ist nicht installiert."

    OS=$(uname -s)

    case $OS in
        "Linux")
            LINUX_DISTRO=$(cat /etc/os-release | grep NAME | head -n1 | cut -d'=' -f2 | tr -d '"')

            if [[ $LINUX_DISTRO == *"Ubuntu"* ]] || [[ $LINUX_DISTRO == *"Debian"* ]]; then
                INSTALL_CMD="sudo apt-get install tar"
            elif [[ $LINUX_DISTRO =~ *"Fedora"* ]]; then
                INSTALL_CMD="sudo dnf install tar"
            elif [[ $LINUX_DISTRO =~ *"CentOS"* ]] || [[ $LINUX_DISTRO =~ *"RHEL"* ]] || [[ $LINUX_DISTRO =~ *"Rocky Linux"* ]]; then
                INSTALL_CMD="sudo yum install tar"
            else
                echo "Ihr Linux-Distribution wird derzeit nicht unterstützt. Bitte installieren Sie tar manuell."
                exit 1
            fi
            ;;
        *"Darwin"*)
            INSTALL_CMD="brew install tar"
            ;;
        *)
            echo "Ihr Betriebssystem wird derzeit nicht unterstützt. Bitte installieren Sie tar manuell."
            exit 1
    esac

    read -p "Möchten Sie tar mit dem folgenden Befehl installieren: '$INSTALL_CMD' (y/n)? " RESPONSE

    if [[ $RESPONSE =~ ^[Yy]$ ]]; then
        eval $INSTALL_CMD
    else
        echo "Bitte installieren Sie tar manuell und führen Sie das Skript erneut aus."
        exit 1
    fi
fi

echo "bzip2 ist installiert."

if ! which bzip2 >/dev/null; then
    echo "bzip2 ist nicht installiert."

    OS=$(uname -s)

    case $OS in
        "Linux")
            LINUX_DISTRO=$(cat /etc/os-release | grep NAME | head -n1 | cut -d'=' -f2 | tr -d '"')

            if [[ $LINUX_DISTRO =~ *"Ubuntu"* ]] || [[ $LINUX_DISTRO =~ *"Debian"* ]]; then
                INSTALL_CMD="sudo apt-get install bzip2"
            elif [[ $LINUX_DISTRO =~ *"Fedora"* ]]; then
                INSTALL_CMD="sudo dnf install bzip2"
            elif [[ $LINUX_DISTRO =~ *"CentOS"* ]] || [[ $LINUX_DISTRO =~ *"RHEL"* ]] || [[ $LINUX_DISTRO =~ *"Rocky Linux"* ]]; then
                INSTALL_CMD="sudo yum install bzip2"
            else
                echo "Ihr Linux-Distribution wird derzeit nicht unterstützt. Bitte installieren Sie bzip2 manuell."
                exit 1
            fi
            ;;
        *"Darwin"*)
            INSTALL_CMD="brew install bzip2"
            ;;
        *)
            echo "Ihr Betriebssystem wird derzeit nicht unterstützt. Bitte installieren Sie bzip2 manuell."
            exit 1
    esac

    read -p "Möchten Sie bzip2 mit dem folgenden Befehl installieren: '$INSTALL_CMD' (y/n)? " RESPONSE

    if [[ $RESPONSE =~ ^[Yy]$ ]]; then
        eval $INSTALL_CMD
    else
        echo "Bitte installieren Sie bzip2 manuell und führen Sie das Skript erneut aus."
        exit 1
    fi
fi

echo "bzip2 ist installiert."

SERVER_IP=$(hostname -I | cut -d' ' -f1)
TS3_LATEST_VERSION=$(wget -t 1 -T 3 'https://files.teamspeak-services.com/releases/server/' -q -O - | grep -Ei 'a href="[0-9]+' | grep -Eo ">(.*)<" | tr -d ">" | tr -d "<" | uniq | sort -V -r | grep -iv "exp" | head -n 1)

echo "Die neueste Teamspeak-Version ist: $TS3_LATEST_VERSION"
if [ "$EUID" -ne 0 ]; then
    echo "Dieses Skript muss als Root ausgeführt werden"
    exit 1
fi

read -p "Möchten Sie den voreingestellten Benutzernamen (ts3server) ändern? (y/n): " CHANGE_USER

if [[ $CHANGE_USER =~ ^[Yy]$ ]]; then
    read -p "Bitte geben Sie den neuen Benutzernamen ein: " USERNAME
else
    USERNAME=ts3server
fi

read -p "Möchten Sie den voreingestellten Installationspfad (/opt/ts3server) ändern? (y/n): " CHANGE_INSTALL_DIR
if [[ $CHANGE_INSTALL_DIR =~ ^[Yy]$ ]]; then
    while true; do
        read -p "Bitte geben Sie den neuen Installationspfad ein ohne / am Ende: " INSTALL_PATH
        if [[ $INSTALL_PATH != */ ]]; then
            break
        else
            echo "Die Eingabe sollte nicht mit einem / enden. Bitte erneut eingeben."
        fi
    done
else
    INSTALL_PATH=/opt/ts3server
fi

read -p "Möchten Sie die voreingestellte Teamspeak Server Version ($TS3_LATEST_VERSION) ändern? (y/n): " CHANGE_TS_VERSION

if [[ $CHANGE_TS_VERSION =~ ^[Yy]$ ]]
then
    read -p "Bitte geben Sie die neue Teamspeak Server Version ein: " TS_VERSION
else
    TS_VERSION=$TS3_LATEST_VERSION
fi

read -p "Möchten Sie die voreingestellte IP-Adresse ($SERVER_IP) ändern? (y/n): " CHANGE_IP

if [[ $CHANGE_IP =~ ^[Yy]$ ]]
then
    read -p "Bitte geben Sie die neue IP-Adresse ein: " IP
else
    IP=$SERVER_IP
fi

read -p "Möchten Sie die voreingestellte Query IP ($SERVER_IP) ändern? (y/n): " CHANGE_QUERY_IP

if [[ $CHANGE_QUERY_IP =~ ^[Yy]$ ]]
then
    read -p "Bitte geben Sie die neue Query IP ein: " QUERY_IP
else
    QUERY_IP=$SERVER_IP
fi

read -p "Möchten Sie den voreingestellten Query Port (10011) ändern? (y/n): " CHANGE_QUERY_PORT

if [[ $CHANGE_QUERY_PORT =~ ^[Yy]$ ]]
then
    read -p "Bitte geben Sie den neuen Query Port ein: " QUERY_PORT
else
    QUERY_PORT=10011
fi

read -p "Möchten Sie die voreingestellte Filetransfer IP ($SERVER_IP) ändern? (y/n): " CHANGE_FILE_TRANS_IP

if [[ $CHANGE_FILE_TRANS_IP =~ ^[Yy]$ ]]
then
    read -p "Bitte geben Sie die neue Query IP ein: " FILE_TRANS_IP
else
    FILE_TRANS_IP=$SERVER_IP
fi

read -p "Möchten Sie den voreingestellten Filetransfer Port (30033) ändern? (y/n): " CHANGE_FILE_TRANS_PORT

if [[ $CHANGE_FILE_TRANS_PORT =~ ^[Yy]$ ]]
then
    read -p "Bitte geben Sie den neuen Query Port ein: " FILE_TRANS_PORT
else
    FILE_TRANS_PORT=30033
fi

read -p "Möchten Sie den voreingestellten Lizenzpfad ($INSTALL_PATH) ändern? (y/n): " CHANGE_LICENSE_KEY_PATH
if [[ $CHANGE_LICENSE_KEY_PATH =~ ^[Yy]$ ]]; then
    while true; do
        read -p "Bitte geben Sie den neuen Lizenzpfad ein ohne / am Ende: " LICENSE_KEY_PATH
        if [[ $LICENSE_KEY_PATH != */ ]]; then
            break
        else
            echo "Die Eingabe sollte nicht mit einem / enden. Bitte erneut eingeben."
        fi
    done
else
    LICENSE_KEY_PATH=$INSTALL_PATH
fi


echo -e "\nDer eingestellte Benutzername ist: $USERNAME"
echo -e "\nDer eingestellte Installationspfad ist: $INSTALL_PATH"
echo -e "\nDie eingestellte TS Version ist: $TS_VERSION"
echo -e "\nDie eingestellte IP-Adresse ist: $IP"
echo -e "\nDie eingestellte Query IP-Adresse ist: $QUERY_IP"
echo -e "\nDer eingestellte Query Port ist: $QUERY_PORT"
echo -e "\nDie eingestellte Filetransfer IP-Adresse ist: $FILE_TRANS_IP"
echo -e "\nDer eingestellte Filetransfer Port ist: $FILE_TRANS_PORT"
echo -e "\nDer eingestellte Lizenzpfad ist: $LICENSE_KEY_PATH"


read -p "Sind diese Werte korrekt? (y/n): " CONFIRM_VALUES

if [[ $CONFIRM_VALUES =~ ^[Yy]$ ]]
then
    echo "Die Werte wurden bestätigt. Die Installation wird gestartet...."

else
    echo "Die Werte wurden nicht bestätigt. Das Skript wird neu gestartet..."
    exec $0
fi

echo "Bitte geben Sie ein sicheres Passwort für den Serveradmin ein: "
read -s password
echo
if [ -z "$password" ]; then
  echo "Passworteingabe ist obligatorisch. Bitte versuchen Sie es erneut."
  exit 1
fi

echo "Bitte geben Sie Ihr Passwort erneut ein zur Bestätigung: "
read -s password_confirm
echo
if [ "$password" != "$password_confirm" ]; then
  echo "Passworteingaben stimmen nicht überein. Bitte versuchen Sie es erneut."
  exit 1
fi

echo "Ihr Passwort wurde erfolgreich eingegeben und bestätigt."

if grep -iq 'NAME="*.ubuntu.*"' /etc/os-release; then
    adduser --system --group --disabled-login --disabled-password --no-create-home "$USERNAME" >/dev/null 2>&1

elif grep -iq 'NAME=.*debian.*' /etc/os-release; then
    adduser --system --group --disabled-login --disabled-password --no-create-home "$USERNAME" >/dev/null 2>&1

elif grep -iq 'NAME="*.centos.*"' /etc/os-release; then
    useradd -r -s /sbin/nologin "$USERNAME" && passwd -l "$USERNAME" >/dev/null 2>&1

elif grep -iq 'NAME="*.fedora.*"' /etc/os-release; then
    useradd -r -s /sbin/nologin "$USERNAME" && passwd -l "$USERNAME" >/dev/null 2>&1

elif grep -iq 'NAME="*.rocky linux.*"' /etc/os-release; then
    useradd -r -s /sbin/nologin "$USERNAME" && passwd -l "$USERNAME" >/dev/null 2>&1

elif grep -iq 'NAME="*.rhel.*"' /etc/os-release; then
    useradd -r -s /sbin/nologin "$USERNAME" && passwd -l "$USERNAME" >/dev/null 2>&1
else
    echo "Unbekanntes Betriebssystem."
    exit 1
fi
if [ $? -ne 0 ]; then
    echo "Fehler beim Anlegen des Benutzers $USERNAME."
    exit 1
fi

X86="https://files.teamspeak-services.com/releases/server/$TS_VERSION/teamspeak3-server_linux_x86-$TS_VERSION.tar.bz2"
X64="https://files.teamspeak-services.com/releases/server/$TS_VERSION/teamspeak3-server_linux_amd64-$TS_VERSION.tar.bz2"

ARCH=$(uname -m)
if [ "$ARCH" = "i386" ]; then
    LINK="$X86"
elif [ "$ARCH" = "i686" ];then
    LINK="$X86"
elif [ "$ARCH" = "x86_64" ];then
    LINK="$X64"
fi

function ts3server_install {
mkdir -p "$INSTALL_PATH"
chmod 770 "$INSTALL_PATH"
touch "$INSTALL_PATH"/.ts3server_license_accepted
tar -xjf teamspeak3-server_linux*.tar.bz2
mv teamspeak3-server_linux*/* "$INSTALL_PATH"
chown "$USERNAME":"$USERNAME" "$INSTALL_PATH" -R
rm -rf teamspeak3-server_linux*.tar.bz2 teamspeak3-server_linux*/
}


echo "Teamspeak³ Server wird unter '$INSTALL_PATH' installiert $LINK:"
if wget -q "$LINK"; then
  ts3server_install
else
  echo -e "\n ERROR!!! Teampseak³ Server konnte nicht heruntergeladen werden \n"
  exit 1
fi

rm -rf "$INSTALL_PATH"/ts3server.ini
touch "$INSTALL_PATH"/ts3server.ini
cat > "$INSTALL_PATH"/ts3server.ini <<EOF
machine_id=
default_voice_port=9987
voice_ip=$SERVER_IP
licensepath=$LICENSE_KEY_PATH
filetransfer_port=$FILE_TRANS_PORT
filetransfer_ip=$FILE_TRANS_IP
query_port=$QUERY_PORT
query_ip=$QUERY_IP
query_ip_allowlist=query_ip_allowlist.txt|query_ip_whitelist.txt
query_ip_denylist=query_ip_denylist.txt|query_ip_blacklist.txt
dbplugin=ts3db_sqlite3
dbpluginparameter=
dbsqlpath=sql/
dbsqlcreatepath=create_sqlite/
dbconnections=10
logpath=logs
logquerycommands=0
dbclientkeepdays=30
logappend=1
query_skipbruteforcecheck=0
query_buffer_mb=20
http_proxy=
license_accepted=1
serverquerydocs_path=serverquerydocs/
query_ssh_ip=0.0.0.0, ::
query_ssh_port=10022
query_protocols=raw,http,ssh
query_ssh_rsa_host_key=ssh_host_rsa_key
query_timeout=300
query_http_ip=0.0.0.0, ::
query_http_port=10080
query_https_ip=0.0.0.0, ::
query_https_port=10443
query_pool_size=2
mmdbpath=
logquerytiminginterval=0
EOF


touch /etc/systemd/system/ts3server.service
cat > /etc/systemd/system/ts3server.service <<EOF
[Unit]
Description=TeamSpeak3 Server $USERNAME
Wants=network-online.target
After=syslog.target network.target

[Service]
WorkingDirectory=$INSTALL_PATH
User=$USERNAME
Group=$USERNAME
Type=forking
ExecStart=$INSTALL_PATH/ts3server_startscript.sh start inifile=$INSTALL_PATH/ts3server.ini
ExecStop=$INSTALL_PATH/ts3server_startscript.sh stop
ExecReload=$INSTALL_PATH/ts3server_startscript.sh reload
PIDFile=$INSTALL_PATH/ts3server.pid

[Install]
WantedBy=multi-user.target
EOF

chown "$USERNAME":"$USERNAME" "$INSTALL_PATH" -R

echo "Starting the TeamSpeak 3 server"
cd $INSTALL_PATH
./ts3server_minimal_runscript.sh inifile=ts3server.ini serveradmin_password=$password > /dev/null 2>&1 &
pid=$!
sleep 10
kill $pid
chown "$USERNAME":"$USERNAME" "$INSTALL_PATH" -R
systemctl --quiet enable ts3server.service
rm /dev/shm/7gbhujb54g8z9hu43jre8
sleep 2
systemctl start ts3server.service
sleep 5

EXTERNAL_IP=$(wget -qO - http://geoip.ubuntu.com/lookup | sed -n -e 's/.*<Ip>\(.*\)<\/Ip>.*/\1/p')
IMPORTANT=$(cat "$INSTALL_PATH"/logs/*.log | grep -P -o "token=[a-zA-z0-9+]+")

echo -e "ServerAdmin Key: $IMPORTANT\n"
echo -e "Fertig! Der Server wurde erfolgreich installiert.\n Du kannst YATQA verwenden um deinen Server besser zu verwalten.\n"
echo -e "Deine Server IP lautet: $IP\n"
echo -e "Bitte beachte, dass du das Passwort für den Serveradmin selbst gewählt hast und es hier nicht erneut ausgegeben wird. Solltest du dein Passwort ändern wollen, so nutze dafür die bekannten wege.\n"

exit 0
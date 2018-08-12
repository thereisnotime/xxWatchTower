# xxWatchTower

### Description ###
Linux SSH and TTY monitoring &amp; alerting tool. It sends email each time somebody uses SSH or TTY connection. Uses Pluggable Authentication Modules (PAM) rules to detect common-session and sudo events, after that sends all the information (user IP, date, process, type of connection etc.) via sendemail to a specified email address.

### Installation ###
* WARNING: The current public version of the script installs the PAM rules in /etc/pam.d/common-session and /etc/pam.d/sudo. It should not create any problems, but if it does - please open an issue here.

Easy oneliner for installation with wget:
```sh
wget https://github.com/thereisnotime/xxWatchTower/raw/master/xxWatchTower.sh -O /tmp/xxWatchTower.sh && chmod +x /tmp/xxWatchTower.sh && /tmp/xxWatchTower.sh && rm /tmp/xxWatchTower.sh
``` 

Easy oneliner for installation with curl:
```sh
curl -L https://github.com/thereisnotime/xxWatchTower/raw/master/xxWatchTower.sh | sh
``` 

### Dependencies ###
Currently the script depends only on the package manager and few internals, which get installed with the script:
```sh
sendemail
````

### Compatability ###
The should work on most Linus distributions and has been tested on the following:
```sh
Debian 7 x64
Debian 7 x86
Debian 8 x64
Debian 8 x86
Debian 9 x64
``` 

### Automation ###
The script can be configured manually or by passing exactly 6 arguments to it:
```sh
./xxWatchTower.sh SCRIPTFILENAME EMAILFROM EMAILTO SMTPSERVER SMTPUSERNAME SMTPPASSWORD
```
Or download + install + configure oneliner:
```sh
wget https://github.com/thereisnotime/xxWatchTower/raw/master/xxWatchTower.sh -O /tmp/xxWatchTower.sh && chmod +x /tmp/xxWatchTower.sh && /tmp/xxWatchTower.sh SCRIPTFILENAME EMAILFROM EMAILTO SMTPSERVER SMTPUSERNAME SMTPPASSWORD && rm /tmp/xxWatchTower.sh
```
SCRIPTFILENAME - the full location where you want the script to be installed.
EMAILFROM - best to use the SMTPUSERNAME one to avoid spam filtering.
EMAILTO - the email which will receive the notifications.
SMTPSERVER - for sending the notifications.
SMTPUSERNAME - for authorization.
SMTPPASSWORD - for authorization.
* Note: Do not forget to use the right quotes if your input has special symbols.

### Uninstall ###
To remove xxWatchTower use the following commands:
```sh
tmp=$(cat "/etc/pam.d/sudo")
tmp2=$(echo $tmp | grep -o -P '(?<=pam_exec.so ).*(?=#ENDXXWATCHTOWER)')
SCRIPTFILENAME=$tmp2
declare -a FILEARRAY=("/etc/pam.d/common-session" "/etc/pam.d/sudo")
for CURRENTFILE in "${FILEARRAY[@]}"
do
    if grep -q "#XXWATCHTOWER" "$CURRENTFILE"; then
        echo "Rule detected in: $CURRENTFILE"
        sed -i '/#XXWATCHTOWER/,/#ENDXXWATCHTOWER/g' "$CURRENTFILE"
        sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' "$CURRENTFILE"
        echo "Removed rule from $CURRENTFILE."
    fi
done
if [ -f "$SCRIPTFILENAME" ] ; then
    echo "Deleting script at: $SCRIPTFILENAME"
    rm "$SCRIPTFILENAME"
fi
echo "Done."

```

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

### Uninstall ###
To remove xxWatchTower from all shells use:
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

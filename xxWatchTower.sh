#!/bin/bash
# HEREDOC string containing the aliases
# xxWatchTower
# Oneliner:
# bash <(curl -s https://raw.githubusercontent.com/thereisnotime/xxWatchTower/master/xxWatchTower.sh)
################################
#### Install dependencies
apt-get install -y sendemail
#### Input
if [ "$#" -eq 6 ]; then
    SCRIPTFILENAME="$1"
    EMAILFROM="$2"
    EMAILTO="$3"
    SMTPSERVER="$4"
    SMTPUSERNAME="$5"
    SMTPPASSWORD="$6"
fi
if [ "$#" -eq 0 ]; then
    read -p "Install script in (default: /root/.xxwatchtower): " SCRIPTFILENAME
    SCRIPTFILENAME=${SCRIPTFILENAME:-/root/.xxwatchtower}
    read -p "Email was sent from (example: agent01@example.com): " EMAILFROM
    EMAILFROM=${EMAILFROM:-EMAILFROMPLACEHOLDER}
    read -p "Email receiver (example: monitoring@example.com): " EMAILTO
    EMAILTO=${EMAILTO:-EMAILTOPLACEHOLDER}
    read -p "SMTP Server for emails (example: mail.cock.li): " SMTPSERVER
    SMTPSERVER=${SMTPSERVER:-SMTPSERVERPLACEHOLDER}
    read -p "SMTP Username (example: agent01@example.com): " SMTPUSERNAME
    SMTPUSERNAME=${SMTPUSERNAME:-SMTPUSERNAMEPLACEHOLDER}
    read -p "SMTP Password: " SMTPPASSWORD
    SMTPPASSWORD=${SMTPPASSWORD:-SMTPPASSWORDPLACEHOLDER}
fi
if [ "$#" != 0 ] && [ "$#" != 6 ]; then
    echo "Invalid arguments ($#). Use all 6 or do not use arguments at all."
    exit 0
fi
#### Variables
declare -a FILEARRAY=("/etc/pam.d/common-session" "/etc/pam.d/sudo")
PAMRULE=$(cat <<'END_HEREDOC'
#XXWATCHTOWER
session    optional     pam_exec.so SCRIPTFILENAMEPLACEHOLDER
#ENDXXWATCHTOWER
END_HEREDOC
)
SCRIPTBASE=$(cat <<'END_HEREDOC'
#!/bin/sh
#XXWATCHTOWER
##################
# xxWatchTower
# v1.2
##################
#### Configuration
EMAILFROM="EMAILFROMPLACEHOLDER"
EMAILTO="EMAILTOPLACEHOLDER"
SMTPSERVER="SMTPSERVERPLACEHOLDER"
SMTPUSERNAME="SMTPUSERNAMEPLACEHOLDER"
SMTPPASSWORD='SMTPPASSWORDPLACEHOLDER'
[ "$PAM_TYPE" = "open_session" ] || exit 0
#### Send email
sendemail -f $EMAILFROM -t $EMAILTO -u "[New SSH/TTY Login]: $PAM_USER@`hostname`" -s $SMTPSERVER -m "Host: `hostname`\nUser: $PAM_USER\nRuser: $PAM_RUSER\nRhost: $PAM_RHOST\nService: $PAM_SERVICE\nType: $PAM_TTY\nTimestmap: `date +%s`\nDate: `date`\nServer: `uname -a`\nLogins: `w`" -v -o message-charset="utf-8" -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -q >/dev/null 2>/dev/null &
#ENDXXWATCHTOWER
END_HEREDOC
)

#### PAM Rule
for CURRENTFILE in "${FILEARRAY[@]}"
do
    if [ ! -f "$CURRENTFILE" ]; then touch "$CURRENTFILE"; fi
    if grep -q "#XXWATCHTOWER" "$CURRENTFILE"; then
        # Remove old rule
        echo "Old rule detected in: $CURRENTFILE"
        sed -i '/#XXWATCHTOWER/,/#ENDXXWATCHTOWER/g' "$CURRENTFILE"
        # Remove trailing lines
        sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' "$CURRENTFILE"
        echo "Removed old rule from $CURRENTFILE."
    fi
    # Write new xxWatchTower rule to file.
    echo "Adding PAM rule to $CURRENTFILE."
    echo "$PAMRULE" >> "$CURRENTFILE"
    sed -i "s|SCRIPTFILENAMEPLACEHOLDER|$SCRIPTFILENAME|g" "$CURRENTFILE"
done
#### Main script
if [ -f "$SCRIPTFILENAME" ] ; then
    echo "Deleting old version from: $SCRIPTFILENAME"
    rm "$SCRIPTFILENAME"
fi
#### Write new xxWatchTower script to file.
echo "Installing script in $SCRIPTFILENAME."
echo "$SCRIPTBASE" >> "$SCRIPTFILENAME"
echo "Configuring the script..."
sed -i "s|EMAILFROMPLACEHOLDER|$EMAILFROM|g" "$SCRIPTFILENAME"
sed -i "s|EMAILTOPLACEHOLDER|$EMAILTO|g" "$SCRIPTFILENAME"
sed -i "s|SMTPSERVERPLACEHOLDER|$SMTPSERVER|g" "$SCRIPTFILENAME"
sed -i "s|SMTPUSERNAMEPLACEHOLDER|$SMTPUSERNAME|g" "$SCRIPTFILENAME"
sed -i "s|SMTPPASSWORDPLACEHOLDER|$SMTPPASSWORD|g" "$SCRIPTFILENAME"
chmod +x "$SCRIPTFILENAME"
echo "Done."
unset SCRIPTBASE CURRENTFILE SCRIPTFILENAME PAMRULE FILEARRAY
exit 0
# END OF FILE

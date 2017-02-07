#!/bin/bash

#    Change the root password for various services
#	 Copyright (C) 2017 @maldevel
#    https://github.com/maldevel/misc
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#   
#    For more see the file 'LICENSE' for copying permission.


# Supported services: system, mysql, postgresql, gitlab, glpi, owncloud, wordpress

function usage
{
    echo "usage: change-root-password [-h] -s service [-u username] [-d database] [-b username] [--occ filepath]"
    echo ""
    echo "arguments:"
    echo "-h, --help                          show this help message and exit"
    echo "-s service, --service service"
    echo "                                    select a service to change root/admin password (mysql, system, postgresql, gitlab, glpi, owncloud, wordpress)"
    echo "-u username, --username username    service administrator's username."
    echo "-d database, --database database    database name to make sql queries."
    echo "-b username, --dbuser username      database user to make sql queries."
    echo "--occ filepath                      location of occ tool"
    echo ""
}

# if no arguments print usage and exit
if [ $# -eq 0 ]; then
    usage
    exit 1
fi


while [ "$1" != "" ]; do
    case $1 in
        -s | --service )        shift
                                if [ "$1" == "" ]; then echo -e "Please select a service.\n"; usage; exit 1; fi
                                SERVICE=$1 
                                ;;
        -u | --username )       shift
                                SRVUSER=$1
                                ;;
        -d | --database )       shift
                                DATABASE=$1
                                ;;
        -b | --dbuser )         shift
                                DBUSER=$1
                                ;;
        --occ )                 shift
                                OWNCLOUDOCC=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )
                                echo "ERROR: unknown option \"$1\""
                                usage
                                exit 1
    esac
    shift
done

if [ "$SERVICE" == "mysql" ]; then
    # change password for mysql root user

    command -v mysqladmin >/dev/null 2>&1 || { echo >&2 "mysqladmin is required but it's not installed. Aborting."; echo ""; exit 1; }

    if [ "$SRVUSER" == "" ]; then
      SRVUSER="root"
    fi

    echo "[+] Updating user $SRVUSER password on mysql server.."
    printf "MySQL: "
    mysqladmin -u $SRVUSER -p password
    echo "[+] Done"
 
elif [ "$SERVICE" == "system" ]; then
    # change password for system root user

    if [ "$SRVUSER" == "" ]; then
      SRVUSER="root"
    fi

    echo "[+] Updating system user $SRVUSER password.."
    passwd $SRVUSER 
    echo "[+] Done"

elif [ "$SERVICE" == "postgresql" ]; then
    #change password for postgresql root user (postgres)

    command -v psql >/dev/null 2>&1 || { echo >&2 "psql is required but it's not installed. Aborting."; echo ""; exit 1; }

    stty -echo
    printf "New password: "
    read PASSWORD
    printf "\nConfirm new password: "
    read CONFIRM_PASSWORD
    stty echo
    printf "\n"

    if [ "$PASSWORD" != "$CONFIRM_PASSWORD" ]; then
      echo "Passwords do not match"
      echo ""
      exit 1
    fi

    if [ "$SRVUSER" == "" ]; then
      SRVUSER="postgres"
    fi

    if [ "$DATABASE" == "" ]; then
      DATABASE="postgres"
    fi

    echo "[+] Updating user $SRVUSER password on postgresql server(database: $DATABASE).."
    sudo -u $SRVUSER psql -U $SRVUSER -h 127.0.0.1 -d $DATABASE -c "ALTER USER postgres WITH PASSWORD '$PASSWORD';"
    echo "[+] Done"

elif [ "$SERVICE" == "gitlab" ]; then
    #change password for gitlab root user

    command -v gitlab-rails >/dev/null 2>&1 || { echo >&2 "gitlab-rails is required but it's not installed. Aborting."; echo ""; exit 1; }

    stty -echo
    printf "New password: "
    read PASSWORD
    printf "\nConfirm new password: "
    read CONFIRM_PASSWORD
    stty echo
    printf "\n"

    if [ "$PASSWORD" != "$CONFIRM_PASSWORD" ]; then
      echo "Passwords do not match"
      echo ""
      exit 1
    fi

    echo "[+] Updating administrator's account password on gitlab server.."
    gitlab-rails console production <<EOF
    user = User.where(id: 1).first
    user.password = '$PASSWORD'
    user.password_confirmation = '$PASSWORD'
    user.password_expires_at = nil
    user.save!
    exit
EOF
    echo "[+] Done"

elif [ "$SERVICE" == "glpi" ]; then
    #change password for glpi(default glpi) administrator

    command -v mysql >/dev/null 2>&1 || { echo >&2 "mysql is required but it's not installed. Aborting."; echo ""; exit 1; }
    command -v php >/dev/null 2>&1 || { echo >&2 "php is required but it's not installed. Aborting."; echo ""; exit 1; }

    if [ "$DATABASE" == "" ]; then
      echo "Please provide the database name."
      echo ""
      exit 1
    fi

    stty -echo
    printf "New password: "
    read PASSWORD
    printf "\nConfirm new password: "
    read CONFIRM_PASSWORD
    stty echo
    printf "\n"

    if [ "$PASSWORD" != "$CONFIRM_PASSWORD" ]; then
      echo "Passwords do not match"
      echo ""
      exit 1
    fi    

    if [ "$SRVUSER" == "" ]; then
      SRVUSER="glpi"
    fi
        
    if [ "$DBUSER" == "" ]; then
      DBUSER="root"
    fi

    echo "[+] Updating user $SRVUSER password on glpi server(database: $DATABASE).."
    printf "MySQL: "
    mysql -u $DBUSER -p -D $DATABASE -e "update glpi_users set password='`php -r "echo password_hash('$PASSWORD', PASSWORD_DEFAULT);"`' where name='$SRVUSER';"
    echo "[+] Done"

elif [ "$SERVICE" == "owncloud" ]; then
    #change password for owncloud administrator

    if [ "$SRVUSER" == ""  ] || [ "$OWNCLOUDOCC" == "" ]; then
      echo "Please provide the owncloud administrator's username and the file path to the occ tool."
      echo ""
      exit 1
    fi

    command -v $OWNCLOUDOCC >/dev/null 2>&1 || { echo >&2 "$OWNCLOUDOCC is required but it's not installed. Aborting."; echo ""; exit 1; }

    echo "[+] Updating user $SRVUSER password on owncloud server.."    
    sudo -u www-data php $OWNCLOUDOCC user:resetpassword $SRVUSER
    echo "[+] Done"

elif [ "$SERVICE" == "wordpress" ]; then
    #change password for wordpress administrator
    
    command -v mysql >/dev/null 2>&1 || { echo >&2 "mysql is required but it's not installed. Aborting."; echo ""; exit 1; }

    if [ "$DATABASE" == "" ]; then
      echo "Please provide the database name."
      echo ""
      exit 1
    fi

    stty -echo
    printf "New password: "
    read PASSWORD
    printf "\nConfirm new password: "
    read CONFIRM_PASSWORD
    stty echo
    printf "\n"

    if [ "$PASSWORD" != "$CONFIRM_PASSWORD" ]; then
      echo "Passwords do not match"
      echo ""
      exit 1
    fi

    if [ "$DBUSER" == "" ]; then
      DBUSER="root"
    fi

    echo "[+] Updating administrator's account password on wordpress(database: $DATABASE).."
    printf "MySQL: "
    mysql -u $DBUSER -p -D $DATABASE -e "UPDATE wp_users SET user_pass=MD5('$PASSWORD') WHERE ID=1 LIMIT 1;"
    echo "[+] Done"

fi


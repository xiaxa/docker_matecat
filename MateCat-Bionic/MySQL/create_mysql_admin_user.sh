#!/bin/bash

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" # > /dev/null 2>&1
    RET=$?
done

ADM_ACCOUNT=`mysql -uroot -e "SELECT * FROM mysql.user WHERE User = 'admin'"`
if [[ ! -z "${ADM_ACCOUNT}" ]]; then
    return 0
fi

#PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
PASS=${MYSQL_PASS}
_word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
echo "=> Creating MySQL admin user with ${_word} password"

mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"
mysql -uroot -e "FLUSH PRIVILEGES"

echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
echo "    mysql -uadmin -p$PASS -h<host> -P<port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "MySQL user 'root' has no password but only allows local connections"
echo "========================================================================"

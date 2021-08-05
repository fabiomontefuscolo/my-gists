#!/bin/bash

# Max size of dump folder (in Mb)
MAX_SIZE=10000

# PHP executable
PHP=/usr/bin/php

# mysqldump executable
MYSQLDUMP=/bin/mysqldump

SELF=$0
tiki_folder=$1
dump_folder=$2

#
# Script functions
#

print_usage ()
{
    echo "Usage:"
    echo "> ${SELF}" '${TIKI_FOLDER}' '${DUMP_FOLDER}'
}

get_backup_size () {
    /bin/du -ms "${dump_folder}" | /bin/cut -f 1
}


#
# preliminary checkings
#

if [ ! -f "${tiki_folder}/db/local.php" ];
then
    echo "The path ${tiki_folder} does not seem to be a tiki folder"
    print_usage
    exit 1;
fi


if [ ! -d "${dump_folder}" ] || [ ! -w "${dump_folder}" ];
then
    echo "The path ${dump_folder} is not a folder or is not writeable"
    print_usage
    exit 1;
fi


#
# Gather Tiki info
#
db_host=""
db_user=""
db_pass=""
db_name=""

eval $($PHP <<EOF
<?php
    include "${tiki_folder}/db/local.php";
    echo 'export db_host=' . escapeshellarg(\$host_tiki) . PHP_EOL;
    echo 'export db_user=' . escapeshellarg(\$user_tiki) . PHP_EOL;
    echo 'export db_pass=' . escapeshellarg(\$pass_tiki) . PHP_EOL;
    echo 'export db_name=' . escapeshellarg(\$dbs_tiki ) . PHP_EOL;
EOF
)

if [ -z "$db_host" ] || [ -z "$db_user" ] || [ -z "$db_pass" ] || [ -z "$db_name" ];
then
    echo "Can't detect database credentials at '${tiki_folder}/db/local.php'"
    exit 1;
fi


cd "${dump_folder}"

#
# Remove old backups
#
while [ -d "${dump_folder}" ] && [ "$(get_backup_size)" -gt "${MAX_SIZE}" ];
do
    ls -1t                                            \
        | grep -E "${db_name}-202[0-9]{5,5}\.sql\.gz" \
        | tail -n1                                    \
        | xargs rm -fv
    sleep 2
done

dump_name="${db_name}-$(date +'%Y%m%d').sql.gz"
$MYSQLDUMP                         \
        --single-transaction       \
        --master-data              \
        --max-allowed-packet=256M  \
        -h"${db_host}"             \
        -u"${db_user}"             \
        -p"${db_pass}"             \
        "${db_name}"               \
    | gzip                         \
    > "${dump_name}"

ln -sf "${dump_name}" "latest.sql.gz"

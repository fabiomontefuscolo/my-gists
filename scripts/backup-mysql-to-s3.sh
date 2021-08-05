#!/bin/bash
S3CMD='/opt/s3cmd/bin/s3cmd'
BUCKET='bucketname'
PREFIX='/any-placeholder'

BACKUP_FOLDER=/var/backup/mysql
BACKUP_FILE_NAME="`date +%Y%m%d`-%s.sql"
BACKUP_EXPIRY_DAYS=180

MYSQL_USR='root'
MYSQL_PWD='*******'
MYSQL_ARG="-u$MYSQL_USR -p$MYSQL_PWD"

COMPRESS="`which xz` -fv"
MYSQL_CMD="`which mysql` $MYSQL_ARG"
MYSQL_DMP="`which mysqldump` --single-transaction $MYSQL_ARG"

DATABASES=$(
    $MYSQL_CMD -N -s -e 'show databases' | grep -Ev '(information|performance|mysql)'
)

while read database;
do
    file_name=$(printf "${BACKUP_FILE_NAME}" "${database}");
    file_path="${BACKUP_FOLDER%%/}/${file_name}"
    $MYSQL_DMP "$database" > "$file_path"
    $COMPRESS "$file_path"
    rm -f "$file_path"

done <<< "$DATABASES"


$S3CMD sync                    \
    --exclude="*/.git/*"       \
    "${BACKUP_FOLDER%%/}/"     \
    "s3://${BUCKET}${PREFIX}${BACKUP_FOLDER%%/}/"


find "${BACKUP_FOLDER%%/}/" -type f -mtime +$BACKUP_EXPIRY_DAYS  \
| while read file_path;
do
    $S3CMD del "s3://${BUCKET}${PREFIX}${file_path}"
    rm "${file_path}"
done

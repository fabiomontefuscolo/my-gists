#!/bin/bash

tiki_name=''
tiki_path=''
bckp_path=''

db_user=''
db_pass=''
db_name=''
db_host=''

while getopts ":i:b:n:" o; 
do
    case "${o}" in
        i)
            tiki_path=$(readlink -f ${OPTARG})
            ;;
        b)
            bckp_path=$(readlink -f ${OPTARG})
            ;;
        n)
            tiki_name=${OPTARG}
            ;;
    esac
done

log_out () {
    echo "[$(date +'%Y-%m-%d %T %z')] " $*
}

log_err () {
    log_out $* >&2
}


if [[ -z "${bckp_path}" ]] || [[ -z "${tiki_path}" ]];
then
    log_err "-i and/or -p parameters missing"
    exit
fi

if [[ ! -f "${tiki_path}/db/local.php" ]];
then
    log_err "Invalid tiki instance: '${tiki_path}'"
    exit
fi

if [[ -z "${tiki_name}" ]];
then
    tiki_name=$(basename "${tiki_path}")
fi

if [[ ! -d "${bckp_path}" ]];
then
    mkdir -p "${bckp_path}"
fi

bckp_file="${bckp_path}/${tiki_name}.tar"
dump_path="$(dirname ${tiki_path})/dump.sql"

eval $(php <<EOF
<?php
    include("${tiki_path}/db/local.php");
    echo 'export db_host="' . "\$host_tiki" . '"' . PHP_EOL;
    echo 'export db_user="' . "\$user_tiki" . '"' . PHP_EOL;
    echo 'export db_pass="' . "\$pass_tiki" . '"' . PHP_EOL;
    echo 'export db_name="' . "\$dbs_tiki" .  '"' . PHP_EOL;
EOF
)

mysqldump                \
    -u"${db_user}"       \
    -p"${db_pass}"       \
    -h"${db_host}"       \
    --single-transaction \
    "${db_name}"         \
    > "${dump_path}"


target_paths=()
target_paths+=("${tiki_path}")
target_paths+=("${dump_path}")

while read datadir;
do
    if [[ -n "${datadir}" ]] && [[ -d ""${datadir}"" ]];
    then
        target_paths+=("${datadir}")
    fi
done < <(
    mysql -u"${db_user}" -p"${db_pass}" -h"${db_host}" "${db_name}" -N -s <<'EOF'
        SELECT value FROM tiki_preferences WHERE name LIKE '%_use_dir';
EOF
)

tar -cjvf "${bckp_file}.bz2" ${target_paths[@]}
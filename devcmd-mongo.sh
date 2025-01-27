#!/bin/bash
mongo_host="devcmd-mongo"
mongo_image="docker.io/bitnami/mongodb:5.0.10-debian-11-r3"

start_mongo_container() {
    kubectl run --namespace fab devcmd-mongo-client --rm --tty -i --restart='Never' --image "$mongo_image" --command -- $*
}

start_mongo_shell() {
    # params: dbname user pwd
    db="$1"
    db_user="$2"
    db_pwd="$3"
    start_mongo_container mongosh $db --host $mongo_host --authenticationDatabase $db -u $db_user -p $db_pwd
}

get_mongo_password() {
    data_path="$1"
    kubectl get secret --namespace fab devcmd-mongo -o jsonpath="{.data.$data_path}" | base64 --decode
}

case $1 in
    root)
        export db_pwd=$(get_mongo_password mongodb-root-password)
        start_mongo_shell admin "$1" "$db_pwd" "$2"
        ;;
    shell)
        start_mongo_container bash
        ;;
    *)
        db_user="fabuser"
        if [ "$1" != "" ]; then db_user="$1"; fi
        export db_pwd=$(get_mongo_password mongodb-passwords)
        if [ -z "$db_pwd" ]; then
            export db_pwd=$(get_mongo_password mongodb-password)
        fi
        start_mongo_shell fab "$db_user" "$db_pwd"
    ;;
esac


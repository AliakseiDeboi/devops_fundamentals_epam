#!/bin/bash

dbName=users.db
dbDir=../data/
dbPath="${dbDir}${dbName}"
backupDir="${dbDir}backups/"
noBackupMessage="No backup file."

checkDb() {
    if [ ! -f $dbPath ]
    then 
        echo "No DB is created. Create datadase? :"
        select yn in "Yes" "No"; do
            case $yn in
                Yes) checkDir $dbDir 0; touch $dbPath; break;;
                No) exit;;
            esac
        done
    fi
}

add() {
    checkDb
    while true
    do
        read -p "Username: " username
        validation $username "Name"
        if [[ $? == 0 ]]; then break; fi
    done

    while true
    do
        read -p  "${username} role: " role
        validation $role "Role"
        if [[ $? == 0  ]]; then break; fi
    done
    echo "${username}, ${role}" >> $dbPath 
    echo "User ${username} with role ${role} has been added."    
}

checkDir() {
    if [ ! -d $1 ]
    then 
        if [ $2 ]
        then mkdir $1
        else echo $noBackupMessage; exit
        fi
    fi
}

backup() {
    checkDb
    checkDir $backupDir 0
    cat $dbPath > "${backupDir}%$(date +%F)%-${dbName}.backup"
    echo "Database backup has been created $(date +%F)"
}

restore() {
    checkDb
    checkDir $backupDir
    latest=$(ls $backupDir -At | head -1)
    if [ latest ]
    then
        cat $backupDir$latest > $dbPath
        echo "Database was restored with ${latest}"
    else echo $noBackupMessage
    fi
}

list() {
    checkDb
    if [[ $1 == --inverse ]]
    then cat -n $dbPath | tac
    else cat -n $dbPath
    fi
}

find(){
    read -p "Username: "  searchTerm
    result=$(grep -i -n -w  "${searchTerm}," $dbPath)
    if [[ -z $result ]]
    then
        echo "User is not exists. Check spelling."
    else 
        echo $result
    fi
}


validation() {
    if [[ $1 =~ ^[A-Za-z_]+$ ]]
    then return 0;
    else 
        echo "$2 musst containt only latin letters."
        return 1;
    fi
}
    
help() {
    echo
    echo "Syntax: db.sh [command] [optional param]"
    echo
    echo "List of commands:"
    echo 
    echo "add"
    echo "Add user with a specific role in database. Only latin letters are supported." 
	echo 
	echo "find"
    echo "Find user by provided username"
    echo
    echo "backup"
    echo "Create the backup for DB"
    echo
    echo "restore"
    echo "Restore database with the backup"
    echo
    echo "list [--reverse]"
    echo "Show database content." 
}

case $1 in
    add) add;;
    backup) backup;;
    restore) restore;;
    find) find;;
    list) list $2;;
    help | '' | *)  help;;
esac
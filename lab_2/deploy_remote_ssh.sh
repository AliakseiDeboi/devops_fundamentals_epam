#!/bin/bash

red=$'\e[1;31m'
grn=$'\e[1;32m'
#yel=$'\e[1;33m'
blu=$'\e[1;34m'
#mag=$'\e[1;35m'
#cyn=$'\e[1;36m'
end=$'\e[0m'

COURSE_DIR=$HOME/learn_stuff/devops

BACKEND_HOST_DIR=$COURSE_DIR/nestjs-rest-api

BACKEND_HOST_BUILD_DIR=$BACKEND_HOST_DIR/dist

FRONTEND_HOST_DIR=$COURSE_DIR/shop-react-redux-cloudfront

FRONTEND_HOST_BUILD_DIR=$FRONTEND_HOST_DIR/build

WEBSERVER_HOST_DIR=/usr/local/etc/nginx/servers

WEBSERVER_HOST_CONFIG=$WEBSERVER_HOST_DIR/react-shop.local.conf

CA_CERT_NAME=react.server

BACKEND_REMOTE_DIR=/var/app/BACKEND_app

FRONTEND_REMOTE_DIR=/var/www/FRONTEND_app

WEBSERVER_REMOTE_DIR=/etc/nginx/sites-available

WEBSERVER_REMOTE_CONFIG=react-shop.local.conf

SSH_ALIAS=ubuntu

buildApp() {
	rm -Rf $3;
	cd $2 && $4
}

checkDirExists() {
	if [[ -z $1 ]] || $1 == "/"; then
		echo "${FUNCNAME[0]}: Provide argument"
		exit;
	fi

	if ssh ubuntu "[ ! -d $1 ]"; then
		echo "Creating: $1"
		ssh -t $SSH_ALIAS "sudo bash -c 'mkdir -p $1 && chown -R sshuser: $1'"
	else
		echo "Clearing: $1"
		ssh $SSH_ALIAS "sudo -S rm -r $1/*"
	fi
}

copyFrontendBuild() {
	scp -Crq $FRONTEND_HOST_BUILD_DIR/* $SSH_ALIAS:$FRONTEND_REMOTE_DIR
}

copyBackendBuild() {
	rsync -a -e ssh --exclude="node_modules" $BACKEND_HOST_DIR/* $SSH_ALIAS:$BACKEND_REMOTE_DIR
	ssh -t $SSH_ALIAS "cd $BACKEND_REMOTE_DIR && yarn && yarn build"
}

copyConfigs() {
	ssh -t $SSH_ALIAS "cp -f $WEBSERVER_REMOTE_DIR/$WEBSERVER_REMOTE_CONFIG $WEBSERVER_REMOTE_DIR/$WEBSERVER_REMOTE_CONFIG.backup"
        scp -Cr $WEBSERVER_HOST_CONFIG $SSH_ALIAS:$WEBSERVER_REMOTE_DIR/$WEBSERVER_REMOTE_CONFIG	
	scp -Cr $WEBSERVER_HOST_DIR/$CA_CERT_NAME* $SSH_ALIAS:$WEBSERVER_REMOTE_DIR
}

checkDirExists $BACKEND_REMOTE_DIR
checkDirExists $FRONTEND_REMOTE_DIR
buildApp BACKEND $BACKEND_HOST_DIR $BACKEND_HOST_BUILD_DIR 'yarn build'
buildApp FRONTEND $FRONTEND_HOST_DIR $FRONTEND_HOST_BUILD_DIR 'yarn build'
copyFrontendBuild
copyBackendBuild
copyConfigs
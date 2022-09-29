#!/bin/bash

parent=../shop-angular-cloudfront
static=dist
output=$parent/$static
ENV_CONFIGURATION=


while true
do
    case $1 in
        -c | -configuration) ENV_CONFIGURATION=$2; shift 2;;
        *) break;;
    esac
done

if [ -d $output ] 
then rm -r $output
fi

mkdir $output

cd $parent && npm i && npm run build -- --configuration=$ENV_CONFIGURATION --output-path=$static

zip -r $output/client-app $output  
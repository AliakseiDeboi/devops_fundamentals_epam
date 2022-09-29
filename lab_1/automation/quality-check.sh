#!/bin/bash

parent=../shop-angular-cloudfront

cd $parent && npm run lint && npm run e2e && npm audit
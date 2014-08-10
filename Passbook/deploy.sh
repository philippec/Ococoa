#!/bin/sh

# Sign pass
./signpass -p Ococoa.raw -o ../server/ococoa-push/Ococoa.pkpass

# Update website
if [ -z `which appcfg.py` ]; then
    echo "appcfg.py does not exist, cannot deploy"
    exit 1
fi
appcfg.py update ../server/ococoa-push/

sleep 2

# Get all tokens
# curl https://ococoa-push.appspot.com/passbook/v1/tokens

# Get all tokens but only push for my phone
# curl https://ococoa-push.appspot.com/passbook/v1/tokens | grep b102 | xargs ./simplepush.php

# Get all tokens and push for all
curl https://ococoa-push.appspot.com/passbook/v1/tokens | xargs ./simplepush.php

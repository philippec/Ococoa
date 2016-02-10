#!/bin/sh

# Check pass for basic JSON validity

echo "Checking pass.json for validity..."
cat Ococoa.raw/pass.json | python -mjson.tool > /dev/null
if [ $? -eq 0 ]; then
    echo "pass.json seems valid"
else
    echo "pass.json is invalid, cannot deploy"
    exit 1
fi

# Sign pass
./signpass -p Ococoa.raw -o ../server/ococoa-push/Ococoa.pkpass

# Update website
if [ -z `which appcfg.py` ]; then
    echo "appcfg.py does not exist, cannot deploy"
    exit 1
fi
appcfg.py update ../server/ococoa-push/

sleep 2

# Get all tokens and push for all
curl https://ococoa-push.appspot.com/passbook/v1/tokens | awk '/"/{print "./simplepush.php "$1" && sleep 0.1"}' > push.sh
sh push.sh
rm push.sh

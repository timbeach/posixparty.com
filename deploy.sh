#!/bin/sh
rsync -vhrla --exclude .claude/ --exclude .well-known/ --exclude .git/ --exclude archive/ $PWD/ vultr:/var/www/posixparty.com

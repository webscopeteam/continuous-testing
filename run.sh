#!/bin/bash

# Remove xdebug
rm -f /home/rof/.phpenv/versions/$(phpenv version-name)/etc/conf.d/xdebug.ini
# Use our composer
mv composer.json ~/.config/composer/composer.json
composer global update
# Terminus Authentication
terminus auth login $PANTHEON_ROBOT --password=$ROBOT_PASSWORD

# Identify the automation user
_CI_BOT_EMAIL="user@codeship.io"
_CI_BOT_NAME="codeship ci"
_CI_COMMIT_MSG=$CI_MESSAGE

# Use the 'master' branch for the dev environment; for multidev,
# use the branch with the same name as the multidev environment name.

# Set PANTHEON_SITE from environment variable or argument
if [ -z "$PANTHEON_SITE" ]
then
  PANTHEON_SITE=$1
fi

# Set PENV (Pantheon environment) from argument , develop otherwise
if [ -z "$2" ]
then
  PENV="develop"
else
  PENV=$2
fi

# Set BRANCH from argument if set, PENV otherwise
if [ -z "$3" ]
then
  BRANCH="$PENV"
else
  BRANCH="$3"
fi

# Check to see if Pantheon site $PANTHEON_SITE exists
PUUID=$(terminus site info --site="$PANTHEON_SITE" --field=id 2>/dev/null)
if [ -z "$PUUID" ]
then
  echo "Could not get UUID for $PANTHEON_SITE"
  exit 1
fi
PUUID=$(echo $PUUID | sed -e 's/^[^:]*: *//')
echo "UUID for $PANTHEON_SITE is $PUUID"
echo "Wake up the site $PANTHEON_SITE"
terminus site wake --site="$PANTHEON_SITE" --env="$PENV"

# Clone pantheon repo
REPO="ssh://codeserver.dev.$PUUID@codeserver.dev.$PUUID.drush.in:2222/~/repository.git"
sshpass -p $ROBOT_PASSWORD git clone --depth 1 --branch "$BRANCH" "$REPO" pantheon_repo

# Move settings.php
mv settings.codeship.php pantheon_repo/sites/default

# Move into site.
cd pantheon_repo

# Trigger a new backup
terminus site backups create --site=$PANTHEON_SITE --env=$PENV --element=db

# Get Pantheon DB
terminus site backups get --site=$PANTHEON_SITE --env=$PENV --element=database --to=panthbackup.sql.gz --latest
# Decompress DB
echo "Decompressing DB"
gunzip panthbackup.sql.gz -v

# Upload DB
drush sqlc < panthbackup.sql
# Sanitize database
drush sqlsan --sanitize-email="build+%uid@test.co.nz" -y
# Update database
drush updb -y
# Configuration import
drush cim -y
# Flush cache
drush cr

# Start PHP server
nohup bash -c "php -S 127.0.0.1:8000 2>&1 &" && sleep 1;

# Install and run selenium
#\curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/packages/selenium_server.sh | bash -s
SELENIUM_VERSION=${SELENIUM_VERSION:="2.46.0"}
SELENIUM_PORT=${SELENIUM_PORT:="4444"}
SELENIUM_OPTIONS=${SELENIUM_OPTIONS:=""}
SELENIUM_WAIT_TIME=${SELENIUM_WAIT_TIME:="10"}
set -e
MINOR_VERSION=${SELENIUM_VERSION%.*}
CACHED_DOWNLOAD="${HOME}/cache/selenium-server-standalone-${SELENIUM_VERSION}.jar"
wget --continue --output-document "${CACHED_DOWNLOAD}" "http://selenium-release.storage.googleapis.com/${MINOR_VERSION}/selenium-server-standalone-${SELENIUM_VERSION}.jar"
nohup bash -c "java -jar ${CACHED_DOWNLOAD} -port ${SELENIUM_PORT} ${SELENIUM_OPTIONS} 2>&1 &" && sleep ${SELENIUM_WAIT_TIME};

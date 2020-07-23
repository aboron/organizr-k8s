#!/bin/bash
cp -Rn /config-clean/* /config/
mkdir /opt/organizr/html
mkdir /opt/organizr/db
cp -Rn /opt/organizr-clean/* /opt/organizr/html
chown -R www-data:www-data /opt/organizr
chmod -R 775 /opt/organizr
chown -R www-data:www-data /config

# Start php-fpm
/usr/sbin/php-fpm7.4 --fpm-config /etc/php/7.4/fpm/php-fpm.conf -D
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start php-fpm: $status"
  exit $status
fi
# Start nginx
/usr/sbin/nginx
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start nginx: $status"
  exit $status
fi

# Naive check runs checks once a minute to see if either of the processes exited.
# The container exits with an error if it detects that either of the processes has exited.
# Otherwise it loops forever, waking up every 60 seconds

while sleep 60; do
  ps aux |grep nginx |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep php-fpm |grep -q -v grep
  PROCESS_2_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done
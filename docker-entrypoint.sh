#!/bin/bash

# Check if process has DAC_READ_SEARCH
getpcaps 1 2>&1 | grep -q cap_dac_read_search
if [ $? -ne 0 ]; then
  echo "E: cap_dac_read_search not possible, are you running the container with the DAC_READ_SEARCH capability?"
  exit 1
fi

# Set time zone
if [ -n "$TZ" ]; then
  echo "$TZ" > /etc/timezone
  echo "I: Set timezone to $TZ."
fi

# Set unifi-video's UID
if [ -n "$PUID" ]; then
  echo "I: Setting unifi-video UID to $PUID"
  usermod -o -u "${PUID}" unifi-video &>/dev/null
  if [ $? -ne 0 ]; then
    echo "E: Unable to set UID of the unifi-video user to $PUID"
    exit 1
  else
    echo "I: Successfully set unifi-video UID to $PUID"
  fi
fi


# Set unifi-video's GID
if [ -n "$PGID" ]; then
  echo "I: Setting unifi-video GID to $PGID"
  groupmod -o -g "${PGID}" unifi-video &>/dev/null
  if [ $? -ne 0 ]; then
    echo "E: Unable to set GID of the unifi-video group to $PGID"
    exit 1
  else
    echo "I: Successfully set unifi-video GID to $PGID"
  fi
fi

# Configure tmpdir if it is mounted
if [ -d /unifi-tmpfs ]; then
  TMPDIR="-Dav.tempdir=/unifi-tmpfs"
  chown -R unifi-video:unifi-video /unifi-tmpfs
fi

# No debug mode set via env, default to off
if [ -n "$DEBUG" ]; then
  DEBUG="-debug"
fi

# chown volumes
chown unifi-video:unifi-video /unifi-video/data /unifi-video/logs

# Copy initial configuration to run the wizard
if [ ! -f /unifi-video/data/system.properties ]; then
  cp -f /usr/lib/unifi-video/etc/system.properties /unifi-video/data/system.properties
  chown unifi-video:unifi-video /unifi-video/data/system.properties
fi

echo "I: exec'ing unifi-video service.."

# Run the service
exec /usr/bin/jsvc \
  $DEBUG \
  -nodetach \
  -cwd /usr/lib/unifi-video \
  -user unifi-video \
  -home /usr/lib/jvm/java-8-openjdk-amd64/jre \
  -cp /usr/share/java/commons-daemon.jar:/usr/lib/unifi-video/lib/airvision.jar \
  -pidfile /var/run/unifi-video/unifi-video.pid \
  -procname unifi-video -Djava.security.egd=file:/dev/urandom \
  -Xmx2048M \
  -Djava.library.path=/usr/lib/unifi-video/lib \
  -Djava.awt.headless=true \
  -Djavax.net.ssl.trustStore=/usr/lib/unifi-video/etc/ufv-truststore \
  -Dfile.encoding=UTF-8 \
  $TMPDIR \
  com.ubnt.airvision.Main start

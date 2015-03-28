#!/bin/sh
# dropbox service
# Copied from
# http://www.jamescoyle.net/how-to/1147-setup-headless-dropbox-sync-client
#
# start-stop-daemon
# -b --background
# -o return exit status 0 instead of 1 if no actions are (would be) taken.
# -c Change to this username/uid before starting the process. 
# -u Check for processes owned by the user specified
# -x Check for processes that are instances of this executable 
# -K stop
# -S start

DROPBOX_USERS="{% for account in dropbox.accounts %}{{ account }} {% endfor %}"

DAEMON=/home/web/.dropbox-dist/dropboxd

start() {
   echo "Starting dropbox..."
   for dbuser in $DROPBOX_USERS; do
       HOMEDIR=/home/web/repo/files/dropbox/$dbuser
       if [ -x $DAEMON ]; then
           HOME="$HOMEDIR" start-stop-daemon -b -o -c web -S -u web -x $DAEMON
       fi
   done
}

stop() {
   echo "Stopping dropbox..."
   for dbuser in $DROPBOX_USERS; do
       HOMEDIR=/home/web/repo/files/dropbox/$dbuser
       if [ -x $DAEMON ]; then
           start-stop-daemon -o -c web -K -u web -x $DAEMON
       fi
   done
}

status() {
   dbpid=`pgrep -u web dropbox`
   if [ -z $dbpid ] ; then
       echo "dropboxd for USER web: not running."
   else
       echo "dropboxd for USER web: running (pid $dbpid)"
   fi
}

case "$1" in

   start)
       start
       ;;
   stop)
       stop
       ;;
   restart|reload|force-reload)
       stop
       start
       ;;
   status)
       status
       ;;
   *)
       echo "Usage: /etc/init.d/dropbox {start|stop|reload|force-reload|restart|status}"
       exit 1

esac

exit 0

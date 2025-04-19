#!/usr/bin/env sh


if [ "x$(hostname)" = "xqpve0" ] ; then
   exit
fi
if [ "x$(hostname)" = "xqpve1" ] ; then
   exit
fi
if [ "x$(hostname)" = "xqdev" ] ; then
   exit
fi

{ crontab -l| grep -q will_shutdown; } || (crontab -l 2>/dev/null; echo "20      23      *       *       *       for tty in /dev/pts/*; do  echo will_shutdown_in_5_minute> \$tty; done") | crontab -
{ crontab -l| grep -q poweroff ; } || (crontab -l 2>/dev/null; echo "25      23      *       *       *       /sbin/poweroff") | crontab -
crontab -l


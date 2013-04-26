#!/bin/bash
if [ $# -eq 0 ] ; then
    echo "Usage: ./drop_rst.sh <remote_ip>"
    exit 1
fi
iptables -A OUTPUT -p tcp --tcp-flags rst rst -d $1 -j DROP

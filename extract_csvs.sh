#!/bin/bash

if [ ! -f "$1" ]; then
  echo "Specify a contacts file for import"
  exit 1
fi

if ! type "csvtool" > /dev/null; then
  echo "You need to install 'csvtool'"
  exit 1
fi

echo "id,firstname,lastname,email,phone,mobile,c_mattermost_handle,c_bed_places,c_bed_period_start,c_bed_period_end,c_bed_gender,c_bed_comment,c_bed_samegender,c_bed_wheelchair,c_bed_district,c_bed_is_host" > hosts.csv
csvtool col 1,5,6,9,10,11,22,60,61,62,71,72,73,74,64,69 $1 | grep -vE '^,+$' | grep '1$' | sort -n >> hosts.csv

echo "id,firstname,lastname,email,phone,mobile,c_mattermost_handle,c_bed_places,c_bed_period_start,c_bed_period_end,c_bed_gender,c_bed_comment,c_bed_samegender,c_bed_wheelchair,c_bed_district,c_bed_host_mail,c_bed_host_firstname,c_bed_host_lastname,c_bed_host_phone,c_bed_host_mm,c_bed_is_guest" > guests.csv
csvtool col 1,5,6,9,10,11,22,60,61,62,71,72,73,74,64,75,76,77,78,79,70 $1 | grep -vE '^,+$' | grep '1$' | sort -n >> guests.csv


#!/bin/bash

if [ ! -f "$1" ]; then
  echo "Specify a contacts file for import"
  exit 1
fi

if ! type "csvtool" > /dev/null; then
  echo "You need to install 'csvtool'"
  exit 1
fi

echo "id,firstname,lastname,email,phone,mobile,c_bed_places,c_bed_period_start,c_bed_period_end,c_bed_gender,c_bed_samegender,c_bed_district,c_bed_is_host" > hosts.csv
csvtool format '%(1),%(5),%(6),%(9),%(10),%(11),%(60),%(61),%(62),%(71),%(73),%(64),%(69)\n' contacts_october-1-2019.csv   | grep -vE '^,+$' | grep '1$' | sort -n >> hosts.csv

echo "id,firstname,lastname,email,phone,mobile,c_bed_places,c_bed_period_start,c_bed_period_end,c_bed_gender,c_bed_samegender,c_bed_district,c_bed_is_guest" > guests.csv
csvtool format '%(1),%(5),%(6),%(9),%(10),%(11),%(60),%(61),%(62),%(71),%(73),%(64),%(70)\n' contacts_october-1-2019.csv   | grep -vE '^,+$' | grep '1$' | sort -n >> guests.csv


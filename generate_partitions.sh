#!/bin/sh

# initial partition date
DATE=2017-01-01

# generate for 24 months parititions
for i in {0..24}
do
   START_MONTH_DATE=$(date -d "$DATE $i month" +%Y-%m-%d)
   NEXT_MONTH_DATE=$(date -d "$DATE $(($i+1)) month" +%Y-%m-%d)
   MONTH_CONVENTION=$(date -d "$START_MONTH_DATE" +%Y%m)
   #echo "$MONTH_END_DATE"
   #echo "$NEXT_MONTH_DATE"
   #echo "$MONTH_CONVENTION"
   echo "PARTITION p$MONTH_CONVENTION VALUES LESS THAN (TO_DAYS('$NEXT_MONTH_DATE')),"
done

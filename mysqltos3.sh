#!/bin/bash

# Based on https://gist.github.com/2206527

# Be pretty
echo -e " "
echo -e " .  ____  .    ______________________________"
echo -e " |/      \|   |                              |"
echo -e "[| \e[1;31mâ™¥    â™¥\e[00m |]  | S3 MySQL Backup Script|"
echo -e " |___==___|  /                               |"
echo -e "              |______________________________|"
echo -e " "

# Basic variables
MYSQLUSER="user"
MYSQLPASS="password"
MYSQLHOST="localhost"
bucket="s3://bucketname"

# Timestamp (sortable AND readable)
stamp=`date +"%s - %A %d %B %Y @ %H%M"`

# List all the databases
databases=`mysql -h $MYSQLHOST -u $MYSQLUSER -p$MYSQLPASS -e "SHOW DATABASES;" | tr -d "| " | grep -v "\(Database\|information_schema\|performance_schema\|mysql\|test\)"`

# Feedback
echo -e "Dumping to \e[1;32m$bucket/$stamp/\e[00m"

# Loop the databases
for db in $databases; do

  # Define our filenames
  filename="$stamp - $db.sql.gz"
  tmpfile="/tmp/$filename"
  object="$bucket/$stamp/$filename"

  # Feedback
  echo -e "\e[1;34m$db\e[00m"

  # Dump and zip
  echo -e "  creating \e[0;35m$tmpfile\e[00m"
  mysqldump -h $MYSQLHOST -u $MYSQLUSER -p$MYSQLPASS --force --opt --databases "$db" | gzip -c > "$tmpfile"

  # Upload
  echo -e "  uploading..."
  s3cmd put "$tmpfile" "$object"

  # Delete
  rm -f "$tmpfile"

done;

# Jobs a goodun
echo -e "\e[1;32mJobs a goodun\e[00m"

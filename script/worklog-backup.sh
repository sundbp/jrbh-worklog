#!/bin/sh

cp /home/patrik/Dropbox/backup/jrbh_prod.dump.4 /home/patrik/Dropbox/backup/jrbh_prod.dump.5
cp /home/patrik/Dropbox/backup/jrbh_prod.dump.3 /home/patrik/Dropbox/backup/jrbh_prod.dump.4
cp /home/patrik/Dropbox/backup/jrbh_prod.dump.2 /home/patrik/Dropbox/backup/jrbh_prod.dump.3
cp /home/patrik/Dropbox/backup/jrbh_prod.dump.1 /home/patrik/Dropbox/backup/jrbh_prod.dump.2
cp /home/patrik/Dropbox/backup/jrbh_prod.dump /home/patrik/Dropbox/backup/jrbh_prod.dump.1
/usr/bin/pg_dump jrbh_prod > /home/patrik/Dropbox/backup/jrbh_prod.dump

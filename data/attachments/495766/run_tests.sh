#!/bin/sh

set -e

# Rubies that are expected to work without -K
ALL_RUBIES=1.8.7,1.9.1

# Rails and 1.8.7 don't yet work with -K options
FIXED_RUBIES=1.9.1

cd actionpack
echo "---- Runing NORMAL test (no -K option) ----"
RUBYOPT= rvm ${ALL_RUBIES} tests

for k in e u s n; do 
  echo "---- Runing with -K${k} ----"
  RUBYOPT=-K${k} rvm ${FIXED_RUBIES} tests
done
cd ..

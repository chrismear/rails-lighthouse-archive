#!/bin/sh

set -e

run_all_tests()
{
  cd actionpack
  echo "---- Runing NORMAL test (no -K option) ----"
  RUBYOPT= rake test; 
  for k in e u s n; do 
    echo "---- Runing with -K${k} ----"
    RUBYOPT=-K${k} rake test; 
  done
  cd ..
}

rvm use 1.9.1
run_all_tests

rvm use 1.8.7
run_all_tests

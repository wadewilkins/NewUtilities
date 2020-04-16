#!/bin/bash
set echo off
cd tests
echo
echo
echo
echo "Testing container/application deployment"


# Let's get the CONTAIN_ID once.
CONTAINER_ID=`docker ps --format "{{.ID}}" --filter 'ancestor=wade_wilkins_concur'`
echo "ContainerID:  " $CONTAINER_ID
if [ -z "$CONTAINER_ID" ]
then
      echo "Container not found"
      exit 1
fi

# Happy path.  Submit job and make sure it runs.
./test1 $CONTAINER_ID
ret_code=$?
if [ "$ret_code" -ne "0" ]; then
  echo "Test 1 failed!"
  exit 2
fi

# Cron schedule fromat tests.
./test2 $CONTAINER_ID
ret_code=$?
if [ "$ret_code" -ne "0" ]; then
  echo "Test 2 failed!"
  exit 3
fi

# Cron task null or missing test
./test3 $CONTAINER_ID
ret_code=$?
if [ "$ret_code" -ne "0" ]; then
  echo "Test 3 failed!"
  exit 4 
fi

# Cron comments are NOT required
./test4 $CONTAINER_ID
ret_code=$?
if [ "$ret_code" -ne "0" ]; then
  echo "Test 4 failed!"
  exit 5
fi


echo
echo "All Tests passed"
echo 
echo
echo
exit 0 

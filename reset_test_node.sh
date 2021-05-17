#!/bin/sh
echo "------------Reset------------"

# Init genesis block & Run test node
for i in 1 2 3 4
do
  echo "--- Remove log $i ..."
  rm -rf ./node"$i".log

  echo "--- Remove chaindata node $i ..."
  FILEPATH=./tests/test_nodes/node"$i"/data/geth
  (cd $FILEPATH;ls | grep -v nodekey | xargs rm -rf)
done

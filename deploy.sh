#/bin/bash
cd `dirname $0`
make clean
make html
mv build/html build/warehouse


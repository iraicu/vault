#!/bin/bash

output_file="data/log-C0-SATA.csv"
echo "K,RAM,HASH,SORT,FLUSH,COMPRESS,TOTAL" > $output_file

RAM=262144

make clean
make vault_x86 NONCE_SIZE=4 RECORD_SIZE=32

for k in {25..32}
do
	./drop-all-caches.sh
	output=$(./vault -t 8 -o 128 -i 8 -f vault$k.memo -m $RAM -k $k -w true)
	echo "$k,$RAM,$output" >> $output_file
done

make clean
make vault_x86 NONCE_SIZE=5 RECORD_SIZE=32
for k in {33..35}
do
	./drop-all-caches.sh
	output=$(./vault -t 8 -o 128 -i 8 -f vault$k.memo -m $RAM -k $k -w true)
	echo "$k,$RAM,$output" >> $output_file
done

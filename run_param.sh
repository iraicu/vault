#!/bin/bash

output_file="data/epycbox/param-C0-HDD.csv"
hash_threads=8
sort_threads=64
io_threads=1
max_threads=64
ram=262144
k=32

echo "Hash_threads,Sort_threads,IO_threads,RAM,HASH,SORT,FLUSH,COMPRESS,TOTAL" > $output_file

make clean
make vault_arm NONCE_SIZE=4 RECORD_SIZE=32

for t in 2 4 8 16 32 64
do
	if [ $t -gt $max_threads ]; then
		break
	fi

	./drop-all-caches.sh
	output=$(./vault -t $t -o $sort_threads -i $io_threads -m $ram -k $k -f vault$k.memo -w true)
	echo "$t,$sort_threads,$io_threads,$ram,$output" >> $output_file
done

for o in 1 2 4 8 16 32 64
do
	if [ $o -gt $max_threads ]; then
		break
	fi

	./drop-all-caches.sh
	output=$(./vault -t $hash_threads -o $o -i $io_threads -m $ram -k $k -f vault$k.memo -w true)
        echo "$hash_threads,$o,$io_threads,$ram,$output" >> $output_file
done


for i in 1 2 4 8 16 32 64
do
	if [ $i -gt $max_threads ]; then
		break
	fi

        ./drop-all-caches.sh
        output=$(./vault -t $hash_threads -o $sort_threads -i $i -m $ram -k $k -f vault$k.memo -w true)

        echo "$hash_threads,$sort_threads,$i,$ram,$output" >> $output_file
done

for r in 512 1024 2048 4096 8192 16384 32768 65536 131072 262144
do
	if [ $r -gt $ram ]; then
		break
	fi

        ./drop-all-caches.sh
        output=$(./vault -t $hash_threads -o $sort_threads -i $io_threads -m $r -k $k -f vault$k.memo -w true)

        echo "$hash_threads,$sort_threads,$io_threads,$r,$output" >> $output_file
done

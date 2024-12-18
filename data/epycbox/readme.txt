param-C0-HDD.csv
data-l/varvara/vault
./vault -t $hash_threads -o $sort_threads -i $io_threads -m $ram -k $k -f vault$k.memo -w true

log-C0-HDD.txt
data-l/varvara/vault
./vault -t 8 -o 128 -i 1 -m 262144 -k $k -f vault$k.memo -w true

log-C0-NVME.txt
data-fast/varvara/vault
./vault -t 8 -o 128 -i 8 -m 262144 -k $k -f vault$k.memo -w true

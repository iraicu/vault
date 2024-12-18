param-C0.csv
data-fast/varvara/vault
./vault -t $hash_threads -o $sort_threads -i $io_threads -m $ram -k 32 -f vault32.memo -w true
-- -t, -o, -i, -m varied

log-C0-NVME.txt
data-fast/varvara/vault
./vault -t 8 -o 8 -i 8 -f vault$k.memo -m 16384 -k $k -w true

log-C0-HDD.txt 
data-a/varvara/vaultx **there is vault executable in that folder
./vault -t 8 -o 8 -i 1 -f vault$k.memo -m 16384 -k $k -w true

lspci -nnk | grep -A3 -i audio
sleep 3
speaker-test -c 2 -t wav

register_habits=$(ls ~/pdbs/ |
	grep '\.habit$' |
	fzy)

if [ -z "$register_habits" ]; then
	echo "you didn't choose one!"
else
	date "+%m/%d/%Y" >> ~/pdbs/$register_habits
fi

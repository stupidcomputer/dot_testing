#!/bin/sh

day5=$(date --date="5 days ago" "+%m/%d/%Y")
day4=$(date --date="4 days ago" "+%m/%d/%Y")
day3=$(date --date="3 days ago" "+%m/%d/%Y")
day2=$(date --date="2 days ago" "+%m/%d/%Y")
day1=$(date --date="1 days ago" "+%m/%d/%Y")
today=$(date "+%m/%d/%Y")

# $1 -- habit filename
show_past_habit () {
	printf "%25s =========\n" "$1"
	donein5days=$(grep -c "$day5" "$HOME/pdbs/$1")
	donein4days=$(grep -c "$day4" "$HOME/pdbs/$1")
	donein3days=$(grep -c "$day3" "$HOME/pdbs/$1")
	donein2days=$(grep -c "$day2" "$HOME/pdbs/$1")
	donein1days=$(grep -c "$day1" "$HOME/pdbs/$1")
	donetoday=$(grep -c "$today"  "$HOME/pdbs/$1")

	printf "%.5s %.5s %.5s %.5s %.5s %.5s\n%5s %5s %5s %5s %5s %5s\n\n" \
		"$day5" "$day4" "$day3" "$day2" "$day1" "$today" \
		"$donein5days" "$donein4days" "$donein3days" \
		"$donein2days" "$donein1days" "$donetoday"
}

habits=$(ls ~/pdbs | grep '\.habit$')
for i in $habits; do
	show_past_habit "$i"
done

read

#!/bin/sh

day5=$(date --date="5 days ago" "+%m/%d/%Y")
day4=$(date --date="4 days ago" "+%m/%d/%Y")
day3=$(date --date="3 days ago" "+%m/%d/%Y")
day2=$(date --date="2 days ago" "+%m/%d/%Y")
day1=$(date --date="1 days ago" "+%m/%d/%Y")
today=$(date "+%m/%d/%Y")

# $1 -- habit filename
show_past_habit () {
	printf "%55s =========\n" "$1"
	donein5days=$(grep -c "$day5" ~/pdbs/$1.habit )
	donein4days=$(grep -c "$day4" ~/pdbs/$1.habit )
	donein3days=$(grep -c "$day3" ~/pdbs/$1.habit )
	donein2days=$(grep -c "$day2" ~/pdbs/$1.habit )
	donein1days=$(grep -c "$day1" ~/pdbs/$1.habit )
	donetoday=$(grep -c "$today" ~/pdbs/$1.habit)

	printf "%10s %10s %10s %10s %10s %10s\n%10s %10s %10s %10s %10s (today)%3s\n\n" \
		"$day5" "$day4" "$day3" "$day2" "$day1" "$today" \
		"$donein5days" "$donein4days" "$donein3days" \
		"$donein2days" "$donein1days" "$donetoday"
}

habits=$(ls ~/pdbs | grep '\.habit$' | sed 's/\.habit$//g')
IFS='
'
for i in "$habits"; do
	show_past_habit "$i"
done

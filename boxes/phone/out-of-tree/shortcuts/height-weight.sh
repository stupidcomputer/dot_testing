#!/bin/sh

today=$(date "+%m/%d/%Y")

printf "Inputting height and weight information for today\n\n"
printf "Height?\n"

read -p "?>" height

printf "Weight?\n"

read -p "?>" weight

cd ~/pdbs
printf "\n%s	%i" "$today" "$weight" >> weight.timeseries
printf "\n%s	%i" "$today" "$height" >> height.timeseries

git add weight.timeseries height.timeseries
git commit -m "added height, weight data for $today"

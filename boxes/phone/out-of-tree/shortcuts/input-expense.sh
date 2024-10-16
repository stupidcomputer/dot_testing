#!/bin/sh

today=$(date "+%m/%d/%Y")
ledgerdate=$(date "+%Y/%m/%d")

printf "Inputting an expense for today\n\n"
printf "Payee name?\n"

read -p "?>" payee

printf "Amount?\n"

read -p "?>" amount

cd ~/pdbs
printf '%s * %s\n\tExpenses:%s	$%s\n\tAssets:Greencard 4154\n\n' "$ledgerdate" "$payee" "$payee" "$amount" >> phone.ledger

git add phone.ledger
git commit -m "added an expense for $today"

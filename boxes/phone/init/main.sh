mkdir -p app_cache
for i in $(cat apps); do
	output_name=$(echo $i | awk -F'/' '{print $NF}')
	curl "$i" --max-redirs 999 -L -C - -o "app_cache/$output_name"
	adb install "app_cache/$output_name"
done

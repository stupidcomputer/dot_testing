mkdir -p app_cache
for i in $(cat apps); do
	output_name=$(echo $i | awk -F'/' '{print $NF}')
	curl "$i" --max-redirs 999 -L -C - -o "app_cache/$output_name"
	adb install "app_cache/$output_name"
done

mkdir -p gpapp_cache
for i in $(cat gpapps); do
	apkeep -a "$i" ./gpapp_cache/
done

for i in $(ls gpapp_cache/ | grep xapk); do
	# this is specific to planning center online
	xapk_playground=$(mktemp)
	rm $xapk_playground
	mkdir $xapk_playground

	cp gpapp_cache/$i $xapk_playground
	cd $xapk_playground
	mkdir out
	unzip $i -d out
	cd -
	cd $xapk_playground/out
	rm icon.png
	rm manifest.json
	adb install-multiple *
	cd -
done

cd gpapp_cache
for i in $(ls | grep '\.apk'); do
	adb install $i
done

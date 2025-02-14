inotifywait -m -e create --format '%f' '/home/usr' | while read NEWFILE
do
	if [ "$NEWFILE" = "Downloads" ]; then
		rm -rf ~/Downloads
	elif [ "$NEWFILE" = "Documents" ]; then
		rm -rf ~/Documents
	elif [ "$NEWFILE" = "BespokeSynth" ]; then
		rm -rf ~/BespokeSynth
	elif [ "$NEWFILE" = "BlackmagicDesign" ]; then
		rm -rf ~/BlackmagicDesign
	elif [ "$NEWFILE" = "Videos" ]; then
		rm -rf ~/Videos
	elif [ "$NEWFILE" = "MuseScore4" ]; then
		rm -rf ~/MuseScore4
	elif [ "$NEWFILE" = ".zoom" ]; then
		rm -rf ~/.zoom
	elif [ "$NEWFILE" = ".thunderbird" ]; then
		rm -rf ~/.thunderbird
	elif [ "$NEWFILE" = ".mozilla" ]; then
		rm -rf ~/.mozilla
	elif [ "$NEWFILE" = ".fltk" ]; then
		rm -rf ~/.fltk
	elif [ "$NEWFILE" = ".compose-cache" ]; then
		rm -rf ~/.compose-cache
	elif [ "$NEWFILE" = ".xsession-errors" ]; then
		rm -f ~/.xsession-errors
	fi
done

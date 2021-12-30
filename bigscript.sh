START=""
END=""
COUNTER=0
SELECTEDFILE=""
NUMBEROFPAGES=""
EXTENSION=""

selectFile() {
	zenity --info --title "Information" --text "Welcome to PDF extracter. Please select a file."
	SELECTEDFILE=$(zenity --file-selection)

	FILENAME=${SELECTEDFILE##*/}
	EXTENSION=${FILENAME##*.}

	while [ "$EXTENSION" != "pdf" ]; do
		zenity --error --text "You must select a PDF file. Please select again."
		SELECTEDFILE=$(zenity --file-selection)
		FILENAME=${SELECTEDFILE##*/}
		EXTENSION=${FILENAME##*.}
	done
}

takeStartPage() {
	counter=1
	table=""
	while [ "$counter" -le "$1" ]; do
		x="$counter"
		table="$table $x"
		counter=$((counter + 1))
	done

	START=$(zenity --list --title="START" --text="Select start page" --column="Pages" --width="400" --height="400" $table)

	if [ "$?" -eq 1 ]; then
		echo "Exiting"
		exit
	fi

	if [ "$?" -eq 0 ] && [ -z "$START" ]; then
		echo "You need to select a page"
		zenity --error --text "You must select a start page. Please select again."
		START=""
		takeStartPage $NUMBEROFPAGES
	fi
}

takeFinalPage() {
	counter=$1 # $1 = $START $2 = $NUMBEROFPAGES
	table=""
	while [ "$counter" -le "$2" ]; do
		x="$counter"
		table="$table $x"
		counter=$((counter + 1))
	done

	END=$(zenity --list --title="END" --text="Select final page" --column="Pages" --width="400" --height="400" $table)

	if [ "$?" -eq 1 ]; then
		echo "Exiting"
		exit
	fi

	if [ "$?" -eq 0 ] && [ -z "$END" ]; then
		echo "You need to select a page"
		zenity --error --text "You must select a final page. Please select again."
		END=""
		takeFinalPage $START $NUMBEROFPAGES
	fi
}

extractPDF() {
	pdftk $SELECTEDFILE cat $START-$END output extracted_p$START-$END.pdf
	zenity --info --title="Success" --text "Extracted successfuly" --no-wrap
}

main() {
	selectFile
	NUMBEROFPAGES=$(pdftk $SELECTEDFILE dump_data | grep NumberOfPages | sed 's/[^0-9]*//')
	takeStartPage $NUMBEROFPAGES
	takeFinalPage $START $NUMBEROFPAGES
	extractPDF
}

main

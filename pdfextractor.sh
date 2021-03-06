#!/bin/bash

# Author           : Duhan Meric Korkmaz ( duhanmeric@gmail.com )
# Created On       : 29.12.2021
# Last Modified By : Duhan Meric Korkmaz ( duhanmeric@gmail.com )
# Last Modified On : 11.01.2022
# Version          : 1.4
#
# Description : This script is using "pdftk" third party program to cut the PDF files for selected pages.
#
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more
# details or contact the Free Software Foundation for a copy)

START=""         # variable for pdf start page
END=""           # variable for pdf final page
SELECTEDFILE=""  # selected PDF file
NUMBEROFPAGES="" # how many pages does PDF file has
EXTENSION=""     # file extension

# file selection function
selectFile() {
	zenity --info --title "Information" --text "Welcome to PDF extractor. Please select a file."

	# select file UI
	SELECTEDFILE=$(zenity --file-selection)
	ret=$?

	# finding the file's extension.
	FILENAME=${SELECTEDFILE##*/}
	EXTENSION=${FILENAME##*.}

	# if clicked cancel and extension is empty
	if [ "$ret" -eq 1 ]; then
		echo "Exiting"
		exit
	fi

	# if the extension is not pdf then make recursion
	while [ "$EXTENSION" != "pdf" ]; do
		zenity --error --text "You must select a PDF file. Please select again."
		SELECTEDFILE=$(zenity --file-selection)
		if [ "$?" == 1 ]; then
			echo "Exiting"
			exit
		fi
		FILENAME=${SELECTEDFILE##*/}
		EXTENSION=${FILENAME##*.}

	done
}

# detecting the starting page for cut
takeStartPage() {

	# creating a table with page numbers
	counter=1
	table=""
	while [ "$counter" -le "$1" ]; do
		x="$counter"
		table="$table $x"
		counter=$((counter + 1))
	done

	# adding that table to zenity list and storing it in START variable
	START=$(zenity --list --title="START" --text="Select start page" --column="Pages" --width="400" --height="400" $table)

	# if user clicks cancel button then exit
	if [ "$?" -eq 1 ]; then
		echo "Exiting"
		exit
	fi

	# if user clicks OK and if the START page is not selected
	# then display zenity error and ask again with recursion
	if [ "$?" -eq 0 ] && [ -z "$START" ]; then
		echo "You need to select a page"
		zenity --error --text "You must select a start page. Please select again."
		START=""
		takeStartPage $NUMBEROFPAGES
	fi
}

# detecting the starting page for cut
takeFinalPage() {

	# creating a table with page numbers
	# $1 = $START $2 = $NUMBEROFPAGES
	counter=$1
	table=""
	while [ "$counter" -le "$2" ]; do
		x="$counter"
		table="$table $x"
		counter=$((counter + 1))
	done

	# adding that table to zenity list and storing it in END variable
	END=$(zenity --list --title="END" --text="Select final page" --column="Pages" --width="400" --height="400" $table)

	# if user clicks cancel button then exit
	if [ "$?" -eq 1 ]; then
		echo "Exiting"
		exit
	fi

	# if user clicks OK and if the START page is not selected
	# then display zenity error and ask again with recursion
	# but this time I need to give 2 arguments to recursion
	if [ "$?" -eq 0 ] && [ -z "$END" ]; then
		echo "You need to select a page"
		zenity --error --text "You must select a final page. Please select again."
		END=""
		takeFinalPage $START $NUMBEROFPAGES
	fi
}

# real extracting process
extractPDF() {
	# detecting the original PDF file's path
	DIR="$(dirname "${SELECTEDFILE}")"

	# pdftk code line for cuting the PDF. and the output file name is related to selected page numbers.
	pdftk $SELECTEDFILE cat $START-$END output "$DIR/extracted_$START-$END.pdf"

	# success screen after extracted
	zenity --info --title="Success" --text "Extracted successfuly" --no-wrap
}

main() {
	if [ "$1" == "" ]; then
		selectFile

		# detecting how many pages does that pdf file has by pdftk
		NUMBEROFPAGES=$(pdftk $SELECTEDFILE dump_data | grep NumberOfPages | sed 's/[^0-9]*//')
		takeStartPage $NUMBEROFPAGES
		takeFinalPage $START $NUMBEROFPAGES
		extractPDF
	fi

	# if the argument is none of the -v/-h
	if [ "$1" != "-v" ] && [ "$1" != "-h" ] && [ "$1" != "-c" ] && [ "$1" != "-g" ]; then 
		echo "Unkown command"
	else
		while getopts hvcg OPT; do # take options for -help -version -copyright -github
			case $OPT in
			h)
				cat <<EndOfMessage
Welcome to PDF extractor.
1. First of all you need to select a file with '.pdf' extension.
2. After selecting a PDF file, you need to select the start page where you want to start to cut the document. If you click cancel it will exit the program
3. Remember the click 'OK' after selecting a start page, otherwise the program will ask you the same question until you exit or until you select the page.		
4. If you already passed the start page screen you are going to see 'select final page' screen. At here, same procedure continues like start page."
5. After selecting a end page, you are going to see 'Extracted successfuly' screen."
6. The new PDF file is in the same path with the original PDF file."
EndOfMessage
				;;
			v)
				cat <<EndOfMessage
Bash Script PDF Extractor, version 1.4
Author: Duhan Meric Korkmaz.
Email: duhanmeric@gmail.com
Student No: 191914
EndOfMessage
				;;
			c)
				cat <<EndOfMessage
Licensed under GPL (see /usr/share/common-licenses/GPL for more
details or contact the Free Software Foundation for a copy)
EndOfMessage
				;;
			g)
				cat <<EndOfMessage
author github (actually a web developer): https://github.com/duhanmeric
author website: https://duhanmeric.herokuapp.com
EndOfMessage
				;;
			# there is no "*" option for this switch case because it already been made
			# in if else section above
			esac
		done

	fi
}

main $1 # entry point for program with additional argument like -h or -v

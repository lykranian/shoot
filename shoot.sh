#!/usr/bin/env bash

# screenshot program mk. 2

# requires: maim+slop OR scrot   (maim+slop recommended)
#           pngcrush
#           libimage-exiftool-perl
#           jq
#           xclip
#           keybase (optional)

# user options
DESTINATION="teknik" # "teknik" or "kbfs" for now
EXT="png" # filetype (keep png)
# end options



# don't blame me if you touch anything below and it stops working
NAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 1)
FILE="$NAME.$EXT"
TMP="/tmp/shoot"

mkdir $TMP &> /dev/null

# functions
show_help () {
    echo "  simple screenshot script"
    echo "  https image link is copied to clipboard"
    echo ""
    echo "  set $DESTINATION on line 13"
    echo ""
    echo "  usage : shoot"
    echo "        : shoot -s"
    echo "        : shoot filename"
    echo ""
    echo "   args : none        fullscreen"
    echo "        : -s          select area"
    echo "        : filename    upload file"
    echo "        : -h          show this help"
    echo ""
    echo "   deps : maim+slop OR scrot"
    echo "        : pngcrush"
    echo "        : libimage-exiftool-perl"
    echo "        : xclip"
    echo "        : jq"
    echo "        : keybase (optional)"
    exit
}
installed () {
    type "$1" &> /dev/null
}
dep_error () {
    echo " you are missing one or more dependencies. see -h for details."
    exit
}
full_screen () {
    if installed maim; then
	maim --format=png --opengl --mask=on --nokeyboard $TMP/$FILE
    elif installed scrot; then
	scrot -q 85 $TMP/$FILE
    else
	dep_error
    fi
    echo "  screenshot taken"
    notify-send "screenshot taken"
}
select_area () {
    if installed maim; then
    maim --select --format=png --opengl --mask=on --magnify --bordersize 9001 --color=0.2,0.2,0.2,0.9 $TMP/$FILE
    elif installed scrot; then
	scrot -s -q 85 $TMP/$FILE
    else
	dep_error
    fi
    echo "  screenshot taken"
    notify-send "screenshot taken"
}
copy_file () {
    filename=$(basename "$1")
    EXT="${filename##*.}"
    FILE="$NAME.$EXT"
    cp $1 $TMP/$FILE
}


# some dep checks
if ! installed exiftool; then
    dep_error
fi
if ! installed pngcrush; then
    dep_error
fi
if ! installed xclip; then
    dep_error
fi
if ! installed jq; then
    dep_error
fi

# arg logic
if [ $# -gt 1 ]; then
    show_help
fi

if [ $# -eq 0 ]; then
    full_screen
fi

if [ $# -eq 1 ]; then
    if [ $1 == "-s" ]; then
	select_area
    elif [ $1 == "-h" ]; then
	 show_help
    else
	if [ -e $1 ]; then
	    copy_file $1
	else
	    echo "  file does not exist."
	    exit
	fi
    fi
fi


# strip all exif data
exiftool -all= $TMP/$FILE &> /dev/null

# pngcrush if file is a png
if [ $EXT == "png" ]; then
    pngcrush $TMP/$FILE $TMP/$FILE.crushed &> /dev/null
    cp $TMP/$FILE.crushed $TMP/$FILE
fi

if [ $DESTINATION == "teknik" ]; then
    OUTPUT=$(curl -sf -F "genDeletionKey=true" -F "saveKey=true" -F "encrypt=true" -F "file=@$(echo $TMP/$FILE)" https://api.teknik.io/v1/upload/)
    LINK=$(echo $OUTPUT | jq -M -r .result.url)
    DELETION=$(echo $OUTPUT | jq -M -r .result.url)
elif [ $DESTINATION == "kbfs" ]; then
    if ! installed keybase; then
	echo "  please install keybase."
	exit
    else
	# see if keybase is logged in
	LOGGED_IN_=$(keybase status | grep "Logged in")
	LOGGED_IN="${LOGGED_IN_##* }"
	if [ "$LOGGED_IN" != "yes" ]; then
	    echo '  you are not logged into keybase. see `run_keybase`'
	    exit
	fi
	# get current keybase username
	USER_=$(keybase status | grep Username)
	USER="${USER_##* }"
	# USER="whatever" # set this to your user if prev 2 lines get it wrong

	mkdir /keybase/public/$USER/i &> /dev/null
	cp $TMP/$FILE /keybase/public/$USER/i/$FILE

	LINK="https://$USER.keybase.pub/i/$FILE"
    fi
fi


printf "  "
# copies link to clipboards
echo -n $LINK | xclip -i -sel p -f | xclip -i -sel c -f
echo ""
notify-send "upload complete"

#!/usr/bin/env bash

MEDIA_PLAYER="/usr/bin/mpv"      # Replace it with your Media Player, eg: Vlc, mpv
PHOTO_VIEWER="/usr/bin/feh"      # Replace it with your Image Player, eg: feh, viewnior 

XDG_OPEN="/usr/bin/xdg-open"     # Open the file with their default software

if [[ $EDITOR == "" ]]; then # Check if EDITOR env variable is present or not
	EDITOR="/usr/bin/nano" # Replace it with your text editor, eg: vim, nano, micro
fi

# Checking if i3-swallow binary exist or not (https://github.com/jamesofarrell/i3-swallow)
if [ "$(command -v swallow)" ]; then
	MEDIA_PLAYER="swallow $MEDIA_PLAYER"
	PHOTO_VIEWER="swallow $PHOTO_VIEWER"
fi

# Checking if fzf binary exist or not
if ! [ "$(command -v fzf)" ]; then
	echo "Install fzf first"
	exit 2
fi

if [[ $# -gt 0 ]]
	then
		array=( "$@" )
		len=${#array[@]}
		args=${array[*]:0:$len}
		searched_file=$(fzf --cycle --ansi --layout reverse-list --no-mouse --preview 'bat --color "always" {}' --query "$args")

	else
		searched_file=$(fzf --cycle --ansi --layout reverse-list --no-mouse --preview 'bat --color "always" {}')
fi

function search_and_match () {

	if  [ "$extension" == "mp3" ] || [ "$extension" == "wav" ] || 
		[ "$extension" == "aa"  ] || [ "$extension" == "aac" ] || 
		[ "$extension" == "ogg" ] || [ "$extension" == "oga" ] || 
		[ "$extension" == "m4a" ] || [ "$extension" == "aac" ]

		then

			echo "$searched_file"
			$MEDIA_PLAYER "$searched_file"

	fi

	if  [ "$extension" == "mp4" ] || [ "$extension" == "mkv"  ] || 
		[ "$extension" == "flv" ] || [ "$extension" == "webm" ] || 
		[ "$extension" == "3gp" ] || [ "$extension" == "mpeg" ] || 
		[ "$extension" == "wmv" ] || [ "$extension" == "avi"  ]

		then
		
			echo "$searched_file"
			$MEDIA_PLAYER "$searched_file"
			
	fi

    if  [ "$extension" == "jpg"  ] || [ "$extension" == "jpeg" ] || 
	    [ "$extension" == "JPG"  ] || [ "$extension" == "JPEG" ] || 
	    [ "$extension" == "png"  ] || [ "$extension" == "gif"  ] || 
	    [ "$extension" == "webp" ] || [ "$extension" == "WEBP" ] || 
	    [ "$extension" == "tiff" ] || [ "$extension" == "TIFF" ] || 
	    [ "$extension" == "bmp"  ] || [ "$extension" == "svg"  ]

        then
        
			echo "$searched_file"
			$PHOTO_VIEWER "$searched_file"

	fi

    if [[ $(file --mime "$searched_file" | grep -oh "\w*charset=\w*") != "charset=binary" ]]; then
		echo "\"$searched_file\"" | xclip -selection clipboard
		echo "$searched_file | Copied to your clipborad"
		$EDITOR "$searched_file" 
	else
		$XDG_OPEN "$searched_file"
		echo "\"$searched_file\"" | xclip -selection clipboard
		echo "$searched_file | Copied to your clipborad"
	fi
	
}

if [ "$searched_file" == "" ]
    then
        echo "Nothing found..."
    else
    	file_base=$(basename "$searched_file")
        extension=${file_base##*.}
        search_and_match
fi

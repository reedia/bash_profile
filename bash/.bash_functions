#!/bin/bash -l

#  ---------------------------------------------------------------------------
#
#  ______      _  ______ _ _           
#  |  _  \    | | |  ___(_) |          
#  | | | |___ | |_| |_   _| | ___  ___ 
#  | | | / _ \| __|  _| | | |/ _ \/ __|
#  | |/ / (_) | |_| |   | | |  __/\__ \
#  |___/ \___/ \__\_|   |_|_|\___||___/
#                                                                            
#  Description:  Mac OS X Dotfiles - Simply designed to fit your shell life.
#  																			
#  Sections:																
#  																			
#  	1. Functions, File and Folder Management
#
#  ---------------------------------------------------------------------------


#  ---------------------------------------------------------------------------
#   1. Functions, File and Folder Management
#  ---------------------------------------------------------------------------

# zipf: Function to create a ZIP archive of a folder
zipf() { zip -r "$1".zip "$1"; }

# numFiles: Function to count of non-hidden files in current dir
alias numFiles='echo $(ls -1 | wc -l)' 

# rm: Function to make 'rm' move files to the trash
function rm() {
	local path
	for path in "$@"; do
		# ignore any arguments
		if [[ "$path" == -* ]]; then :
		else
			local dst=${path##*/}
			# append the time if necessary
			while [ -e ~/.Trash/"$dst" ]; do
				dst="$dst "$(date +%H-%M-%S)
			done
			mv "$path" ~/.Trash/"$dst"
		fi
	done
}

# cd: Function to Enable 'cd' into directory aliases
function cd() {
	if [ ${#1} == 0 ]; then
		builtin cd
	elif [ -d "${1}" ]; then
		builtin cd "${1}"
	elif [[ -f "${1}" || -L "${1}" ]]; then
		path=$(getTrueName "$1")
		builtin cd "$path"
	else
		builtin cd "${1}"
	fi
}

# tree: Function to generates a tree view from the current directory
if [ ! -e /usr/local/bin/tree ]; then
	function tree(){
		pwd
		ls -R | grep ":$" |   \
		sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'
	}
fi

# sshKeyGen: Function to generates SSH key
function sshKeyGen() {

	echo "What's the name of the Key (no spaced please) ? ";
	read -r name;

	echo "What's the email associated with it? ";
	read -r email;

	$(ssh-keygen -t rsa -f ~/.ssh/id_rsa_$name -C "$email");

	ssh-add ~/.ssh/id_rsa_$name;

	pbcopy < ~/.ssh/id_rsa_$name.pub;

	echo "SSH Key copied in your clipboard";

}

# filestolower: Function to rename all the files which contain uppercase letters to lowercase in the current folder
function filestolower(){
  read -r -p "This will rename all the files and directories to lowercase in the current folder, continue? [y/n]: " letsdothis
  if [ "$letsdothis" = "y" ] || [ "$letsdothis" = "Y" ]; then
    for x in `ls`
      do
      skip=false
      if [ -d "$x" ]; then
	read -rp "'$x' is a folder, rename it? [y/n]: " renamedir
	if [ "$renamedir" = "n" ] || [ "$renamedir" = "N" ]; then
	  skip=true
	fi
      fi
      if [ "$skip" == "false" ]; then
        lc=$(echo "$x"  | tr ':A-Z:' ':a-z:')
        if [ "$lc" != "$x" ]; then
          echo "renaming $x -> $lc"
          mv "$x" "$lc"
        fi
      fi
    done
  fi
}

# aliasc: Function alias
aliasc() {
  alias | grep "^${1}=" | awk -F= '{ print $2 }' | sed "s/^'//" | sed "s/'$//"
}

# mkcd: Function to combine mkdir and cd
mkcd() {
	mkdir "$1"
	cd "$1" || exit
}

# tosu: Function to combine touch and osu
tosu() {
	touch "$1"
	osu "$1"
}

# size: Function to check a file size
size() {
	stat -f '%z' "$1"
}

# md: Function to create a new directory and enter it
function md() {
	mkdir -p "$@" && cd "$@" || exit 
}

# rd: Function to remove a direcory and its files
function rd() {
	rm -rf "$@"
}

# logout: Function to logout from OS X via the Terminal
logout() {
	osascript -e 'tell application "System Events" to log out'
	builtin logout
}

# countdown: Function for countdown
function countdown(){
   date1=$((`date +%s` + $1));
   while [ "$date1" -ne `date +%s` ]; do
     echo -ne "$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r";
   done
}

# logout: Function for a stopwatch
function stopwatch(){
  date1=`date +%s`;
   while true; do
    echo -ne "$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r";
   done
}

# extract: Function to extract most know archives with one command
extract() {
	if [ -f $1 ]; then
		case $1 in
		*.tar.bz2) tar xjf $1 ;;
		*.tar.gz) tar xzf $1 ;;
		*.bz2) bunzip2 $1 ;;
		*.rar) unrar e $1 ;;
		*.gz) gunzip $1 ;;
		*.tar) tar xf $1 ;;
		*.tbz2) tar xjf $1 ;;
		*.tgz) tar xzf $1 ;;
		*.zip) unzip $1 ;;
		*.Z) uncompress $1 ;;
		*.7z) 7z x $1 ;;
		*) echo "'$1' cannot be extracted via extract()" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

# randompwd: Function to generates a strong random password of 20 characters
# https://www.gnu.org/software/sed/manual/html_node/Character-Classes-and-Bracket-Expressions.html
function randompwd() {
	cat /dev/urandom | LC_CTYPE=C tr -dc [:alnum:],[:alpha:],[:punct:] | fold -w 256 | head -c 20 | sed -e 's/^0*//'
	echo
}

# mcd: Function to makes new Dir and jumps inside
mcd() { mkdir -p "$1" && cd "$1" || exit; }

# trash: Function to moves a file to the MacOS trash
trash() { command mv "$@" ~/.Trash; }

# ql: Function to open any file in MacOS Quicklook Preview
ql() { qlmanage -p "$*" >&/dev/null; }   

# my_ps: Function to list processes owned by an user
my_ps() { ps "$@" -u "$USER" -o pid,%cpu,%mem,start,time,bsdtime,command; }

# ii: Function to display useful host related informaton
ii() {
	echo -e "\\nYou are logged on ${RED}$HOST"
	echo -e "\\nAdditionnal information:$NC "
	uname -a
	echo -e "\\n${RED}Users logged on:$NC "
	w -h
	echo -e "\\n${RED}Current date :$NC "
	date
	echo -e "\\n${RED}Machine stats :$NC "
	uptime
	echo -e "\\n${RED}Current network location :$NC "
	scselect
	echo -e "\\n${RED}Public facing IP Address :$NC "
	myip
	echo -e "\\n${RED}DNS Configuration:$NC "
	scutil --dns
	echo
}

# httpDebug: Function to download a web page and show info on what took time
httpDebug() { /usr/bin/curl "$@" -o /dev/null -w "dns: %{time_namelookup} connect: %{time_connect} pretransfer: %{time_pretransfer} starttransfer: %{time_starttransfer} total: %{time_total}\\n"; }
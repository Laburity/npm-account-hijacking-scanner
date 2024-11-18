#######################################

# NPM Package Checker
# Author: Hassan Khan Yusufzai
# GitHub: https://github.com/Splint3r7
# Twitter: https://twitter.com/Splint3r7

########################################

if [[ $1 == '-h' ]] || [[ $1 == '--help' ]]; then
	echo "[+] Useage:	./npm-checker.sh -p <package name>"
	echo "[+] Useage:	./npm-checker.sh -f <list of package names>"
	exit 1
fi

RED='\033[0;31m'
BWhite='\033[1;37m'
GREEN="\033[0;32m"
RESET="\033[0m"
NC='\033[0m'
YELLO="\033[0;33m"
Purple='\033[0;35m'
IRed='\033[0;91m' 
Cyan='\033[0;36m'


NPMCHECKER () {

exec=$(npm view ${package} maintainers.email 2>&1)
current_epoch=`date '+%s'`

if [[ $exec =~ "npm ERR!" ]] || [[ $exec == "" ]]; then
	echo -e "[${RED}-${NC}] ${YELLO}Not a Valid NPM package${NC}: ${package}"
else

	if [[ $exec =~ "maintainers"  ]]; then
		email=$(echo -e "$exec \n" | awk '{print $3}')
		emails=$(echo -e "$email \n" | cut -d "'" -f2 | cut -d "@" -f2 | sort -u | awk 'NF' > /tmp/tmp.txt)

		while read e_mails; do
			hosts=$(echo $e_mails)
			
			expiry_date=$(whois "$hosts" | egrep -i "Expiration Date" | head -1 | awk '{print $NF}' | cut -d "+" -f1 | sed "s/\-/:/g" | cut -d "T" -f1 2>&1)

			exp_date_stamp=$(date -j -f "%Y:%m:%d" "${expiry_date}" +%s 2>&1)

			if [[ $current_epoch > $exp_date_stamp ]] || [[ $current_epoch == $exp_date_stamp ]] ; then

				vuln_mail=$(echo "$email \n" | grep $hosts)
				
				vuln_flag=$(echo -e "[\xE2\x9D\x8C]${RED} VULNERABLE ${NC} -> [$hosts] [$vuln_mail]")

				echo -e "[${GREEN}+${NC}] ${YELLO}Checking NPM Package${NC}: $package $vuln_flag"
			else
				secure_flag=$(echo -e "[${GREEN}\xE2\x9C\x94${NC}] Secure Host -> [$hosts]")
				echo -e "[${GREEN}+${NC}] ${YELLO}Checking NPM Package${NC}: $package $secure_flag"
			fi
		done < /tmp/tmp.txt
		
	else
		fmail=$(echo -e "$exec")
		mail=$(echo -e "$exec" | cut -d "'" -f2 | cut -d "@" -f2 | sort -u)

		expiry_date=$(whois "$mail" | egrep -i "Expiration Date" | head -1 | awk '{print $NF}' | cut -d "+" -f1 | sed "s/\-/:/g" | cut -d "T" -f1 2>&1)

		exp_date_stamp=$(date -j -f "%Y:%m:%d" "${expiry_date}" +%s 2>&1)

		if [[ $current_epoch > $exp_date_stamp ]] || [[ $current_epoch == $exp_date_stamp ]] ; then

			vuln_mail=$(echo "$fmail " | grep $mail)
			vuln_flag=$(echo -e "[\xE2\x9D\x8C]${RED} VULNERABLE ${NC} -> [$mail] [$vuln_mail]")
			echo -e "[${GREEN}+${NC}] ${YELLO}Checking NPM Package${NC}: $package $vuln_flag"
		else
			secure_flag=$(echo -e "[${GREEN}\xE2\x9C\x94${NC}] Secure Host -> [$mail]")
			echo -e "[${GREEN}+${NC}] ${YELLO}Checking NPM Package${NC}: $package $secure_flag"
		fi
fi
fi
}

if [[ $1 == '--package' ]] || [[ $1 == '-p' ]]; then
	
	package=$2
	NPMCHECKER

fi

if [[ $1 == '--file' ]] || [[ $1 == '-f' ]]; then
	input_file=$2
	for package in $(cat $input_file); do
		NPMCHECKER
	done

fi

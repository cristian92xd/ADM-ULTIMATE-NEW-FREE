#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
LINE='======================='
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
badlist2="/tmp/badlist2"
badlist3="/tmp/badlist3"
HELPERS="/bin/helpers.py"
PYTHON_MIN_VER="2.6"
MEGA_API_URL="https://g.api.mega.co.nz"
OPENSSL_AES_CTR_128_DEC="openssl enc -d -aes-128-ctr"
OPENSSL_AES_CBC_128_DEC="openssl enc -a -A -d -aes-128-cbc"
OPENSSL_AES_CBC_256_DEC="openssl enc -a -A -d -aes-256-cbc"
OPENSSL_MD5="openssl md5"
[[ ! -e ${badlist2} ]] && touch ${badlist2}
[[ ! -e ${badlist3} ]] && touch ${badlist3}
[[ ! -e ${HELPERS} ]] && wget -q -O ${HELPERS} https://www.dropbox.com/s/jdhevg793boe93m/helpers.py?dl=1
[[ -e ${HELPERS} ]] && chmod 777 ${HELPERS}
[[ $(dpkg --get-selections|grep -w "python"|head -1) ]] || apt-get install python -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "python3"|head -1) ]] || apt-get install python3 -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "curl"|head -1) ]] || apt-get install curl -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "openssl"|head -1) ]] || apt-get install openssl -y &>/dev/null
[[ $(dpkg --get-selections|grep -w "pv"|head -1) ]] || apt-get install pv -y &>/dev/null
SCRIPT=$(readlink -f "$0")
if [ ! -d ".mega" ]; then
	mkdir ".mega"
fi
fun_trans () { 
local texto
local retorno
declare -A texto
SCPidioma="${SCPdir}/idioma"
[[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
local LINGUAGE=$(cat ${SCPidioma})
[[ -z $LINGUAGE ]] && LINGUAGE=pt
[[ ! -e /etc/texto-adm ]] && touch /etc/texto-adm
source /etc/texto-adm
if [[ -z "$(echo ${texto[$@]})" ]]; then
 retorno="$(source trans -e google -b es:${LINGUAGE} "$@"|sed -e 's/[^a-z0-9 -]//ig' 2>/dev/null)"
 if [[ $retorno = "" ]];then
 retorno="$(source trans -e bing -b es:${LINGUAGE} "$@"|sed -e 's/[^a-z0-9 -]//ig' 2>/dev/null)"
 fi
 if [[ $retorno = "" ]];then 
 retorno="$(source trans -e yandex -b es:${LINGUAGE} "$@"|sed -e 's/[^a-z0-9 -]//ig' 2>/dev/null)"
 fi
echo "texto[$@]='$retorno'"  >> /etc/texto-adm
echo "$retorno"
else
echo "${texto[$@]}"
fi
}
function check_deps {
	local dep_error=0
	for i in openssl python pv; do
		if [ -z "$(command -v "$i" 2>&1)" ]; then
			echo "[$i] no instalado!"
			dep_error=1
		else
			case "$i" in
				openssl)
					openssl_sup=$(openssl enc -ciphers 2>&1)
					for i in "aes-128-ctr" "aes-128-cbc" "aes-256-cbc"; do
						if [ -z "$(echo -n "$openssl_sup" | grep -o "$i" | head -n1)" ]; then
							echo "openssl binario no suportado ${i}"
							dep_error=1
						fi
					done
				;;
				python)
					if [[ "$(python --version 2>&1 | grep -o -E '[0-9]\.[0-9]')" < "$PYTHON_MIN_VER" ]]; then
						dep_error=1
					fi
				;;
			esac
		fi
	done
	if [ $dep_error -ne 0 ]; then
		exit
	fi
}
function urlb64_to_b64 {
	local b64=$(echo -n "$1" | tr '\-_' '+/' | tr -d ',')
	local pad=$(((4-${#1}%4)%4))
	for i in $(seq 1 $pad); do
		b64="${b64}="
	done
	echo -n "$b64"
}
function decrypt_md_link {
	local data=$(regex_imatch "^.*?mega:\/\/enc[0-9]*?\?([a-z0-9_,-]+).*?$" "$link" 1)
	local iv="79F10A01844A0B27FF5B2D4E0ED3163E"
	if [ $(echo -n "$1" | grep 'mega://enc?') ]; then
		key="6B316F36416C2D316B7A3F217A30357958585858585858585858585858585858"
	elif [ $(echo -n "$1" | grep 'mega://enc2?') ];then
		key="ED1F4C200B35139806B260563B3D3876F011B4750F3A1A4A5EFD0BBE67554B44"
	fi
	echo -n "https://mega.nz/#"$(echo -n "$(urlb64_to_b64 "$data")" | $OPENSSL_AES_CBC_256_DEC -K "$key" -iv "$iv")
}
function hrk2hk {
	declare -A hk
	hk[0]=$(( 0x${1:0:16} ^ 0x${1:32:16} ))
	hk[1]=$(( 0x${1:16:16} ^ 0x${1:48:16} ))

	printf "%016x" ${hk[*]}
}
function get_mc_link_info {
	local MC_API_URL=$(echo -n "$1" | grep -i -E -o 'https?://[^/]+')"/api"
	local download_exit_code=1
	local info_link=$($DL_COM --header 'Content-Type: application/json' $DL_COM_PDATA "{\"m\":\"info\", \"link\":\"$1\"}" "$MC_API_URL")
	download_exit_code=$?
	if [ "$download_exit_code" -ne 0 ]; then
		echo -e "ERROR: ALGO SALIO MAL (${download_exit_code})"
		return 1
	fi
	if [ $(echo $info_link | grep '"error"') ]; then
		local error_code=$($HELPERS json_param "$info_link" error)
		echo -e "MEGA CRYPTER ERROR $error_code"
		return 1
	fi
	local expire=$($HELPERS json_param "$info_link" expire)
	if [ "$expire" != "0" ]; then
		IFS='#' read -a array <<< "$expire"
		local no_exp_token=${array[1]}
	else
		local no_exp_token="$expire"
	fi
	local file_name=$(echo -n $($HELPERS json_param "$info_link" name) | base64 -w 0 -i 2>/dev/null)
	local path=$(echo -n $($HELPERS json_param "$info_link" path))
	if [ "$path" != "0" ]; then
		path=$(echo -n "$path" | base64 -w 0 -i 2>/dev/null)
	fi
	local mc_pass=$($HELPERS json_param "$info_link" pass)
	local file_size=$($HELPERS json_param "$info_link" size)
	local key=$($HELPERS json_param "$info_link" key)
	echo -n "${file_name}@${path}@${file_size}@${mc_pass}@${key}@${no_exp_token}"
}
function check_file_exists {
	if [ -f "$1" ]; then
		local actual_size=$(stat -c %s "$1")
		if [ "$actual_size" == "$2" ]; then
			if [ -n "$4" ] && [ -f ".mega/${4}" ]; then
				rm ".mega/${4}"
			fi
			showError "\033[1;31m $(fun_trans "ERROR: Archivo $1 no existe. Descarga abortada")!"
		fi
		DL_MSG="\033[1;31m Archivo $1 existe pero con diferente tamaño (${2} vs ${actual_size} bytes). Descargando [${3}] ...\n"
	else
		DL_MSG="\033[1;31m $(fun_trans "Descargando") $1 [${3}] ..."
	fi
}
function format_file_size {
	if [ "$1" -ge 1073741824 ]; then
		local file_size_f=$(awk "BEGIN { rounded = sprintf(\"%.1f\", ${1}/1073741824); print rounded }")" GB"
	elif [ "$1" -ge 1048576 ];then
		local file_size_f=$(awk "BEGIN { rounded = sprintf(\"%.1f\", ${1}/1048576); print rounded }")" MB"
	else
		local file_size_f="${1} bytes"
	fi
	echo -ne "$file_size_f"
}
function mc_pass_check {
	IFS='#' read -a array <<< "$1"
	local iter_log2=${array[0]}
	local key_check=${array[1]}
	local salt=${array[2]}
	local iv=${array[3]}
	local password=$(echo -n "$2" | base64 -w 0 -i 2>/dev/null)
	local mc_pass_hash=$($HELPERS pbkdf2 "$salt" "$password" $((2**$iter_log2)))
	mc_pass_hash=$(echo -n "$mc_pass_hash" | base64 -d -i 2>/dev/null | od -v -An -t x1 | tr -d '\n ')
	iv=$(echo -n "$iv" | base64 -d -i 2>/dev/null | od -v -An -t x1 | tr -d '\n ')
	if [ "$(echo -n "$key_check" | $OPENSSL_AES_CBC_256_DEC -K "$mc_pass_hash" -iv "$iv" 2>/dev/null | od -v -An -t x1 | tr -d '\n ')" != "$mc_pass_hash" ]; then
		echo -n "0"
	else
		echo -n "${mc_pass_hash}#${iv}"
	fi
}
function trim {
	if [[ "$1" =~ \ *([^ ]|[^ ].*[^ ])\ * ]]; then
		echo -n "${BASH_REMATCH[1]}"
	fi
}
function regex_match {
	if [[ "$2" =~ $1 ]]; then
		echo -n "${BASH_REMATCH[$3]}"
	fi
}
function regex_imatch {
	shopt -s nocasematch
	if [[ "$2" =~ $1 ]]; then
		echo -n "${BASH_REMATCH[$3]}"
	fi
	shopt -u nocasematch
}
proxy_fun () {
	index="/root/index"
	list="/tmp/list"
	random="/tmp/rnd2"
	wget -q -O $index "https://www.sslproxies.org/"
	[[ ! -e $index ]] && exit
	cat $index | grep -oi "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}</td><td>[0-9]\{2,5\}" | sed -e "s%</td><td>%:%g" | sort > $list
	[[ $(awk '{x++}END{print x}' $list) = "" ]] && exit
	rm $index
	echo "" > $random
	#Start
	i=0
	echo -ne "\033[1;37m [1] $(fun_trans "Obteniendo proxy") "
	while true; do
	num=$(awk '{x++}END{print x}' $list)
	let num--
		while true; do
			num2=$(shuf -i 1-$num -n 1)
			num3=$(sed -n "/${num2}/"= $random)
			[[ $num3 = "" ]] && break
			echo "$num2" >> $random
		done
	proxy=$(awk "NR==$num2" $list)
	[[ $proxy = "" ]] && exit
	[[ $i -gt $num ]] && exit
	int=$(sed -n "/${proxy}/"= $badlist2)
	if [[ ${int} = "" ]]; then
	  #HTTPS
	  curl -s --max-time 1 -x https://$proxy $linkmega &> /dev/null
	  CHECK=$?
	  [[ $CHECK -eq 0 ]] && good_proxy="true"
	  #FUN 
		if [[ $good_proxy != "" ]]; then
		  break
		else
		  echo "$proxy" >> $badlist2
		fi
	  fi
	  let i++
	  done
	echo -e "\033[1;32m [OK]"
	rm $random
	rm $list
}
socks_fun () {
	index="/root/index"
	list="/tmp/list"
	random="/tmp/rnd"
	wget -q -O $list "http://45.7.230.128:81/vipsocks.txt" 
	[[ ! -e $list ]] && no_found3 && exit
	echo "" > $random
	#Start
	echo -ne "\033[1;37m [$tri] $(fun_trans "Obteniendo socks4") "
	i=0
	while true; do
	num=$(awk '{x++}END{print x}' $list)
	let num--
		while true; do
			num2=$(shuf -i 1-$num -n 1)
			num3=$(sed -n "/${num2}/"= $random)
			[[ $num3 = "" ]] && break
			echo "$num2" >> $random
		done
	proxy=$(awk "NR==$num2" $list)
	[[ $proxy = "" ]] && exit
	[[ $i -gt $num ]] && exit
	int=$(sed -n "/${proxy}/"= $badlist3)
	if [[ ${int} = "" ]]; then
	  #Socks4
	  curl -s --max-time 1 --socks4 $proxy $linkmega &> /dev/null
	  CHECK=$?
	  [[ $CHECK -eq 0 ]] && good_proxy="true"
	  #FUN 
		if [[ $good_proxy != "" ]]; then
		  break
		else
		  echo "$proxy" >> $badlist3
		fi
	  fi
	  let i++
	  done
	echo -e "\033[1;32m [OK]" && let tri++
	rm $random
	rm $list
}
fun_mega () {
echo -e " \033[1;32m $(fun_trans "GESTOR DE DESCARGA - MEGA NZ") [NEW-ADM]"
echo -e "$barra"
echo -e "${cor[4]} [1] >${cor[3]} $(fun_trans "Descarga archivos de MEGA NZ")"
echo -e "${cor[4]} [2] >${cor[3]} $(fun_trans "Descarga archivos de MEGA NZ usando proxy")"
echo -e "${cor[4]} [3] >${cor[3]} $(fun_trans "Descarga archivos de MEGA NZ usando socks4") ($(fun_trans "MAS LENTO"))"
echo -e "${cor[4]} [0] >${cor[3]} $(fun_trans "VOLTAR")"
echo -e "$barra"
while [[ ${megaoption} != @([0-3]) ]]; do
read -p "Digite un opcion: " megaoption
tput cuu1 && tput dl1
done
case ${megaoption} in
	0)
	exit;;
	*);;
	esac
while [[ ${linkmega} = "" ]]; do
read -p "Ingresar link mega: " linkmega
tput cuu1 && tput dl1
done
tri=1
case ${megaoption} in
	1)
	p1=$(trim "$linkmega")
	if [[ "$p1" =~ ^http ]] || [[ "$p1" =~ ^mega:// ]]; then
		link="$p1"
    else
	exit
	fi
	DL_COM="curl --fail --connect-timeout 30 -s "
	DL_COM_PDATA="--data"
	;;
	2)
	p1=$(trim "$linkmega")
	if [[ "$p1" =~ ^http ]] || [[ "$p1" =~ ^mega:// ]]; then
		link="$p1"
	else
	exit
	fi
	proxy_fun
	DL_COM="curl --fail -s --connect-timeout 30 --x $proxy"
	DL_COM_PDATA="--data"
	;;	
	3)
	p1=$(trim "$linkmega")
	if [[ "$p1" =~ ^http ]] || [[ "$p1" =~ ^mega:// ]]; then
		link="$p1"
	else
	exit
	fi
	socks_fun
	DL_COM="curl --fail -s --connect-timeout 30 --socks4 $proxy"
	DL_COM_PDATA="--data"
	;;
	esac
check_deps
if [ $(echo -n "$link" | grep -E -o 'mega://enc') ]; then
	link=$(decrypt_md_link "$link")
fi
echo -ne "\033[1;37m [$tri] $(fun_trans "Obteniendo metadata .")"
if [ $(echo -n "$link" | grep -E -o 'mega(\.co)?\.nz') ]; then
	file_id=$(regex_match "^.*\/#.*?!(.+)!.*$" "$link" 1)
	file_key=$(regex_match "^.*\/#.*?!.+!(.+)$" "$link" 1)
	hex_raw_key=$(echo -n $(urlb64_to_b64 "$file_key") | base64 -d -i 2>/dev/null | od -v -An -t x1 | tr -d '\n ')
	if [ $(echo -n "$link" | grep -E -o 'mega(\.co)?\.nz/#!') ]; then
		mega_req_json="[{\"a\":\"g\", \"p\":\"${file_id}\"}]"
		mega_req_url="${MEGA_API_URL}/cs?id=&ak="
	elif [ $(echo -n "$link" | grep -E -o -i 'mega(\.co)?\.nz/#N!') ]; then
		mega_req_json="[{\"a\":\"g\", \"n\":\"${file_id}\"}]"
		folder_id=$(regex_match "###n\=(.+)$" "$link" 1)
		mega_req_url="${MEGA_API_URL}/cs?id=&ak=&n=${folder_id}"
	fi
	mega_res_json=$($DL_COM --header 'Content-Type: application/json' $DL_COM_PDATA "$mega_req_json" "$mega_req_url")
	download_exit_code=$?
	if [ "$download_exit_code" -ne 0 ]; then
		echo -e "\033[1;31m [FAIL]"
		echo -e "$barra"
		echo -e "\n\033[1;31m $(fun_trans "El enlace del archivo no es valido")!"
		echo -e "\n$barra"
		exit
	fi
	if [ $(echo -n "$mega_res_json" | grep -E -o '\[ *\-[0-9]+ *\]') ]; then
		echo -e "\033[1;31m [FAIL]"
		echo -e "$barra"
		echo -e "\033[1;31m $(fun_trans "Enlace del archivo no valido")!"
		echo -e "\n$barra"
		exit
	fi
	file_size=$($HELPERS json_param "$mega_res_json" s)
	at=$($HELPERS json_param "$mega_res_json" at)
	hex_key=$(hrk2hk "$hex_raw_key")
	at_dec_json=$(echo -n $(urlb64_to_b64 "$at") | $OPENSSL_AES_CBC_128_DEC -K "$hex_key" -iv "00000000000000000000000000000000" -nopad | tr -d '\0')

	if [ ! $(echo -n "$at_dec_json" | grep -E -o 'MEGA') ]; then
		echo -e "\033[1;31m [FAIL]"
		echo -e "$barra"
		echo -e "\033[1;31m$(fun_trans "Link no valido!")"
		echo -e "\n$barra"
		exit
	fi
	file_name=$(echo $at_dec_json|cut -d':' -f3|sed 's/^.\|.$//g'|sed 's/.$//g')
	check_file_exists "$file_name" "$file_size" "$(format_file_size "$file_size")"
	if [ $(echo -n "$link" | grep -E -o 'mega(\.co)?\.nz/#!') ]; then
		mega_req_json="[{\"a\":\"g\", \"g\":\"1\", \"p\":\"$file_id\"}]"
	elif [ $(echo -n "$link" | grep -E -o -i 'mega(\.co)?\.nz/#N!') ]; then
		mega_req_json="[{\"a\":\"g\", \"g\":\"1\", \"n\":\"$file_id\"}]"
	fi
	mega_res_json=$($DL_COM --header 'Content-Type: application/json' $DL_COM_PDATA "$mega_req_json" "$mega_req_url")
	download_exit_code=$?
	if [ "$download_exit_code" -ne 0 ]; then
		echo -e "\033[1;31m [FAIL]"
		echo -e "$barra"
		echo -e "\033[1;31m $(fun_trans "No se puedo encontrar el archivo")!"
		echo -e "\n$barra"
		exit
	fi
	dl_temp_url=$($HELPERS json_param "$mega_res_json" g)
else
	MC_API_URL=$(echo -n "$1" | grep -i -E -o 'https?://[^/]+')"/api"
	md5=$(echo -n "$link" | $OPENSSL_MD5 | grep -E -o '[0-9a-f]{32}')
	if [ -f ".mega/${md5}" ];then
		mc_link_info=$(cat ".mega/${md5}")
	else
		mc_link_info=$(get_mc_link_info "$link")
		if [ "$?" -eq 1 ];then
			echo -e "\033[1;31m [FAIL]"
			echo -e "$barra"
			echo -e "$mc_link_info"
			echo -e "$barra"
			exit 1
		fi
		echo -n "$mc_link_info" >> ".mega/${md5}"
	fi
	IFS='@' read -a array <<< "$mc_link_info"
	file_name=$(echo -n "${array[0]}" | base64 -d -i 2>/dev/null)
	path=${array[1]}
	if [ "$path" != "0" ]; then
		path=$(echo -n "$path" | base64 -d -i 2>/dev/null)
	fi
	file_size=${array[2]}
	mc_pass=${array[3]}
	key=${array[4]}
	no_exp_token=${array[5]}
	if [ "$path" != "0" ] && [ "$path" != "" ]; then
		if [ ! -d "$path" ]; then
			mkdir -p "$path"
		fi
		file_name="${path}${file_name}"
	fi
	if [ "$mc_pass" != "0" ]; then
		echo -e "\033[1;31m [FAIL]"
		echo -e "\n$barra"
		echo -e "\033[1;31m $(fun_trans "Enlace del archivo no valido")!"
		echo -e "\n$barra"
		exit
	else
		hex_raw_key=$(echo -n $(urlb64_to_b64 "$key") | base64 -d -i 2>/dev/null | od -v -An -t x1 | tr -d '\n ')
	fi
	check_file_exists "$file_name" "$file_size" "$(format_file_size "$file_size")" "$md5"
	hex_key=$(hrk2hk "$hex_raw_key")
	dl_link=$($DL_COM --header 'Content-Type: application/json' $DL_COM_PDATA "{\"m\":\"dl\", \"link\":\"$link\", \"noexpire\":\"$no_exp_token\"}" "$MC_API_URL")
	download_exit_code=$?
	if [ "$download_exit_code" -ne 0 ]; then
		echo -e "\033[1;31m [FAIL]"
		echo -e "\n$barra"
		echo -e "\033[1;31m $(fun_trans "No se puede realizar la descarga")!"
	fi
	if [ $(echo $dl_link | grep '"error"') ]; then
		error_code=$($HELPERS json_param "$dl_link" error)
		echo -e "\033[1;31m [FAIL]"
		echo -e "\n$barra"
		echo -e "\033[1;31m $(fun_trans "Error de encriptacion: $error_code")!"
	fi
	dl_temp_url=$($HELPERS json_param "$dl_link" url)
	if [ "$mc_pass" != "0" ]; then
		iv=$(echo -n $($HELPERS json_param "$dl_link" pass) | base64 -d -i 2>/dev/null | od -v -An -t x1 | tr -d '\n ')
		dl_temp_url=$(echo -n "$dl_temp_url" | $OPENSSL_AES_CBC_256_DEC -K "$pass_hash" -iv "$iv")
	fi
fi
DL_COMMAND="$DL_COM"
echo -e "\033[1;32m [OK]"
if [ "$output" == "-" ]; then
	hex_iv="${hex_raw_key:32:16}0000000000000000"
	$DL_COMMAND "$dl_temp_url" | $OPENSSL_AES_CTR_128_DEC -K "$hex_key" -iv "$hex_iv"
	exit 0
fi
echo -e "$barra"
echo -e "$DL_MSG\n\033[1;32m"
PV_CMD="pv"
download_exit_code=1
until [ "$download_exit_code" -eq 0 ]; do
	if [ -f "${file_name}.temp" ]; then
		temp_size=$(stat -c %s "${file_name}.temp")
		offset=$(($temp_size-$(($temp_size%16))))
		iv_forward=$(printf "%016x" $(($offset/16)))
		hex_iv="${hex_raw_key:32:16}$iv_forward"
		truncate -s $offset "${file_name}.temp"
		$DL_COMMAND "$dl_temp_url/$offset" | $PV_CMD -s $(($file_size-$offset)) | $OPENSSL_AES_CTR_128_DEC -K "$hex_key" -iv "$hex_iv" >> "${file_name}.temp"
	else
		hex_iv="${hex_raw_key:32:16}0000000000000000"
		$DL_COMMAND "$dl_temp_url" | $PV_CMD -s $file_size | $OPENSSL_AES_CTR_128_DEC -K "$hex_key" -iv "$hex_iv" > "${file_name}.temp"
	fi
	download_exit_code=${PIPESTATUS[0]}
	if [ "$download_exit_code" -ne 0 ]; then
		echo -e "\n$barra"
		echo -e  "\033[1;31m $(fun_trans "No es posible la comunicacion con MEGA - bad proxy o limite maximo alcanzado")? "
		echo -e "$barra"
		exit
	fi
done
if [ ! -f "${file_name}.temp" ]; then
	exit
fi
mv "${file_name}.temp" "${file_name}"
mv "${file_name}" "/var/www/"
cp "/var/www/${file_name}" "/var/www/html/${file_name}"
if [ -f ".mega/${md5}" ];then
	rm ".mega/${md5}"
fi
fun_ip () {
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && echo "$MEU_IP2" || echo "$MEU_IP"
}
IP="$(fun_ip)"
echo -e "$barra"
echo -e "\033[1;32m $(fun_trans " Archivo descargado en"): \n http://$IP:81/$file_name"
echo -e "$barra"
exit
}
fun_mega
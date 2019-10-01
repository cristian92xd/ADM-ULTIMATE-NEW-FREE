#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

fun_ip () {
if [[ -e /etc/MEUIPADM ]]; then
IP="$(cat /etc/MEUIPADM)"
else
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && IP="$MEU_IP2" || IP="$MEU_IP"
echo "$MEU_IP2" > /etc/MEUIPADM
fi
}

fun_bar () {
comando="$1"
 _=$(
$comando > /dev/null 2>&1
) & > /dev/null
pid=$!
while [[ -d /proc/$pid ]]; do
echo -ne " \033[1;33m["
   for((i=0; i<10; i++)); do
   echo -ne "\033[1;31m##"
   sleep 0.2
   done
echo -ne "\033[1;33m]"
sleep 1s
echo
tput cuu1
tput dl1
done
echo -e " \033[1;33m[\033[1;31m####################\033[1;33m] - \033[1;32m100%\033[0m"
sleep 1s
}

GENERADOR_BIN () {
echo -ne " \033[1;31m[ ! ] Descargando"
wget -O /etc/ger-frm/GENERADOR_BIN.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/HerramientasADM/GENERADOR_BIN.shh > /dev/null 2>&1; chmod +x /etc/ger-frm/GENERADOR_BIN.sh
fun_bar "chmod -R 777 /etc/ger-frm/"
chmod -R 777 /etc/ger-frm/ > /dev/null 2>&1
echo -e "$barra"
echo -e "${cor[3]} DESCARGADO CON SUCCESO"
echo -e "$barra"
return
}

# fun_bar "service ssh restart" "service squid3 restart"

msg -ama "$(fun_trans "STATUS DE SISTEMA") ${cor[4]}[NEW-ADM]"
echo -e "$barra"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "GERADOR DE BIN")"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "CONSULTAR UN BIN")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "XXXXXXXXXXXXX")"
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "XXXXXXXXXXXXXX")"
echo -ne "\033[1;32m [5] > " && msg -azu "$(fun_trans "XXXXXXXXXXXXXX")"
echo -ne "\033[1;32m [6] > " && msg -azu "$(fun_trans "XXXXXXXXXXXXXXXXXX") $ddos"
echo -ne "\033[1;32m [7] > " && msg -azu "$(fun_trans "XXXXXXXXXXXXXXXXXX") $ddos"
echo -ne "\033[1;32m [8] > " && msg -azu "$(fun_trans "XXXXXXXXXXXXXXXXXX") $ddos"
echo -ne "\033[1;32m [9] > " && msg -azu "$(fun_trans "XXXXXXXXXXXXXXXXXX") $ddos"
echo -ne "\033[1;32m [10] > " && msg -azu "$(fun_trans "XXXXXXXXXXXXXXXXXX") $ddos"
echo -ne "\033[1;32m [6] > " && msg -azu "$(fun_trans "XXXXXXXXXXXXXXXXXX") $ddos"
echo -ne "\033[1;32m [6] > " && msg -azu "$(fun_trans "XXXXXXXXXXXXXXXXXX") $ddos"
echo -ne "\033[1;32m [6] > " && msg -azu "$(fun_trans "XXXXXXXXXXXXXXXXXX") $ddos"
echo -ne "\033[1;32m [6] > " && msg -azu "$(fun_trans "XXXXXXXXXXXXXXXXXX") $ddos"
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")"
echo -e "$barra"
while [[ ${arquivoonlineadm} != @(0|[1-9]) ]]; do
read -p "Selecione a Opcao: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
0)exit;;
1)GENERADOR_BIN;;
2)MasterBin;;
3)/etc/ger-tools/visorpuertos.sh;;
4)/etc/ger-tools/optimizar.sh;;
5)/etc/ger-tools/netstat.sh;;
6)/etc/frm/nload.sh;;
7)/etc/frm/nload.sh;;
8)/etc/frm/nload.sh;;
9)/etc/frm/nload.sh;;
10)/etc/frm/nload.sh;;
11)/etc/frm/nload.sh;;
esac
msg -bar
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

nload () {
wget -O /etc/ger-frm/nload.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/HerramientasADM/nload.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/nload.sh
fun_bar "chmod -R 777 /etc/ger-frm/nload.sh"
chmod -R 777 /etc/ger-frm/nload.sh > /dev/null 2>&1
echo -e "$barra"
echo -e "${cor[3]} DESCARGADO CON SUCCESO EN: ${cor[2]}Menu de herramientas"
return
}

htop () {
wget -O /etc/ger-frm/htop.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/HerramientasADM/htop.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/htop.sh
fun_bar "chmod -R 777 /etc/ger-frm/htop.sh"
chmod -R 777 /etc/ger-frm/htop.sh > /dev/null 2>&1
echo -e "$barra"
echo -e "${cor[3]} DESCARGADO CON SUCCESO EN: ${cor[2]}Menu de herramientas"
return
}

visorpuertos () {
wget -O /etc/ger-frm/visorpuertos https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/HerramientasADM/visorpuertos.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/visorpuertos.sh
fun_bar "chmod -R 777 /etc/ger-frm/visorpuertos.sh"
chmod -R 777 /etc/ger-frm/visorpuertos.sh > /dev/null 2>&1
echo -e "$barra"
echo -e "${cor[3]} DESCARGADO CON SUCCESO EN: ${cor[2]}Menu de herramientas"
return
}

nload () {
wget -O /etc/ger-frm/nettools https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/HerramientasADM/nettools > /dev/null 2>&1; chmod +x /etc/ger-frm/nettools
fun_bar "chmod -R 777 /etc/ger-frm/nettools"
chmod -R 777 /etc/ger-frm/nettools > /dev/null 2>&1
echo -e "$barra"
echo -e "${cor[3]} DESCARGADO CON SUCCESO EN: ${cor[2]}Menu de herramientas"
return
}

msg -ama "$(fun_trans "TOOLS DOWNLOAD MANAGER") ${cor[4]}[NEW-ADM]"
echo -e "$barra"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "TRAFICO DE RED NLOAD")"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "PROCESOS DEL SISTEMAx")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "STATUS DE SISTEMA")"
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "NET TOOLS TARGET")"
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")"
echo -e "$barra"
while [[ ${arquivoonlineadm} != @(0|[1-4]) ]]; do
read -p "Selecione a Opcao: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
0)exit;;
1)nload;;
2)htop.sh;;
3)visorpuertost;;
4)nettools;;
esac
msg -bar
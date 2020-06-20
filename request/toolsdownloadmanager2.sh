#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

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

fai2ban () {
wget -O /etc/ger-frm/MasterBin.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/HerramientasADM/fai2ban.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/fai2ban.sh
fun_bar "chmod -R 777 /etc/ger-frm/fai2ban.sh"
chmod -R 777 /etc/ger-frm/fai2ban.sh > /dev/null 2>&1
msg -bar
echo -e "${cor[3]} DESCARGADO CON SUCCESO EN: ${cor[2]}Menu de herramientas"
return
}

panelsshplus () {
wget -O /etc/ger-frm/real-host.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/HerramientasADM/panelsshplus.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/panelsshplus.sh
fun_bar "chmod -R 777 /etc/ger-frm/panelsshplus.sh"
chmod -R 777 /etc/ger-frm/panelsshplus.sh > /dev/null 2>&1
msg -bar
echo -e "${cor[3]} DESCARGADO CON SUCCESO EN: ${cor[2]}Menu de herramientas"
return
}

paysnd () {
wget -O /etc/ger-frm/dados.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/HerramientasADM/paysnd.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/paysnd.sh
fun_bar "chmod -R 777 /etc/ger-frm/paysnd.sh"
chmod -R 777 /etc/ger-frm/paysnd.sh > /dev/null 2>&1
msg -bar
echo -e "${cor[3]} DESCARGADO CON SUCCESO EN: ${cor[2]}Menu de herramientas"
return
}

payySND () {
wget -O /etc/ger-frm/Crear-Demo.sh https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Install/HerramientasADM/payySND.sh > /dev/null 2>&1; chmod +x /etc/ger-frm/payySND.sh
fun_bar "chmod -R 777 /etc/ger-frm/payySND.sh"
chmod -R 777 /etc/ger-frm/payySND.sh > /dev/null 2>&1
msg -bar
echo -e "${cor[3]} DESCARGADO CON SUCCESO EN: ${cor[2]}Menu de herramientas"
return
}

msg -ama "$(fun_trans "TOOLS DOWNLOAD MANAGER 2") ${cor[4]}[NEW-ADM]"
msg -bar
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "FAIL2BAN PROTECAO")"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "PANEL DE VENTAS SSHPLUS")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "PAYLOAD FORCA BRUTA BASH")"
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "PAYLOAD FORCA BRUTA PYTHON")"
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")"
msg -bar
while [[ ${arquivoonlineadm} != @(0|[1-4]) ]]; do
read -p "[0-4]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case $arquivoonlineadm in
1)fai2ban;;
2)panelsshplus;;
3)paysnd;;
4)payySND;;
0)exit;;
esac
msg -bar
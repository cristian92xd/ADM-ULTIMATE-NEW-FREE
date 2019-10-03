#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit 1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
SCPidioma="${SCPdir}/idioma" && [[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}

mportas () {
unset portas
portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
done <<< "$portas_var"
i=1
echo -e "$portas"
}

ssl_redir() {
msg -bra "$(fun_trans "Asigne un nombre para el redirecionador")"
msg -bar
read -p " nombre: " namer
msg -bar
msg -ama "$(fun_trans "A que puerto redirecionara el puerto SSL")"
msg -ama "$(fun_trans "Es decir un puerto abierto en su servidor")"
msg -ama "$(fun_trans "Ejemplo Dropbear, OpenSSH, ShadowSocks, OpenVPN, Etc")"
msg -bar
read -p " Local-Port: " portd
msg -bar
msg -ama "$(fun_trans "Que puerto desea agregar como SSL")"
msg -bar
    while true; do
    read -p " Puerto SSL: " SSLPORTr
    [[ $(mportas|grep -w "$SSLPORTr") ]] || break
    msg -bar
    echo -e "$(fun_trans "${cor[0]}Esta puerta está en uso")"
    msg -bar
    unset SSLPORT1
    done

echo "" >> /etc/stunnel/stunnel.conf
echo "[${namer}]" >> /etc/stunnel/stunnel.conf
echo "connect = 127.0.0.1:${portd}" >> /etc/stunnel/stunnel.conf
echo "accept = ${SSLPORTr}" >> /etc/stunnel/stunnel.conf
echo "client = no" >> /etc/stunnel/stunnel.conf


service stunnel4 restart > /dev/null 2>&1
msg -bar
msg -bra " $(fun_trans "AGREGADO CON EXITO") ${cor[2]}[!OK]"
msg -bar
}


gestor_fun () {
echo -e " ${cor[3]} $(fun_trans "MULTI PUERTOS SSL") ${cor[4]}[NEW-ADM]"
echo -e "$barra"
echo -e " ${cor[0]} $(fun_trans "Te permite abriar mas puertos SSL")"
while true; do
echo -e "$barra"
echo -e "${cor[4]} [1] > \033[1;36m$(fun_trans "Multi portos SSL")"
echo -e "${cor[4]} [0] > ${cor[0]}$(fun_trans "VOLTAR")\n${barra}"
while [[ ${opx} != @(0|[1-3]) ]]; do
echo -ne "${cor[0]}$(fun_trans "Digite a Opcao"): \033[1;37m" && read opx
tput cuu1 && tput dl1
done
case $opx in
	0)
	return;;
	1)
	ssl_redir
	break;;
esac
done
}
gestor_fun
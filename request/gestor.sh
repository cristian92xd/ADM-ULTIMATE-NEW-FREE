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

update_pak () {
echo -ne " \033[1;31m[ ! ] apt-get update"
apt-get update -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] apt-get upgrade"
apt-get upgrade -y > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -e "$barra"
return
}

reiniciar_ser () {
echo -ne " \033[1;31m[ ! ] Services stunnel4 restart"
service stunnel4 restart > /dev/null 2>&1
[[ -e /etc/init.d/stunnel4 ]] && /etc/init.d/stunnel4 restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services squid restart"
service squid restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services squid3 restart"
service squid3 restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services apache2 restart"
service apache2 restart > /dev/null 2>&1
[[ -e /etc/init.d/apache2 ]] && /etc/init.d/apache2 restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services openvpn restart"
service openvpn restart > /dev/null 2>&1
[[ -e /etc/init.d/openvpn ]] && /etc/init.d/openvpn restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services dropbear restart"
service dropbear restart > /dev/null 2>&1
[[ -e /etc/init.d/dropbear ]] && /etc/init.d/dropbear restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services ssh restart"
service ssh restart > /dev/null 2>&1
[[ -e /etc/init.d/ssh ]] && /etc/init.d/ssh restart > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] Services fail2ban restart"
( 
[[ -e /etc/init.d/ssh ]] && /etc/init.d/ssh restart
fail2ban-client -x stop && fail2ban-client -x start
) > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -e "$barra"
return
}

reiniciar_vps () {
echo -ne " \033[1;31m[ ! ] Sudo Reboot"
sleep 3s
echo -e "\033[1;32m [OK]"
(
sudo reboot
) > /dev/null 2>&1
echo -e "$barra"
return
}

host_name () {
unset name
while [[ ${name} = "" ]]; do
echo -ne "\033[1;37m $(fun_trans "Digite o nome do host"): " && read name
tput cuu1 && tput dl1
done
hostnamectl set-hostname $name 
if [ $(hostnamectl status | head -1  | awk '{print $3}') = "${name}" ]; then 
echo -e "\033[1;32m $(fun_trans "Nome de host alterado corretamente")!, $(fun_trans "reiniciar VPS")"
else
echo -e "\033[1;31m $(fun_trans "Nome de host n�o modificado")!"
fi
echo -e "$barra"
return
}

act_hora () {
echo -ne " \033[1;31m[ ! ] timedatectl"
timedatectl > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] timedatectl list-timezones"
timedatectl list-timezones > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] timedatectl list-timezones  | grep Santiago"
timedatectl list-timezones  | grep Santiago > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -ne " \033[1;31m[ ! ] timedatectl set-timezone America/Santiago"
timedatectl set-timezone America/Santiago > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -e "$barra"
return
}

cambiopass () {
echo -e "${cor[3]} $(fun_trans "Esta herramienta cambia la contraseña de su servidor vps")"
echo -e "${cor[3]} $(fun_trans "Esta contraseña es utilizada como usuario") root"
echo -e "$barra"
echo -e " $(fun_trans "Desea Seguir?")"
read -p " [S/N]: " -e -i n PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
echo -e "$barra"
#Inicia Procedimentos
echo -e "${cor[0]} $(fun_trans "Escriba su nueva contraseña")"
echo -e "$barra"
read  -p " Nuevo passwd: " pass
(echo $pass; echo $pass)|passwd 2>/dev/null
sleep 1s
echo -e "$barra"
echo -e "${cor[3]} $(fun_trans "Contraseña cambiada con exito!")"
echo -e "${cor[2]} $(fun_trans "Su contraseña ahora es"): ${cor[4]}$pass"
echo -e "$barra"
return
}

rootpass () {
echo -e "${cor[3]} $(fun_trans "Esta herramienta cambia a usuario root las vps de ")"
echo -e "${cor[3]} $(fun_trans "Googlecloud y Amazon esta configuracion solo")"
echo -e "${cor[3]} $(fun_trans "funcionan en Googlecloud y Amazon Puede causar")"
echo -e "${cor[3]} $(fun_trans "error en otras VPS agenas a Googlecloud y Amazon ")"
echo -e "$barra"
echo -e " $(fun_trans "Desea Seguir?")"
read -p " [S/N]: " -e -i n PROS
[[ $PROS = @(s|S|y|Y) ]] || return 1
echo -e "$barra"
#Inicia Procedimentos
echo -e "${cor[0]} $(fun_trans "Aplicando Configuracoes")"
fun_bar "service ssh restart"
#Parametros Aplicados
sed -i "s;PermitRootLogin prohibit-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
sed -i "s;PermitRootLogin without-password;PermitRootLogin yes;g" /etc/ssh/sshd_config
sed -i "s;PasswordAuthentication no;PasswordAuthentication yes;g" /etc/ssh/sshd_config
echo -e "$barra"
echo -e "${cor[0]} $(fun_trans "Escriba su nueva contraseña") root"
echo -e "$barra"
read  -p " Nuevo passwd: " pass
(echo $pass; echo $pass)|passwd 2>/dev/null
sleep 1s
echo -e "$barra"
echo -e "${cor[3]} $(fun_trans "Configuraciones aplicadas con exito!")"
echo -e "${cor[2]} $(fun_trans "Su contraseña ahora es"): ${cor[4]}$pass"
service ssh restart > /dev/null 2>&1
echo -e "$barra"
return
}

cleanreg () {
echo -ne " \033[1;31m[ ! ] Registro del limitador eliminado"
sudo rm -rf /etc/newadm/ger-user/Limiter.log > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -e "$barra"
return
}

gestor_fun () {
echo -e " ${cor[3]} $(fun_trans "ADMINISTRADOR VPS") ${cor[4]}[NEW-ADM]"
echo -e "$barra"
while true; do
echo -e "${cor[4]} [1] > \033[1;36m$(fun_trans "Atualizar pacotes")"
echo -e "${cor[4]} [2] > \033[1;36m$(fun_trans "Reiniciar os serviço")"
echo -e "${cor[4]} [3] > \033[1;36m$(fun_trans "Reiniciar VPS")"
echo -e "${cor[4]} [4] > \033[1;36m$(fun_trans "Alterar o nome do VPS")"
echo -e "${cor[4]} [5] > \033[1;36m$(fun_trans "Atualizar hora America-Santiago")"
echo -e "${cor[4]} [6] > \033[1;36m$(fun_trans "Cambiar contraseña ROOT del VPS")"
echo -e "${cor[4]} [7] > \033[1;36m$(fun_trans "Serviço ROOT para Googlecloud e Amazon")"
echo -e "${cor[4]} [8] > \033[1;36m$(fun_trans "Eliminar Registro del Limitador")"

echo -e "${cor[4]} [0] > ${cor[0]}$(fun_trans "VOLTAR")\n${barra}"
while [[ ${opx} != @(0|[1-8]) ]]; do
echo -ne "${cor[0]}$(fun_trans "Selecione a Opcao"): \033[1;37m" && read opx
tput cuu1 && tput dl1
done
case $opx in
	0)
	return;;
	1)
	update_pak
	break;;
	2)
	reiniciar_ser
	break;;
	3)
	reiniciar_vps
	break;;
	4)
	host_name
	break;;
	5)
	act_hora
	break;;
	6)
	cambiopass
	break;;
	7)
	rootpass
	break;;
	8)
	cleanreg
	break;;
esac
done
}
gestor_fun
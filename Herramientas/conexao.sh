#!/bin/bash
ram1=$(free -h | grep -i mem | awk {'print $2'})
ram2=$(free -h | grep -i mem | awk {'print $4'})
ram3=$(free -h | grep -i mem | awk {'print $3'})
uso=$(top -bn1 | awk '/Cpu/ { cpu = "" 100 - $8 "%" }; END { print cpu }')
system=$(cat /etc/MEUIPADM)

[[ ! -d /etc/SSHPlus ]] && mkdir /etc/SSHPlus > /dev/null 2>&1
link_bin="https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/ADM-ULTIMATE-NEW-FREE/master/Herramientas/proxy.py"
[[ ! -e /etc/SSHPlus/proxy.py ]] && wget -O /etc/SSHPlus/proxy.py ${link_bin} > /dev/null 2>&1 && chmod +x /etc/SSHPlus/proxy.py

[[ ! -e /etc/SSHPlus/Exp ]] && touch /etc/SSHPlus/Exp

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
comando[0]="$1"
comando[1]="$2"
 (
[[ -e $HOME/fim ]] && rm $HOME/fim
${comando[0]} > /dev/null 2>&1
${comando[1]} > /dev/null 2>&1
touch $HOME/fim
 ) > /dev/null 2>&1 &
 tput civis
echo -ne "\033[1;33mAGUARDE \033[1;37m- \033[1;33m["
while true; do
   for((i=0; i<18; i++)); do
   echo -ne "\033[1;31m#"
   sleep 0.1s
   done
   [[ -e $HOME/fim ]] && rm $HOME/fim && break
   echo -e "\033[1;33m]"
   sleep 1s
   tput cuu1
   tput dl1
   echo -ne "\033[1;33mAGUARDE \033[1;37m- \033[1;33m["
done
echo -e "\033[1;33m]\033[1;37m -\033[1;32m OK !\033[1;37m"
tput cnorm
}

verif_ptrs () {
porta=$1
PT=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
for pton in `echo -e "$PT" | cut -d: -f2 | cut -d' ' -f1 | uniq`; do
    svcs=$(echo -e "$PT" | grep -w "$pton" | awk '{print $1}' | uniq)
    [[ "$porta" = "$pton" ]] && {
    	echo -e "\n\033[1;31mPORTA \033[1;33m$porta \033[1;31mEM USO PELO \033[1;37m$svcs\033[0m"
    	sleep 3
    	fun_conexao
    }
done
}

fun_socks () {
	clear
    echo -e "\E[44;1;37m            GERENCIAR PROXY SOCKS             \E[0m"
    echo ""
    [[ $(netstat -nplt |grep 'python' | wc -l) != '0' ]] && {
        sks='\033[1;32mON'
        var_sks1="DESATIVAR SOCKS"
        echo -e "\033[1;33mPORTAS\033[1;37m: \033[1;32m$(netstat -nplt |grep 'python' | awk {'print $4'} |cut -d: -f2 |xargs)"
    } || {
        var_sks1="ATIVAR SOCKS"
        sks='\033[1;31mOFF'
    }
    echo ""
	echo -e "\033[1;31m[\033[1;36m1\033[1;31m] \033[1;37m• \033[1;33m$var_sks1\033[0m"
	echo -e "\033[1;31m[\033[1;36m2\033[1;31m] \033[1;37m• \033[1;33mABRIR PORTA\033[0m"
	echo -e "\033[1;31m[\033[1;36m3\033[1;31m] \033[1;37m• \033[1;33mALTERAR STATUS\033[0m"
	echo -e "\033[1;31m[\033[1;36m0\033[1;31m] \033[1;37m• \033[1;33mVOLTAR\033[0m"
	echo ""
	echo -ne "\033[1;32mOQUE DESEJA FAZER \033[1;33m?\033[1;37m "; read resposta
	if [[ "$resposta" = '1' ]]; then
		if ps x | grep proxy.py|grep -v grep 1>/dev/null 2>/dev/null; then
			clear
			echo -e "\E[41;1;37m             PROXY SOCKS              \E[0m"
			echo ""
			fun_socksoff () {
				for pidproxy in  `screen -ls | grep ".proxy" | awk {'print $1'}`; do
					screen -r -S "$pidproxy" -X quit
				done
				[[ $(grep -wc "proxy.py" /etc/autostart) != '0' ]] && {
		    		sed -i '/proxy.py/d' /etc/autostart
		    	}
				sleep 1
				screen -wipe > /dev/null
			}
			echo -e "\033[1;32mDESATIVANDO O PROXY SOCKS\033[1;33m"
			echo ""
			fun_bar 'fun_socksoff'
			echo ""
			echo -e "\033[1;32mPROXY SOCKS DESATIVADO COM SUCESSO!\033[1;33m"
			sleep 3
			fun_socks
		else
			clear
			echo -e "\E[44;1;37m             PROXY SOCKS              \E[0m"
		    echo ""
		    echo -ne "\033[1;32mQUAL PORTA DESEJA ULTILIZAR \033[1;33m?\033[1;37m: "; read porta
		    if [[ -z "$porta" ]]; then
		    	echo ""
		    	echo -e "\033[1;31mPorta invalida!"
		    	sleep 3
		    	clear
		    	fun_conexao
		    fi
		    verif_ptrs $porta
		    fun_inisocks () {
		    	sleep 1
		    	screen -dmS proxy python /etc/SSHPlus/proxy.py $porta
		    	[[ $(grep -wc "proxy.py" /etc/autostart) = '0' ]] && {
		    		echo -e "netstat -tlpn | grep python > /dev/null && echo 'ON' || screen -dmS proxy python /etc/SSHPlus/proxy.py $porta" >> /etc/autostart
		    	} || {
		            sed -i '/proxy.py/d' /etc/autostart
		            echo -e "netstat -tlpn | grep python > /dev/null && echo 'ON' || screen -dmS proxy python /etc/SSHPlus/proxy.py $porta" >> /etc/autostart
		        }
		    }
		    echo ""
		    echo -e "\033[1;32mINICIANDO O PROXY SOCKS\033[1;33m"
		    echo ""
		    fun_bar 'fun_inisocks'
		    echo ""
		    echo -e "\033[1;32mPROXY SOCKS ATIVADO COM SUCESSO\033[1;33m"
		    sleep 3
		    fun_socks
		fi
	elif [[ "$resposta" = '2' ]]; then
		if ps x | grep proxy.py|grep -v grep 1>/dev/null 2>/dev/null; then
			sockspt=$(netstat -nplt |grep 'python' | awk {'print $4'} |cut -d: -f2 |xargs)
			clear
			echo -e "\E[44;1;37m            PROXY SOCKS             \E[0m"
			echo ""
			echo -e "\033[1;33mPORTAS EM USO: \033[1;32m$sockspt"
			echo ""
			echo -ne "\033[1;32mQUAL PORTA DESEJA ULTILIZAR \033[1;33m?\033[1;37m: "; read porta
			if [[ -z "$porta" ]]; then
				echo ""
				echo -e "\033[1;31mPorta invalida!"
				sleep 3
				clear
				fun_conexao
			fi
			verif_ptrs $porta
			echo ""
			echo -e "\033[1;32mINICIANDO O PROXY SOCKS NA PORTA \033[1;31m$porta\033[1;33m"
			echo ""
			abrirptsks () {
				sleep 1
				screen -dmS proxy python /etc/SSHPlus/proxy.py $porta
				sleep 1
			}
			fun_bar 'abrirptsks'
			echo ""
			echo -e "\033[1;32mPROXY SOCKS ATIVADO COM SUCESSO\033[1;33m"
			sleep 3
			fun_socks
		else
			clear
			echo -e "\033[1;31mFUNCAO INDISPONIVEL\n\n\033[1;33mATIVE O SOCKS PRIMEIRO !\033[1;33m"
			sleep 2
			fun_socks
		fi
	elif [[ "$resposta" = '3' ]]; then
		if ps x | grep proxy.py|grep -v grep 1>/dev/null 2>/dev/null; then
			clear
			msgsocks=$(cat /etc/SSHPlus/proxy.py |grep -E "MSG =" | awk -F = '{print $2}' |cut -d "'" -f 2)
			echo -e "\E[44;1;37m             PROXY SOCKS              \E[0m"
			echo ""
			echo -e "\033[1;33mSTATUS: \033[1;32m$msgsocks"
			echo""
			echo -ne "\033[1;32mINFORME SEU STATUS\033[1;31m:\033[1;37m "; read msgg
			if [[ -z "$msgg" ]]; then
				echo ""
				echo -e "\033[1;31mStatus invalido!"
				sleep 3
				fun_conexao
			fi
			echo -e "\n\033[1;31m[\033[1;36m01\033[1;31m]\033[1;33m AZUL"
			echo -e "\033[1;31m[\033[1;36m02\033[1;31m]\033[1;33m VERDE"
			echo -e "\033[1;31m[\033[1;36m03\033[1;31m]\033[1;33m VERMELHO"
			echo -e "\033[1;31m[\033[1;36m04\033[1;31m]\033[1;33m AMARELO"
			echo -e "\033[1;31m[\033[1;36m05\033[1;31m]\033[1;33m ROSA"
			echo -e "\033[1;31m[\033[1;36m06\033[1;31m]\033[1;33m CYANO"
			echo -e "\033[1;31m[\033[1;36m07\033[1;31m]\033[1;33m LARANJA"
			echo -e "\033[1;31m[\033[1;36m08\033[1;31m]\033[1;33m ROXO"
			echo -e "\033[1;31m[\033[1;36m09\033[1;31m]\033[1;33m PRETO"
			echo -e "\033[1;31m[\033[1;36m10\033[1;31m]\033[1;33m SEM COR"
			echo ""
			echo -ne "\033[1;32mQUAL A COR\033[1;31m ?\033[1;37m : "; read sts_cor
			if [[ "$sts_cor" = "1" ]] || [[ "$sts_cor" = "01" ]]; then
				cor_sts='blue'
			elif [[ "$sts_cor" = "2" ]] || [[ "$sts_cor" = "02" ]]; then
				cor_sts='green'
			elif [[ "$sts_cor" = "3" ]] || [[ "$sts_cor" = "03" ]]; then
				cor_sts='red'
			elif [[ "$sts_cor" = "4" ]] || [[ "$sts_cor" = "04" ]]; then
				cor_sts='yellow'
			elif [[ "$sts_cor" = "5" ]] || [[ "$sts_cor" = "05" ]]; then
				cor_sts='#F535AA'
			elif [[ "$sts_cor" = "6" ]] || [[ "$sts_cor" = "06" ]]; then
				cor_sts='cyan'
			elif [[ "$sts_cor" = "7" ]] || [[ "$sts_cor" = "07" ]]; then
				cor_sts='#FF7F00'
			elif [[ "$sts_cor" = "8" ]] || [[ "$sts_cor" = "08" ]]; then
				cor_sts='#9932CD'
			elif [[ "$sts_cor" = "9" ]] || [[ "$sts_cor" = "09" ]]; then
				cor_sts='black'
			elif [[ "$sts_cor" = "10" ]]; then
				cor_sts='null'
			else
				echo -e "\n\033[1;33mOPCAO INVALIDA !"
				cor_sts='null'
			fi
			fun_msgsocks () {
				msgsocks2=$(cat /etc/SSHPlus/proxy.py |grep "MSG =" | awk -F = '{print $2}')
				sed -i "s/$msgsocks2/ '$msgg'/g" /etc/SSHPlus/proxy.py
				sleep 1
				cor_old=$(grep 'color=' /etc/SSHPlus/proxy.py | cut -d '"' -f2)
				sed -i "s/$cor_old/$cor_sts/g" /etc/SSHPlus/proxy.py

			}
			echo ""
			echo -e "\033[1;32mALTERANDO STATUS!"
			echo ""
			fun_bar 'fun_msgsocks'
			restartsocks () {
				if ps x | grep proxy.py|grep -v grep 1>/dev/null 2>/dev/null; then
				    echo -e "$(netstat -nplt |grep 'python' | awk {'print $4'} |cut -d: -f2 |xargs)" > /tmp/Pt_sks
					for pidproxy in  `screen -ls | grep ".proxy" | awk {'print $1'}`; do
						screen -r -S "$pidproxy" -X quit
					done
					screen -wipe > /dev/null
					_Ptsks="$(cat /tmp/Pt_sks)"
					sleep 1
					screen -dmS proxy python /etc/SSHPlus/proxy.py $_Ptsks
					rm /tmp/Pt_sks
				fi
			}
			echo ""
			echo -e "\033[1;32mREINICIANDO PROXY SOCKS!"
			echo ""
			fun_bar 'restartsocks'
			echo ""
			echo -e "\033[1;32mSTATUS ALTERADO COM SUCESSO!"
			sleep 3
			fun_socks
		else
			clear
			echo -e "\033[1;31mFUNCAO INDISPONIVEL\n\n\033[1;33mATIVE O SOCKS PRIMEIRO !\033[1;33m"
			sleep 2
			fun_socks
		fi
	elif [[ "$resposta" = '0' ]]; then
		echo ""
		echo -e "\033[1;31mRetornando...\033[0m"
		sleep 2
		fun_conexao
	else
		echo ""
		echo -e "\033[1;31mOpcao invalida !\033[0m"
		sleep 2
		fun_socks
	fi

}

fun_sslh () {
 [[ "$(netstat -nltp|grep 'sslh' |wc -l)" = '0' ]] && {
    clear
    echo -e "\E[44;1;37m             INSTALADOR SSLH               \E[0m\n"
    echo -e "\n\033[1;33m[\033[1;31m!\033[1;33m] \033[1;32mA PORTA \033[1;37m443 \033[1;32mSERA USADA POR PADRAO\033[0m\n"
	echo -ne "\033[1;32mREALMENTE DESEJA INSTALAR O SSLH \033[1;31m? \033[1;33m[s/n]:\033[1;37m "; read resp
	if [[ "$resp" = 's' ]]; then
        verif_ptrs 443
        fun_instsslh () {
            [[ -e "/etc/stunnel/stunnel.conf" ]] && ptssl="$(netstat -nplt |grep 'stunnel' | awk {'print $4'} |cut -d: -f2 |xargs)" || ptssl='3128'
            [[ -e "/etc/openvpn/server.conf" ]] && ptvpn="$(netstat -nplt |grep 'openvpn' |awk {'print $4'} |cut -d: -f2 |xargs)" || ptvpn='1194'
            DEBIAN_FRONTEND=noninteractive apt-get -y install sslh
            echo -e "#Modo autónomo\n\nRUN=yes\n\nDAEMON=/usr/sbin/sslh\n\nDAEMON_OPTS='--user sslh --listen 0.0.0.0:443 --ssh 127.0.0.1:22 --ssl 127.0.0.1:$ptssl --http 127.0.0.1:80 --openvpn 127.0.0.1:$ptvpn --pidfile /var/run/sslh/sslh.pid'" > /etc/default/sslh
            /etc/init.d/sslh start && service sslh start
        }
        echo -e "\n\033[1;32mINSTALANDO O SSLH !\033[0m\n"
        fun_bar 'fun_instsslh'
        echo -e "\n\033[1;32mINICIANDO O SSLH !\033[0m\n"
        fun_bar '/etc/init.d/sslh restart && service sslh restart'
        [[ $(netstat -nplt |grep -w 'sslh' | wc -l) != '0' ]] && echo -e "\n\033[1;32mINSTALADO COM SUCESSO !\033[0m" || echo -e "\n\033[1;31mERRO INESPERADO !\033[0m"
        sleep 3
        fun_conexao
     else
         echo -e "\n\033[1;31mRetornando.."
         sleep 2
         fun_conexao
     fi
  } || {
    clear
    echo -e "\E[41;1;37m             REMOVER O SSLH               \E[0m\n"
	echo -ne "\033[1;32mREALMENTE DESEJA REMOVER O SSLH \033[1;31m? \033[1;33m[s/n]:\033[1;37m "; read respo
    if [[ "$respo" = "s" ]]; then
	    fun_delsslh () {
	        /etc/init.d/sslh stop && service sslh stop
	        apt-get remove sslh -y
	        apt-get purge sslh -y
	     }
	    echo -e "\n\033[1;32mREMOVENDO O SSLH !\033[0m\n"
	    fun_bar 'fun_delsslh'
	    echo -e "\n\033[1;32mREMOVIDO COM SUCESSO !\033[0m\n"
	    sleep 2
	    fun_conexao
    else
	     echo -e "\n\033[1;31mRetornando.."
         sleep 2
         fun_conexao
    fi
  }
}

x="ok"
fun_conexao () {
while true $x != "ok"
do
clear
echo -e "\E[44;1;37m                MODO DE CONEXAO                 \E[0m\n"
echo -e "\033[1;32mSERVICO: \033[1;33mOPENSSH \033[1;32mPORTA: \033[1;37m$(grep 'Port' /etc/ssh/sshd_config|cut -d' ' -f2 |grep -v 'no' |xargs)" && sts6="\033[1;32m◉ "

[[ "$(netstat -nltp|grep 'sslh' |wc -l)" != '0' ]] && {
	echo -e "\033[1;32mSERVICO: \033[1;33mSSLH: \033[1;32mPORTA: \033[1;37m$(netstat -nplt |grep 'sslh' |awk {'print $4'} |cut -d: -f2 |xargs)"
	sts7="\033[1;32m◉ "
} || {
	sts7="\033[1;31m○ "
}

[[ "$(netstat -nplt |grep 'openvpn' |wc -l)" != '0' ]] && {
	echo -e "\033[1;32mSERVICO: \033[1;33mOPENVPN: \033[1;32mPORTA: \033[1;37m$(netstat -nplt |grep 'openvpn' |awk {'print $4'} |cut -d: -f2 |xargs)"
	sts5="\033[1;32m◉ "
} || {
	sts5="\033[1;31m○ "
}

[[ "$(netstat -nplt |grep 'python' |wc -l)" != '0' ]] && {
	echo -e "\033[1;32mSERVICO: \033[1;33mPROXY SOCKS \033[1;32mPORTA: \033[1;37m$(netstat -nplt |grep 'python' | awk {'print $4'} |cut -d: -f2 |xargs)"
	sts4="\033[1;32m◉ "
} || {
	sts4="\033[1;31m○ "
}
[[ -e "/etc/stunnel/stunnel.conf" ]] && {
	echo -e "\033[1;32mSERVICO: \033[1;33mSSL TUNNEL \033[1;32mPORTA: \033[1;37m$(netstat -nplt |grep 'stunnel' | awk {'print $4'} |cut -d: -f2 |xargs)"
	sts3="\033[1;32m◉ "
} || {
	sts3="\033[1;31m○ "
}
[[ "$(netstat -nltp|grep 'dropbear' |wc -l)" != '0' ]] && {
	echo -e "\033[1;32mSERVICO: \033[1;33mDROPBEAR \033[1;32mPORTA: \033[1;37m$(netstat -nplt |grep 'dropbear' | awk -F ":" {'print $4'} | xargs)"
	sts2="\033[1;32m◉ "
} || {
	sts2="\033[1;31m○ "
}
[[ "$(netstat -nplt |grep 'squid'| wc -l)" != '0' ]] && {
	echo -e "\033[1;32mSERVICO: \033[1;33mSQUID \033[1;32mPORTA: \033[1;37m$(netstat -nplt |grep 'squid' | awk -F ":" {'print $4'} | xargs)"
	sts1="\033[1;32m◉ "
} || {
	sts1="\033[1;31m○ "
}

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""

[\033[1;36m05\033[1;31m] \033[1;37m• \033[1;33mPROXY SOCKS $sts4\033[1;31m
[\033[1;36m07\033[1;31m] \033[1;37m• \033[1;33mSSLH MULTIPLEX $sts7\033[1;31m
[\033[1;36m08\033[1;31m] \033[1;37m• \033[1;33mVOLTAR \033[1;32m<\033[1;33m<\033[1;31m< \033[1;31m
[\033[1;36m00\033[1;31m] \033[1;37m• \033[1;33mSAIR \033[1;32m<\033[1;33m<\033[1;31m< \033[0m"
echo ""
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
tput civis
echo -ne "\033[1;32mOQUE DESEJA FAZER \033[1;33m?\033[1;31m?\033[1;37m "; read x
tput cnorm
clear
case $x in
	5|05)
	fun_socks
	;;
	7|07)
	fun_sslh
	;;
	8|08)
	menu
	;;
	0|00)
	echo -e "\033[1;31mSaindo...\033[0m"
	sleep 2
	clear
	exit;
	;;
	*)
	echo -e "\033[1;31mOpcao invalida !\033[0m"
	sleep 2
esac
done
}
fun_conexao
else
	rm -rf /bin/criarusuario /bin/expcleaner /bin/sshlimiter /bin/addhost /bin/listar /bin/sshmonitor /bin/ajuda /bin/menu /bin/OpenVPN /bin/userbackup /bin/tcpspeed /bin/badvpn /bin/otimizar /bin/speedtest /bin/trafego /bin/banner /bin/limit /bin/Usercreate /bin/senharoot /bin/reiniciarservicos /bin/reiniciarsistema /bin/attscript /bin/criarteste /bin/socks  /bin/DropBear /bin/alterarlimite /bin/alterarsenha /bin/remover /bin/detalhes /bin/mudardata /bin/botssh /bin/versao > /dev/null 2>&1
    rm -rf /etc/SSHPlus > /dev/null 2>&1
    clear
    exit 0
fi
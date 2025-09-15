!/usr/bin/env bash

# Script para Diagnóstico de Rede no Sistema Operacional Linux.
# Version  | 1.0
# Author   | Jefeson Alves
# Email    | jefesonbezerra@gmail.com
# Website  | https:helplan.wordpress.com

# Cores
NO_FORMAT="\033[0m"
YELLOW="\033[38;5;11m"
RED="\033[38;5;9m"
GREEN="\033[38;5;2m"

#Variáveis
nome_usuario=`whoami`
versao=`lsb_release -d | grep Description: | awk '{print $2 " "$4 " "$5}'`

#Inicio da execução
clear

opcoes=("Teste de ping" "Teste de rota" "Teste de porta" "Meu IPv4 Externo" "Meu IPv6 Externo" "Meu IPv4 Interno" "Meu IPv6 Interno" "Meu gateway IPv4" "Meu gateway IPv6" "Sair")

PS3="Digite uma opção: "

while true;
do
    printf '%.0s#' {1..60}; echo
    echo -e "# ${YELLOW}Script para diagnóstico de rede do Linux.${NO_FORMAT}$(printf '%17s' '#')"
    printf '#%58s#\n' ''
    echo -e "# ${YELLOW}Olá, $nome_usuario! Você está utilizando $versao.${NO_FORMAT}$(printf '%4s' '#')"
    printf '%.0s#' {1..60}; echo
    echo ""
    printf '%.0s#' {1..60}; echo
    echo -e "# ${YELLOW}Menu de Opções${NO_FORMAT}$(printf '%44s' '#')"
    printf '%.0s#' {1..60}; echo
    echo ""
    select opt in "${opcoes[@]}"
    do
        case $REPLY in
            1)
                read -p "Digite o endereço IP: " ip_destino
                ping -c 4 $ip_destino
                ;;
            2)
                read -p "Digite o endereço IP: " ip_destino
                traceroute $ip_destino
                ;;
            3)
                read -p "Digite o endereço IP: " ip_destino
                read -p "Digite a porta: " porta_destino
                nmap $ip_destino -p $porta_destino
                ;;
            4)
                ip_externo=`curl -s https://api.ipify.org`
                echo "Meu IPv4 externo: " $ip_externo
                ;;
            5)
                ip_externo=`curl -s https://api64.ipify.org`
                echo "Meu IPv6 externo: " $ip_externo
                ;;
            6)
                ip_interno=$(ip -o -4 addr show | while read -r num iface fam addr rest; do
                    echo "Interface: $iface -> IPv4: ${addr%/*}"
                done)
                echo ""
                echo "IPv4 das interfaces: "
                echo "$ip_interno"
                echo ""
                ;;
            7)
                ip_interno=$(ip -o -6 addr show | while read -r num iface fam addr rest; do
                    echo "Interface: $iface -> IPv6: ${addr%/*}"
                done)
                echo ""
                echo "IPv6 das interfaces: "
                echo "$ip_interno"
                echo ""
                ;;
            8)                
                gateway=`ip route show | grep default | awk '{print $3}'`
                echo "Meu Gateway IPv4:" $gateway
                ;;
            9)             
                gateway=`ip -6 route show | grep default | awk '{print $3}'`
                echo "Meu Gateway IPv6:" $gateway
                ;;
            9)
                echo "Saindo do menu..."
                exit
                ;;
            *)
                echo "Opção inválida. Tente novamente."
                ;;
        esac
        read -p "$(echo -e "${GREEN}Digite qualquer tecla para voltar ao Menu Principal...${NO_FORMAT}")"
        clear
        break
    done
done
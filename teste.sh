# Cores
# COLOR_DEFAULT="\033[0m"
# YELLOW="\033[38;5;11m"
# RED="\033[38;5;9m"
# GREEN="\033[38;5;2m"

# echo -e "# Script para diagnóstico de rede do Linux.$(printf "%10s\n" "#")"
# echo "teste"

# for TEXTO in "Script para diagnóstico de rede." "Olá, Jefeson" "Teste de conectividade"; do
#     printf "%-55s#\n" "$TEXTO"
# done


# Variável global (configuração)
# IP_GATEWAY_IPV4=192.168.20.1
# # Função para testar conectividade
# test_connectivity() {
#     local ip_gateway_ipv4=$1  # variável local (escopo da função)

#     if ping -4 -c 2 "$ip_gateway_ipv4" > /dev/null 2>&1; then
#         echo "Gateway IPv4 ($ip_gateway_ipv4) está acessível ✅"
#     else
#         echo "Gateway IPv4 ($ip_gateway_ipv4) não está acessível ❌"
#     fi
# }

# # Executa o teste
# test_connectivity "$IP_GATEWAY_IPV4"

#!/usr/bin/env bash

# Script para Diagnóstico de Rede no Sistema Operacional Linux.
# Version  | 1.0
# Author   | Jefeson Alves
# Email    | jefesonbezerra@gmail.com
# Website  | https:helplan.wordpress.com

# Cores
DEFAULT_COLOR="\033[0m"
YELLOW="\033[38;5;11m"
RED="\033[38;5;9m"
GREEN="\033[38;5;2m"

NOME_USUARIO=$(whoami)
VERSAO_LINUX=$(lsb_release -d | grep Description: | awk '{print $2 " "$4 " "$5}')
IP_GATEWAY_IPV4=$(ip route show | grep default | awk '{print $3}')
IP_GATEWAY_IPV6=$(ip -6 route show | grep default | awk '{print $3}')

read -p "Digite a url: " URL_TESTE
read -p "Digite a porta TCP(80 ou 443): " PORT_TESTE

DNS1_IPV4=$(grep "^nameserver" /etc/resolv.conf | awk '$2 ~ /^[0-9.]+$/ {print $2; exit}')
DNS2_IPV4=$(grep "^nameserver" /etc/resolv.conf | awk '$2 ~ /^[0-9.]+$/ {print $2}' | sed -n '2p')
DNS1_IPV6=$(grep "^nameserver" /etc/resolv.conf | awk '$2 ~ /:/{print $2}' | sed -n '1p')
DNS2_IPV6=$(grep "^nameserver" /etc/resolv.conf | awk '$2 ~ /:/{print $2}' | sed -n '2p')

clear

printf '%.0s-' {1..60}; echo
echo -e "| ${YELLOW}Script para diagnóstico de rede do Linux.${DEFAULT_COLOR}$(printf '%17s' '|')"
printf '|%58s|\n' ''
echo -e "| ${YELLOW}Olá, $NOME_USUARIO! Você está utilizando $VERSAO_LINUX.${DEFAULT_COLOR}$(printf '%4s' '|')"
printf '%.0s-' {1..60}; echo
printf '%.0s-' {1..60}; echo
echo -e "| ${YELLOW}Teste de conectividade${DEFAULT_COLOR}$(printf '%36s' '|')"
printf '%.0s-' {1..60}; echo

echo -e "| ${YELLOW}Os testes serão realizados com os parâmetros a seguir: ${DEFAULT_COLOR}$(printf '%4s' '|')"
printf '%.0s-' {1..60}; echo
echo ""
printf '%.0s-' {1..60}; echo
echo "| 1. Gateway IPv4: $IP_GATEWAY_IPV4$(printf '%30s' '|')"
echo "| 2. Gateway IPv6: $IP_GATEWAY_IPV6$(printf '%16s' '|')"
echo "| 3. Porta de teste: $PORT_TESTE$(printf '%30s' '|')"
echo "| 4. DNS IPv4 primário: $DNS1_IPV4$(printf '%23s' '|')"
echo "| 5. DNS IPv4 secundário: $DNS2_IPV4$(printf '%21s' '|')"
echo "| 6. DNS IPv6 primário: $DNS1_IPV6$(printf '%16s' '|')"
echo "| 7. DNS IPv6 secundário: $DNS2_IPV6$(printf '%14s' '|')"
echo "| 8. URL: $URL_TESTE$(printf '%37s' '|')"
printf '%.0s-' {1..60}; echo
echo ""

if ping -4 -c 4 "$IP_GATEWAY_IPV4" > /dev/null 2>&1; then
    echo "1. Gateway IPv4 - OK"
else
    echo "1. Falha no Gateway IPv4"
fi

if ping -6 -c 4 "$IP_GATEWAY_IPV6" > /dev/null 2>&1; then
    echo "2. Gateway IPv6: $IP_GATEWAY_IPV6 - OK"
else
    echo "2. Falha no Gateway IPv6: $IP_GATEWAY_IPV6"
fi

if ping -4 -c 4 "$URL_TESTE" > /dev/null 2>&1; then
    echo "3. DNS IPv4 - OK"
else
    echo "3. Falha no DNS IPv4"
fi

if ping -6 -c 4 "$URL_TESTE" > /dev/null 2>&1; then
    echo "4. DNS IPv6 - OK"
else
    echo "4. Falha no DNS IPv6"
fi

if timeout 3 bash -c "</dev/tcp/$URL_TESTE/$PORT_TESTE" 2>/dev/null; then
    echo "5. Acesso à internet - OK"
else
    echo "5. Falha no Acesso à internet"
fi

ping -4 -c 4 "$URL_TESTE" | grep 'rtt' | awk -F'/' '{print "6. Latência: " $6 " ms"}'
traceroute -6 "$URL_TESTE" | tail -n1 | awk '{print "7. Saltos: " $1}'

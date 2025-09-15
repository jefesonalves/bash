#!/usr/bin/env bash

# Script para Diagnóstico de Rede no Sistema Operacional Linux.
# Version  | 1.0
# Author   | Jefeson Alves
# Email    | jefesonbezerra@gmail.com
# Website  | https:helplan.wordpress.com

# ---------- Definie padrão de cores ----------
DEFAULT_COLOR="\033[0m"
YELLOW="\033[38;5;11m"
RED="\033[38;5;9m"
GREEN="\033[38;5;2m"

# ---------- Informa o Sistema Operacional ----------
NOME_USUARIO=$(whoami)
VERSAO_LINUX=$(lsb_release -d | awk -F"\t" '{print $2}')

# ---------- Define parâmetros de rede ----------
LATENCIA_ACEITAVEL=70

# ---------- Banner de apresentação ----------
clear
echo -e " ${YELLOW}Script para diagnóstico de rede do Linux.${DEFAULT_COLOR}"
echo -e " ${YELLOW}Olá, $NOME_USUARIO! Você está utilizando $VERSAO_LINUX.${DEFAULT_COLOR}"
echo ""

# ---------- Solicita ao usuário a URL ----------
while true; do
    read -p "Digite a URL: " URL_TESTE
    URL_TESTE=${URL_TESTE,,}  # converte para lowercase.

    # Realiza um ping para a URL e verifica se resolve o IP).
    if ping -c 1 -W 1 "$URL_TESTE" &> /dev/null; then
        break  # Se resolver o nome sai do loop.
    else
        echo "URL inválida! Digite uma URL válida." # Se não resolver o nome, pede novamente.
    fi
done

# ---------- Solicita ao usuário a porta ----------
while true; do
    read -p "Digite a porta TCP (0-65535): " PORT_TESTE
    
    # Verifica se é a porta está entre 0 e 65535
    if [[ "$PORT_TESTE" =~ ^[0-9]+$ ]] && [ "$PORT_TESTE" -ge 0 ] && [ "$PORT_TESTE" -le 65535 ]; then
        break  # Se a porta estiver no range sai do loop.
    else
        echo "Porta inválida! Digite um número entre 0 e 65535." # Se a porta não estiver no range, pede uma opção válida.
    fi
done

clear

# ---------- Obtém informações de rede ----------
echo -e "${YELLOW}Aguarde um instante...${DEFAULT_COLOR}"
IP_GATEWAY_IPV4=$(ip route show | awk '/default/ {print $3}')
IP_GATEWAY_IPV6=$(ip -6 route show | awk '/default/ {print $3}')
DNS1_IPV4=$(grep "^nameserver" /etc/resolv.conf | awk '$2 ~ /^[0-9.]+$/ {print $2; exit}')
DNS2_IPV4=$(grep "^nameserver" /etc/resolv.conf | awk '$2 ~ /^[0-9.]+$/ {print $2}' | sed -n '2p')
DNS1_IPV6=$(grep "^nameserver" /etc/resolv.conf | awk '$2 ~ /:/{print $2}' | sed -n '1p')
DNS2_IPV6=$(grep "^nameserver" /etc/resolv.conf | awk '$2 ~ /:/{print $2}' | sed -n '2p')
LATENCIA_IPV4=$(ping -4 -c 4 google.com | grep 'rtt' | awk -F'/' '{print $6}')
LATENCIA_INT_IPV4=${LATENCIA_IPV4%.*}
LATENCIA_IPV6=$(ping -6 -c 4 "$URL_TESTE" | grep 'rtt' | awk -F'/' '{print $6}')
LATENCIA_INT_IPV6=${LATENCIA_IPV6%.*}
SALTOS_IPV4=$(traceroute -4 "$URL_TESTE" | tail -n1 | awk '{print $1}')
SALTOS_IPV6=$(traceroute -6 "$URL_TESTE" | tail -n1 | awk '{print $1}')
clear

# ---------- Valida a execução dos testes de rede ----------
ping_test() {
    local target=$1
    local version=$2
    if ping -$version -c 1 "$target" > /dev/null 2>&1; then
        echo "Ok"
    else
        echo "Falha"
    fi
}

tcp_test() {
    local host=$1
    local port=$2
    if timeout 3 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
        echo "Ok"
    else
        echo "Falha"
    fi
}

latency_check() {
    local lat=$1
    local limite=$2
    if [ "$lat" -lt "$limite" ]; then
        echo "Latência Normal"
    else
        echo "Latência Alta"
    fi
}

# ---------- Exibe o resultado das informações de rede e da execução de testes de rede ----------
echo "1. Gateway IPv4 ($IP_GATEWAY_IPV4) - $(ping_test $IP_GATEWAY_IPV4 4)"
echo "2. Gateway IPv6 ($IP_GATEWAY_IPV6) - $(ping_test $IP_GATEWAY_IPV6 6)"
echo "3. Resolução de nome IPv4 ($URL_TESTE) - $(ping_test $URL_TESTE 4)"
echo "4. Resolução de nome IPv6 ($URL_TESTE) - $(ping_test $URL_TESTE 6)"
echo "5. Acesso ao $URL_TESTE na porta $PORT_TESTE - $(tcp_test $URL_TESTE $PORT_TESTE)"
echo "6. Latência IPv4: $LATENCIA_INT_IPV4 ms - $(latency_check $LATENCIA_INT_IPV4 $LATENCIA_ACEITAVEL)"
echo "7. Latência IPv6: $LATENCIA_INT_IPV6 ms - $(latency_check $LATENCIA_INT_IPV6 $LATENCIA_ACEITAVEL)"
echo "8. Saltos IPv4 até $URL_TESTE: $SALTOS_IPV4"
echo "9. Saltos IPv6 até $URL_TESTE: $SALTOS_IPV6"
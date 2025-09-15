!/usr/bin/env bash

# Script para Manutenção do Sistema Operacional Linux.
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

opcoes=("Verificar atualizações" "Atualizar pacotes" "Atualizar distribuição" "Remover pacotes desnecessários" "Atualizar Discord" "Limpar diretório Downloads" "Sair")

# echo "--------------------------------------------------------"
# echo -e "${YELLOW}Script para manutenção do Linux.${NO_FORMAT}"             
# echo "--------------------------------------------------------"
# echo -e "${YELLOW}Olá, $nome_usuario! Você está utilizando $versao.${NO_FORMAT}"
# echo "--------------------------------------------------------"

PS3="Digite uma opção: "
echo ""

while true;
do
    clear
    echo "--------------------------------------------------------"
    echo -e "${YELLOW}Script para manutenção do Linux.${NO_FORMAT}"             
    echo "--------------------------------------------------------"
    echo -e "${YELLOW}Olá, $nome_usuario! Você está utilizando $versao.${NO_FORMAT}"
    echo "--------------------------------------------------------"

    select opt in "${opcoes[@]}"
    do
        case $REPLY in
            1)
                echo "Verificando atualizações..."
                sudo apt-get update | tail -n 1
                ;;
            2)
                echo "Instalando atualizações de pacotes..."
                sudo apt-get upgrade | tail -n 1
                ;;
            3)
                echo "Realizando upgrade da distribuição..."
                sudo apt dist-upgrade
                ;;
            4)
                echo "Removendo pacotes desnecessários..."
                sudo apt autoremove
                ;;
            5)
                echo "Atualizando discord"
                url="https://discord.com/api/download?platform=linux&format=deb"
                curl -L -o /tmp/discord.deb $url
                sudo apt install /tmp/discord.deb
                cd /tmp/
                rm discord.deb
                ;;
            6)
                echo "Limpando o diretório Downloads..."
                cd ~/Downloads/
                rm -rf *
                ;;
            7)
                echo "Saindo do menu..."
                exit 0
                ;;
            *)
                echo "Opção inválida. Tente novamente."
                ;;
        esac
        read -p "$(echo -e "${GREEN}Digite qualquer tecla para voltar ao Menu Principal...${NO_FORMAT}")"
        break
    done
done

# 1. Ajustar o menu para exibir sempre que concluir uma opção
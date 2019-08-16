#!/bin/bash										
# Script de backup para VM's Xen-Server (VM's a QUENTE)		 
# Por: Tiago Silva Leite									 
# E-mail: tleite@bsd.com.br          						 
#-----------------------------------------------------------------------------------
# A informação que precisamos obter é o “Storage-Repository-UUID” de nosso servidor.
# Para isso, utilize o comando conforme ilustrado abaixo no console do xenserver.
# xe sr-list
# Executar em backgroud:  ex: /root/nome_do_script.sh &
# Verificação do log: tail -f /var/log/backup/vms/bkp-vm-individual-dd-mm-yyyy.log
# Agendamento na crontab: crontab -e 
# SHELL=/bin/bash
# PATH=/sbin:/bin:/usr/sbin:/usr/bin
# MAILTO=root 
# Example of job definition:
#  .---------------- minute (0 - 59)
#  | .------------- hour (0 - 23)
#  | | .---------- day of month (1 - 31)
#  | | | .------- month (1 - 12) OR jan,feb,mar,apr ...
#  | | | | .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
#  | | | | |
#  * * * * * user-name command to be executed
# Comando Lista VMs:  xe vm-list | grep "name-label" | grep -v "Control domain" | tr -s " " | cut -d " " -f 5 
######################################################################################

# VARIÁVEL PARA PEGAR AS VMS.
#vmname=`xe vm-list | grep "name-label" | grep -v "Control domain" | tr -s " " | cut -d " " -f 5` # Comando para listar as vms rodando.
#vmname=`cat /root/vmlist.txt`


vmname=COLOCAR AQUI O NOME DA VM


#for vm in $vmname; do
dhvm=`date "+%d %B %Y, %A - %H:%M:%S"`
#if test -d /var/log/backup/vms; then echo ""; else mkdir -p /var/log/backup/vms; fi;
log=/var/log/backup/vms/exportvm__${vmname}.log

# Estado do log Colorido
OK=`echo -e "\033[01;32m [ OK ]  \033[0m"`
NOK=`echo -e "\033[01;31m [ PROBLEMA ] \033[0m"`


mount -t cifs -o username=USER,password=PASS 'DIRECTORY SRC' DIRETOCTY DST
if [ $? -eq 0 ]; then
echo -e "1) Montagem de destino de vm: ${vmname}, em: ${dhvm} ${OK}"  >> $log
else
echo -e "[ Atenção ] Problemas na montagem da vm: ${vmname}, em: ${dhvm} ${NOK}" >> $log 
echo " " >> $log
echo " " >> $log
exit 1
fi

xe vm-shutdown vm=${vmname} force=true
if [ $? -eq 0 ]; then
echo -e "2) Desligou a vm: ${vmname} em: ${dhvm} ${OK}"  >> $log
else
echo -e "[ Atenção ] Problemas ao desligar a vm: ${vmname}, em: ${dhvm} ${NOK}" >> $log 
echo " " >> $log
echo " " >> $log
exit 1
fi

xe vm-export   vm=${vmname} filename=/mnt/vms/${vmname}.xva
if [ $? -eq 0 ]; then
echo -e "3) Export da vm: ${vmname} em: ${dhvm}" ${OK} >> $log
else
echo -e "[ Atenção ] Problemas ao exportar a vm: ${vmname} em: ${dhvm} ${NOK}" >> $log 
echo " " >> $log
echo " " >> $log
exit 1
fi

xe vm-start    vm=${vmname} 
if [ $? -eq 0 ]; then
echo -e "4) Iniciou a vm: ${vmname} em: ${dhvm} ${OK}"  >> $log
else
echo -e "[ Atenção ] Problemas ao desligar a vm: ${vmname} em: ${dhvm} ${NOK}" >> $log 
echo " " >> $log
echo " " >> $log
exit 1
fi

umount /mnt/vms/
if [ $? -eq 0 ]; then
echo -e "5) Desmontou com sucesso  em: ${dhvm} ${OK}"  >> $log
else
echo -e "[ Atenção ] Problemas ao desmontar em: ${dhvm} ${NOK}" >> $log 
echo " " >> $log
echo " " >> $log
exit 1
fi
#done;
exit 0

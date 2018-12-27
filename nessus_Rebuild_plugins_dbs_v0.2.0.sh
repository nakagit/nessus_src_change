#!/bin/sh

############## How to use ##############
# ./nessus_Rebuild_plugins_dbs.sh
# Version: 0.2.0 (2009.07.01 17:45)
#  for CentOS
##############################################
declare plugins_code_db_before plugins_code_db_after
declare plugins_desc_db_before plugins_desc_db_after
declare plugins_desc_db_diff plugins_desc_db_diff

##################################################################################
# Stop Nessus Service
##################################################################################
echo -n "Will you stop Nessus Service? (yes/no)   [y]"
read ans
  case $ans in
    y|Y|[Yy]es|YES|"")
    echo "Stop Nessus Service NOW!"
    service nessusd stop
    echo "Nessus Service stopped sucessfully!"
    echo ""
    ;;

    n|N|[Nn]o|NO)
    exit
    ;;

    *)
    echo "Input mistakes found!"
    echo "Input a single character   'y' or 'n'. "
    ;;
  esac
set $ans=""


##################################################################################
# Delete "Nessus plugins_db"s
#     /opt/nessus/var/nessus/plugins-code.db
#     /opt/nessus/var/nessus/plugins-desc.db
##################################################################################
echo "Will you delete Nessus plugins_db files? "
echo -n "Nessus plugins_db files are 'plugins-code.db' and 'plugins-desc.db'.  (yes/no)   [y] "
read ans
  case $ans in
    y|Y|[Yy]es|YES|"")
      if [ -f /opt/nessus/var/nessus/plugins-code.db ] && [ -f /opt/nessus/var/nessus/plugins-desc.db ] ; then
      echo "Deleting following Nessus plugins_dbs NOW!"
      echo "  /opt/nessus/var/nessus/plugins-code.db"
      echo "  /opt/nessus/var/nessus/plugins-desc.db"
      rm -f /opt/nessus/var/nessus/plugins-code.db /opt/nessus/var/nessus/plugins-desc.db
      echo "2 Nessus plugins_dbs has deleted!"
      else
      echo "[Error]  Not found 'plugins-code.db' and/or 'plugins-desc.db'!"
      fi
    echo ""
    ;;

    n|N|[Nn]o|NO)
    echo "No delete Nessus plugins_dbs."
    exit
    ;;

    *)
    echo "Input mistakes found!"
    echo "Input a single character   'y' or 'n'. "
    ;;
  esac
set $ans=""


##################################################################################
# Start Nessus Service (= Rebuild Nessus plugins_db)
##################################################################################
echo -n "Will you start Nessus Service? (yes/no)   [y]"
read ans
  case $ans in
    y|Y|[Yy]es|YES|"")
    echo "Starting Nessus Service NOW."
    echo "It may takes 10 minutes or so. Please be patient..."
    echo "It depends on your PC performance."
    echo "Nessus will rebuild both 'plugins-code.db' and 'plugins-desc.db' NOW."
    service nessusd start
    sleep 7
    echo "Nessus Service started sucessfully!"
    echo ""
    ;;

    n|N|[Nn]o|NO)
    exit
    ;;

    *)
    echo "Input mistakes found!"
    echo "Input a single character   'y' or 'n'. "
    ;;
  esac
set $ans=""

#==========================================================
# Nessus plugin DB check
#==========================================================
i=0
plugins_code_db_diff=1; plugins_desc_db_diff=1
plugins_code_db_before=0; plugins_desc_db_before=0

echo "Rebuilding Nessus plugin DBs (plugins-code.db, plugins-desc.db). Please wait..."
echo "----------------------------------------"
echo "File Name                  File Size"
echo "----------------------------------------"

while true i=0
do
  if [ ${plugins_code_db_diff} -eq 0 ] && [ ${plugins_desc_db_diff} -eq 0 ];then
  echo "Nessus plugin DBs are updated!!"
  echo ""
  exit
  else
  ls -al /opt/nessus/var/nessus/|grep -w plugins-code.db | awk '{printf "%s %20d\n", $9,$5}'
  plugins_code_db_after=`ls -al /opt/nessus/var/nessus/|grep -w plugins-code.db | awk '{print $5}'`
  ls -al /opt/nessus/var/nessus/|grep -w plugins-desc.db | awk '{printf "%s %20d\n", $9,$5}'
  plugins_desc_db_after=`ls -al /opt/nessus/var/nessus/|grep -w plugins-desc.db | awk '{print $5}'`
  plugins_code_db_diff=`expr ${plugins_code_db_after} - ${plugins_code_db_before}`
  plugins_desc_db_diff=`expr ${plugins_desc_db_after} - ${plugins_desc_db_before}`
  plugins_code_db_before=${plugins_code_db_after}
  plugins_desc_db_before=${plugins_desc_db_after}
  fi
echo ""
sleep 10
done

# END

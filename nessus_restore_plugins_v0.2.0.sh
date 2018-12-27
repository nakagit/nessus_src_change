#!/bin/sh

declare -a OS

############## How to use #########################################
# ./nessus_restore_plugins.sh
# Version: 0.2.0 (2009.05.03 15:50)
#  for Fedora & CentOS
###################################################################

#=================================================================================
# OS detection
#=================================================================================
OS=`more /proc/version|awk '{
if (/centos/) {print "centos"}
if (/fedora/) {print "fedora"}
}'`
#echo "OS="${OS}

##################################################################################
# Delete Nessus plugins (/opt/nessus/lib/nessus/plugins)
##################################################################################
echo -n "Will you delete all Nessus plugins? (yes/no)   [y]  "
read ans
  case $ans in
    y|Y|[Yy]es|YES|"")
      if [ -d /opt/nessus/lib/nessus/plugins ]; then
      echo "Delete Nessus plugins NOW!"
      rm -rf /opt/nessus/lib/nessus/plugins
      echo "All plugins has deleted!"
      else
      echo "Not found /opt/nessus/lib/nessus/plugins direcotry"
      fi
    echo ""
    ;;

    n|N|[Nn]o|NO)
    echo "No delete Nessus plugins."
    ;;

    *)
    echo "Input mistakes found!"
    echo "Input a single character   'y' or 'n'. "
    ;;
  esac
set $ans=""


##################################################################################
# Restore Nessus plugins (/opt/nessus/lib/nessus/plugins)
##################################################################################
echo -n "Will you restore Nessus plugins? (yes/no)   [y]  "
read ans
  case $ans in
    y|Y|[Yy]es|YES|"")
      if [ -d /opt/nessus/lib/nessus ]; then
      cd /opt/nessus/lib/nessus
      echo "-------------------------------------------------------------"
      echo "Timestamp	File size	File name"
      echo "-------------------------------------------------------------"
        if [ "${OS}" = "centos" ]; then
        ls -l *.tar.gz | sort -r -k 9|awk '{print $6,$7,$8,"	"$5,"	"$9}'
        elif [ "${OS}" = "fedora" ]; then
        ls -l *.tar.gz | sort -r -k 8|awk '{print $6,$7,"	"$5,"	"$8}'
        fi
     echo "-------------------------------------------------------------"
      echo ""
        if [ "${OS}" = "centos" ]; then
        latest_backup=`ls -l *.tar.gz | sort -r -k 9 |xargs|awk '{print $9}'`
        elif [ "${OS}" = "fedora" ]; then
        latest_backup=`ls -l *.tar.gz | sort -r -k 8 |xargs|awk '{print $8}'`
        fi
      echo -n "Will you restore "[${latest_backup}] " (yes/no)   [y]  "
      read latest_backup_yn
        case $latest_backup_yn in
          y|Y|[Yy]es|YES|"")
          echo "Restoring Nessus plugins NOW..."
          tar xzf ${latest_backup}
          echo "All plugins has restored!!"
           ;;

          n|N|[Nn]o|NO)
          echo "Indicate Nessus plugins Backup file name as following:"
          echo "xxxx_xxxx_plugins.tar.gz"
          read backup_plugins
          echo ""
            if [ -f /opt/nessus/lib/nessus/${backup_plugins} ]; then
            echo "Restoring Nessus plugins NOW..."
            tar xzf ${backup_plugins}
            echo "All plugins has restored!!"
            else
            echo "Nessus plugins Backup not found at /opt/nessus/lib/nessus/${backup_plugins}"
            exit
            fi        
           ;;

           *)
          echo "Invalid input!"
          echo "Input a single character   'y' or 'n'. "
           ;;
        esac

      fi
    echo ""
    ;;

    n|N|[Nn]o|NO)
    echo "No restoring Nessus plugins."
    ;;
  esac

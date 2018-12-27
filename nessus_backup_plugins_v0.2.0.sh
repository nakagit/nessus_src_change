#!/bin/sh

############## How to use ########################################
# ./nessus_backup_plugins.sh
# Version: 0.2.0 (2009.05.03 15:30) 
#  for Fedora & CentOS
###################################################################
DATE=`date +%m%d`
TIME=`date +%H%M`

##################################################################################
# Backup Nessus plugin folder
##################################################################################
echo "Backup Nessus plugins?"
echo "Backup Location and File name: /opt/nessus/lib/nessus/<DATE>_<TIME>_plugins.tar.gz"
echo -n "Will you backup 'Nessus plugins'?(yes/no)   [y]  "
read ans
echo ""
  case $ans in
    y|Y|[Yy]es|YES|"")
      if [ ! -d /opt/nessus/lib/nessus/plugins ]; then
      echo "No directories found: /opt/nessus/lib/nessus/plugins"
      echo ""
      else 
      echo "Backup 'Nessus plugins' directory."
        if [ -d /opt/nessus/lib/nessus ] && [ -d /opt/nessus/lib/nessus/plugins ]; then
        tar czf /opt/nessus/lib/nessus/${DATE}_${TIME}_plugins.tar.gz -C /opt/nessus/lib/nessus plugins
          if [ $? -eq 0 ]; then
          echo "Backup completed successfully!"
          else
          echo "Failed to backup. "
          fi
        fi
      fi
    echo ""
    ;;

    n|N|[Nn]o|NO)
    echo "No execute Backup."
    echo ""
    ;;

    *)
    echo "Input mistakes found!"
    echo "Input a single character   'y' or 'n'. "
    echo ""
    ;;
  esac

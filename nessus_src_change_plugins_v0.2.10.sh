#!/bin/sh

################ How to Use #########################
# ./nessus_src_change_plugins.sh <Source Port>
# Version: 0.2.10 (2010. 5.13) 12:20
#  for Fedora & CentOS
#############################################################

#=================================================================================
# OS detection
#=================================================================================
OS=`more /proc/version|awk '{
if (/centos/) {print "centos"}
if (/fedora/) {print "fedora"}
}'`
#echo "OS="${OS}


### HELP ###
if ([ "$1" = "--help" ]||[ "$1" = "" ]); then
echo ""
echo "/nessus_src_change_plugins.sh <Mode> abstraction"
echo "(1)<Mode> = Normal   [Approx. 33 mins]"
echo "   1) Console Progress"
echo "   2) Detailed Log files"
echo "   Example(1): <Source Port> = 53 and <Mode> = Normal"
echo "   ./nessus_src_change_plugins.sh 53"
echo ""
echo "(2)<Mode> = Quick   [Approx. 26 mins]"
echo "   1) NO Console Progress"
echo "   2) Detailed Log files"
echo "   Example(2): <Source Port> = 53 and <Mode> = Quick"
echo "   ./nessus_src_change_plugins.sh 53 quick"
echo ""
echo "(3)<Mode> = Very Quick   [Approx. 17 mins]"
echo "   1) NO Console Progress"
echo "   2) Small Log files"
echo "   Example(3): <Source Port> = 53 and <Mode> = Very Quick"
echo "   ./nessus_src_change_plugins.sh 53 vq"
echo ""
echo "=========================================================="
echo "Usage: ./nessus_src_change_plugins.sh <Source Port> <Mode>"
echo "=========================================================="
echo ""
exit
fi

### Replaced Source Port Number ###
if [ $# -eq 0 ]; then
echo ""
echo "Usage: ./nessus_src_change_plugins.sh <Source Port> <Mode>"
echo "For more Information: ./nessus_src_change_plugins.sh --help"
echo ""
exit
fi

if ([ "$2" = "quick" ] || [ "$2" = "vq" ] || [ -z "$2" ]); then
echo ""
else 
echo "2nd Parameter Error!"
echo "Usage: ./nessus_src_change_plugins.sh <Source Port> <Mode>"
echo "  Example(1): <Source Port> = 53 and <Mode> = Normal"
echo "    ./nessus_src_change_plugins.sh 53"
echo "  Example(2): <Source Port> = 53 and <Mode> = Quick"
echo "    ./nessus_src_change_plugins.sh 53 quick"
echo "  Example(3): <Source Port> = 53 and <Mode> = Very Quick"
echo "    ./nessus_src_change_plugins.sh 53 vq"
echo ""
exit
fi


########################################
# Initialization
########################################
declare -i row=0 port_num=0 row_count=0 x=0 port_num=0 temp_no=0
declare -i files_replaced=0 nasl_files=0 inc_files=0 all_files=0 nes_files=0 nbin_files=0
declare -i START_TIME_h=0 START_TIME_m=0 START_TIME_s=0 START_TIME_all=0
declare -i END_TIME_h=0 END_TIME_m=0 END_TIME_s=0 END_TIME_all=0
declare -i Elapsed_time=0 Elapsed_time_h=0 Elapsed_time_m=0 Elapsed_time_s=0
declare -i Elapsed_time_h_mod=0 Elapsed_time_m_mod=0 Elapsed_time_s_mod=0
declare -i org_file_size=0 replaced_file_size=0 error_count=0
declare -a port_num_array row_num_array mode temp

src_port=$1
mode=$2

#################################################
# sleep time configuration
#  Eg. sleep time = 2 sec
#      sleep_com="sleep(2);"
#      sleep_com_bs="sleep\(2\);"
#################################################
sleep_com="sleep(2);"
sleep_com_bs="sleep\(2\);"

DATE=`date +%m%d`
TIME=`date +%H%M`
START_TIME=`date +%H:%M:%S`
date 2>&1 | tee ${DATE}_${TIME}_replace.txt
echo "" 2>&1 | tee -a ${DATE}_${TIME}_replace.txt

#################################################
# Function(IsNumeric)
# Strings are Numeric or Characteristics?
#################################################
IsNumeric() {
  if [ $# -ne 1 ]; then
  return 1
  fi
expr "$1" + 1 > /dev/null 2>&1
  if [ $? -ge 2 ]; then
  return 1
  fi
return 0
}

#################################################
# Function(IsEvenOdd)
# Numbers are Even or Odd?
# Even -> 0
# Odd  -> 1
#################################################
IsEvenOdd() {
  if [ $# -ne 1 ]; then
  return 1
  fi
    if [ `expr "$1" % 2` -eq 0 ]; then
    echo "Even"
    return 0
    else
    echo "Odd"
    fi
  return 1
}

######################################################################
# Backup plugins Folder 
#   (/opt/nessus/lib/nessus/plugins)
######################################################################
echo "Backup Nessus plugins?"
echo "Backup Location and File name: /opt/nessus/lib/nessus/<DATE>_<TIME>_plugins.tar.gz"
#echo -n "Will you backup 'Nessus plugins'?(yes/no)   [y]  "
echo -n "Will you backup 'Nessus plugins'?(yes/no)   [n]  "
read ans
echo ""
  case $ans in
  y|Y|[Yy]es|YES)
#    y|Y|[Yy]es|YES|"")
    if [ -d /opt/nessus/sbin/nessus-update-plugins ]; then
    echo "No directories found: /opt/nessus/lib/nessus/plugins "
    echo ""
    else 
    echo "Backup 'Nessus plugins' direcotry."
      if [ -d /opt/nessus/lib/nessus ] && [ -d /opt/nessus/lib/nessus/plugins ]; then
      tar czf  /opt/nessus/lib/nessus/${DATE}_${TIME}_plugins.tar.gz -C /opt/nessus/lib/nessus plugins
        if [ $? -eq 0 ]; then
        echo "Backup complted successfully!"
        else
        echo "Failed to backup. "
        fi
      fi
    fi
    echo ""
  ;;

  n|N|[Nn]o|NO|"")
#    n|N|[Nn]o|NO)
  echo "No execute Backup."
  echo ""
  ;;

  *)
  echo "Invalid Input!"
  echo "Input a single character   'y' or 'n'. "
  echo ""
  ;;
  esac

set $ans=""


######################################################################
# Confirmation of start replacing plugins.
######################################################################
echo -n "Will you start replacing plugins?(yes/no)   [y]  "
read ans
echo ""
  case $ans in
  y|Y|[Yy]es|YES|"")
  echo "Started replacing plugins. Please be patient..."
  echo ""
  ;;

  n|N|[Nn]o|NO)
  echo "Stopped replacing plugins."
  echo ""
  exit
  ;;

  *)
  echo "Invalid Input!"
  echo "Input a single character   'y' or 'n'. "
  echo ""
  ;;
  esac

set $ans=""


########################################
# Main 
########################################
echo "Source Port = "$src_port 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
  if [ -z "${mode}" ]; then
  echo "Mode = Normal" 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
  else
  echo "Mode = "$mode 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
  fi
echo "" 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
if ([ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]); then
echo "Please be patient..."
else 
echo "-----------------------------------------------------------" 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
echo "#### Replaced Files ####" 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
fi

for file in /opt/nessus/lib/nessus/plugins/*
do
case $file in

#################################################
# Out of Replace target plugins
#################################################
*/Slackware*.nasl|*/aix_I*.nasl|*/aix_U*.nasl|*/centos_RHSA-*.nasl|*/debian_DSA-*.nasl|*/fedora_2*.nasl|*/freebsd_pkg_*.nasl|*/gentoo_GLSA-*.nasl|*/hpux_P*.nasl|*/macosx_*.nasl|*/mandrake_MD*.nasl|*/redhat-RHSA-*.nasl|*/solaris10_*.nasl|*/solaris10_x86_*.nasl|*/solaris251_*.nasl|*/solaris26_*.nasl|*/solaris7_*.nasl|*/solaris8_*.nasl|*/solaris9_*.nasl|*/suse_SA_*.nasl|*/ubuntu_USN-*.nasl|*/blacklist*.inc|*/*.nes|*/*.nbin)
#"${non_target_plugins}")
;;

#################################################
# Replace target plugins
#################################################
*)
#*/3proxy_logurl_overflow.nasl|*/2bgal_sql_injection.nasl|*/3com_switches.nasl|*/JM_urcs.nasl|*/PC_anywhere.nasl|*/PC_anywhere_tcp.nasl|*/ajp_detect.nasl|*/amanda_detect.nasl|*/arkoon.nasl|*/bind_authors.nasl|*/bind_query.nasl|*/check_smtp_helo.nasl|*/communigatepro_overflow.nasl|*/dns_xfer.nasl|*/fake_identd.nasl|*/find_ap.nasl|*/smb_activex_func.inc|*/04webserver.nasl|*/12planet_chat_server_path_disclosure.nasl|*/CSCdw50657.nasl|*/PGPCert_DoS.nasl|*/PHPAdsNew.nasl|*/amanda_detect.nasl|*/arkoon.nasl|*/aventail_asap.nasl|*/ccproxy_detect.nasl|*/cifs445.nasl|*/http_info.nasl|*/kerio_firewall_admin_port.nasl|*/kerio_wrf_management_detection.nasl|*/ovcm_notify_daemon_detect.nasl|*/ssl_deprecated.nasl|*/ssl_supported_ciphers.nasl|*/winmail_42b0824.nasl|*/ypupdated_remote_exec.nasl|*/raptor_detect.nasl|*/postgresql_detect.nasl|*/perl_cgi.nasl)
#*/postgresql_detect.nasl)
#*/winmail_42b0824.nasl|*/winmail_43b0302.nasl)
#*/perl_cgi.nasl)
#*/04webserver.nasl)
#*/http_info.nasl|*/cifs445.nasl|*/kerio_winroute_admin_port.nasl)
#*.nasl|*.inc)
#"${target_plugins}")

#################################################
# Replaced files (Log) 
#   ${DATE}_${TIME}_replace.txt
#################################################
if [ "${mode}" = "quick" ]; then
temp=`echo "${file}" 2>&1 | tee -a ${DATE}_${TIME}_replace.txt`
elif  [ -z "${mode}" ]; then
echo "${file}" 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
fi

####################################################################################################
# List replace target plugins
####################################################################################################
########################################################################
# Pattern(1)(TCP)  port = get_http_port(default:80);
#                  port = xxxx(default:yyy);
########################################################################
if [ "${mode}" = "quick" ]; then
temp=`awk '(/^port/||/^[ ]+port/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/[ ]/||//||/.*/) && (/default:[0-9]+);$/) {print "   "NR":"$0}' $file 2>&1 | tee -a ${DATE}_${TIME}_replace.txt`
elif  [ -z "${mode}" ]; then
awk '(/^port/||/^[ ]+port/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/[ ]/||//||/.*/) && (/default:[0-9]+);$/) {print "   "NR":"$0}' $file 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
fi

########################################################################
# Pattern(2)(TCP)  port = get_unknown_svc(3465);
########################################################################
if [ "${mode}" = "quick" ]; then
temp=`awk '(/^port/||/^[ ]+port/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/[ ]/||//||/.*/) && (/get_unknown_svc/) && (/[ ]/||//) && (/[0-9]+);$/) {print "   "NR":"$0}' $file 2>&1 | tee -a ${DATE}_${TIME}_replace.txt`
elif  [ -z "${mode}" ]; then
awk '(/^port/||/^[ ]+port/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/[ ]/||//||/.*/) && (/get_unknown_svc/) && (/[ ]/||//) && (/[0-9]+);$/) {print "   "NR":"$0}' $file 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
fi

################################################################
# Pattern(3)(TCP)  soc = open_sock_tcp(port);
#                  soc1 = open_sock_tcp(port);
#                  soc2 = open_sock_tcp(port);
#                  soc3 = open_sock_tcp(port);
#                  soc25 = open_sock_tcp(port);
#                  s = open_sock_tcp(port);
#[raptor_detect.nasl] socwww = open_sock_tcp(port);
#[smb_activex_func.inc] _acx_soc = open_sock_tcp(port); 
################################################################
################################################################
# Pattern(4)(UDP)  soc = open_sock_udp(port);
#                  soc1 = open_sock_udp(port);
#                  soc2 = open_sock_udp(port);
#                  soc3 = open_sock_udp(port);
#                  soc25 = open_sock_udp(port);
#                  s = open_sock_udp(port);
#                  socwww = open_sock_udp(port);
################################################################
if [ "${mode}" = "quick" ]; then
temp=`awk '(/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^socwww/||/^[ ]+socwww/||/^_acx_soc/||/^[ ]+_acx_soc/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\(port\);$/) {print "   "NR":"$0}' $file 2>&1 | tee -a ${DATE}_${TIME}_replace.txt`
elif  [ -z "${mode}" ]; then
awk '(/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^socwww/||/^[ ]+socwww/||/^_acx_soc/||/^[ ]+_acx_soc/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\(port\);$/) {print "   "NR":"$0}' $file 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
fi

################################################################
# Pattern(5)(TCP)  soc = open_sock_tcp(80);
################################################################
################################################################
# Pattern(6)(UDP)  soc = open_sock_udp(123);
################################################################
if [ "${mode}" = "quick" ]; then
temp=`awk '(/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\([0-9]+\);$/) {print "   "NR":"$0}' $file 2>&1 | tee -a ${DATE}_${TIME}_replace.txt`
elif  [ -z "${mode}" ]; then
awk '(/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\([0-9]+\);$/) {print "   "NR":"$0}' $file 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
fi

if [ "${mode}" = "quick" ]; then
temp=`echo "" 2>&1 | tee -a ${DATE}_${TIME}_replace.txt`
elif  [ -z "${mode}" ]; then
echo "" 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
fi



#########################################################################
# Replacement(1)  Before: port = get_http_port(default:80);
#                 After:  # port = get_http_port(default:80);
#                         port = 80;
#########################################################################
port_num=0; row_count=0; row=0
cp -pr $file c01.txt

#=================================================================
# Add "#"
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
mv c01.txt c02.txt
else
awk '{
if ((/^port/||/[ ]+port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/[ ]/||//||/.*/) && (/default:[0-9]+);$/))
if      (/^port/)     {gsub(/^port/,"# port",$0)}
else if (/^[ ]+port/) {gsub(/^[ ]+port/,"# port",$0)}
else if ((/^if/) && (/default:[0-9]+);$/))  {gsub(/^if/,"# if",$0)}
{print $0}
}' c01.txt > c02.txt
fi

#=================================================================
# Count replace rows
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
row_count=`awk '{
if ((/^port/||/[ ]+port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/[ ]/||//||/.*/) && (/default:[0-9]+);$/)) 
{print NR}
}' c02.txt|wc -l`
else
row_count=`awk '{
if ((/^# port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/[ ]/||//||/.*/) && (/default:[0-9]+);$/)) 
{print NR}
}' c02.txt|wc -l`
fi

if [ -z ${row_count} ]; then
row_count=0
fi

case ${row_count} in
0) ####### row_count = 0 #######
cp -pr $file c03.txt
;;

1) ####### row_count = 1 #######
#=================================================================
# Search the Row number for replacement.
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
row=`awk '{
if ((/^port/||/[ ]+port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/[ ]/||//||/.*/) && (/default:[0-9]+);$/)) 
if ((/get_http_port/) && (/[ ]/||//) && (/default:/)) {print NR}
else if ((/port/) && (/[ ]/||//) && (/default:/)) {print NR}
}' c02.txt`
else
row=`awk '{
if ((/^# port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/[ ]/||//||/.*/) && (/default:[0-9]+);$/)) 
if ((/get_http_port/) && (/[ ]/||//) && (/default:/)) {print NR}
else if ((/port/) && (/[ ]/||//) && (/default:/)) {print NR}
}' c02.txt`
row=${row}+1
fi


#=================================================================
# Search the Port number for replacement.
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
port_num=`awk '{
if ((/^port/||/[ ]+port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/[ ]/||//||/.*/) && (/default:[0-9]+);$/)) 
if ((/get_http_port/) && (/[ ]/||//) && (/default:/)) {print $0}
else if ((/port/) && (/[ ]/||//) && (/default:/)) {print $0}
}' c02.txt|cut -d: -f2|cut -d")" -f1|awk '/[0-9]+/ {print $0}'`
else
port_num=`awk '{
if ((/^# port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/[ ]/||//||/.*/) && (/default:[0-9]+);$/)) 
if ((/get_http_port/) && (/[ ]/||//) && (/default:/)) {print $0}
else if ((/port/) && (/[ ]/||//) && (/default:/)) {print $0}
}' c02.txt|cut -d: -f2|cut -d")" -f1|awk '/[0-9]+/ {print $0}'`
fi

#=================================================================
# Insert the Port number for replacement.@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#=================================================================
if [ -z ${port_num} ]; then
cp -pr c02.txt c03.txt
elif [ ! ${port_num} -eq 0 ] && [ ! ${row} -eq 1 ] && ([ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]); then
sed -e "${row}s/^/port = "${port_num}";\n#/" c02.txt > c03.txt
elif [ ! ${port_num} -eq 0 ] && [ ! ${row} -eq 1 ] && [ -z "${mode}" ]; then
sed -e "${row}s/^/port = "${port_num}";\n/" c02.txt > c03.txt
else
cp -pr $file c03.txt
fi
;;


*) ####### row_num >= 2 #######
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
row_num_ar=`awk '{
if ((/^port/||/[ ]+port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/[ ]/||//||/.*/) && (/default:[0-9]+);$/)) 
{print NR}
}' c02.txt|xargs -r`
else
row_num_ar=`awk '{
if ((/^# port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/[ ]/||//||/.*/) && (/default:[0-9]+);$/)) 
{print NR}
}' c02.txt|xargs -r`
fi

#=================================================================
# Search the Port number for replacement.
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
port_num_ar=`awk '{
if ((/^port/||/[ ]+port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/[ ]/||//||/.*/) && (/default:[0-9]+);$/)) 
if ((/get_http_port/) && (/[ ]/||//) && (/default:/)) {print $0}
else if ((/port/) && (/[ ]/||//) && (/default:/)) {print $0}
}' c02.txt|cut -d: -f2|cut -d")" -f1|awk '/[0-9]+/ {print $0}'|xargs -r`
else
port_num_ar=`awk '{
if ((/^# port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/[ ]/||//||/.*/) && (/default:[0-9]+);$/)) 
if ((/get_http_port/) && (/[ ]/||//) && (/default:/)) {print $0}
else if ((/port/) && (/[ ]/||//) && (/default:/)) {print $0}
}' c02.txt|cut -d: -f2|cut -d")" -f1|awk '/[0-9]+/ {print $0}'|xargs -r`
fi

if [ ! -z "${row_num_ar}" ] && [ ! -z "${port_num_ar}" ]; then
  x=1
  for h in ${port_num_ar}
  do
  port_num_array[${x}]=${h}
  x=x+1
  done

#=================================================================
# Insert the Port number for replacement
#=================================================================
  x=0
  for i in ${row_num_ar} 
  do
  row=`expr ${i} + ${x}`
  port_num=port_num_array[${x}+1]
    if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
    awk '{
    if ((/^port/||/[ ]+port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/[ ]/||//||/.*/) && (/default:[0-9]+);$/))
    if ((/get_http_port/) && (/[ ]/||//) && (/default:/)) {gsub(/port = get_http_port\(default:'"${port_num}"'\);/, "port = '"${port_num}"';",$0)}
    else if ((/port/) && (/[ ]/||//) && (/default:/)) {gsub(/port = get_http_port\(default:'"${port_num}"'\);/, "port = '"${port_num}"';",$0)}
    {print $0} 
    }' c02.txt > c03.txt
    else
    sed -e "${row}s/^/port = "${port_num}";\n/" c02.txt > c03.txt
    fi
  rm -f c02.txt; cp -pr c03.txt c02.txt
  x=x+1  
  done
else
cp -pr $file c03.txt
fi
;;
esac

cp -pr c03.txt b.txt
rm -f c01.txt c02.txt c03.txt



########################################################################
# Replacement(2)  port = get_unknown_svc(3465);
########################################################################
port_num=0; row_count=0; row=0
cp -pr b.txt d01.txt

#=================================================================
# Add "#"
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
mv d01.txt d02.txt
else
awk '{
if ((/^port/||/[ ]+port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/get_unknown_svc\([0-9]+\);$/))
if      (/^port/)     {gsub(/^port/,"# port",$0)}
else if (/^[ ]+port/) {gsub(/^[ ]+port/,"# port",$0)}
{print $0}
}' d01.txt > d02.txt
fi

#=================================================================
# Count replace rows
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
row_count=`awk '{
if ((/^port/||/[ ]+port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/get_unknown_svc\([0-9]+\);$/))
{print NR}
}' d02.txt|wc -l`
else
row_count=`awk '{
if ((/^# port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/get_unknown_svc\([0-9]+\);$/))
{print NR}
}' d02.txt|wc -l`
fi

if [ -z ${row_count} ]; then
row_count=0
fi

case ${row_count} in
0) ####### row_count = 0 #######
cp -pr b.txt d03.txt
;;

1) ####### row_count = 1 #######
#=================================================================
# Search the Row number for replacement.
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
row=`awk '{
if ((/^port/||/[ ]+port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/get_unknown_svc\([0-9]+\);$/)) 
{print NR}
}' d02.txt`
else
row=`awk '{
if ((/^# port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/get_unknown_svc\([0-9]+\);$/)) 
{print NR}
}' d02.txt`
row=${row}+1
fi


#=================================================================
# Search the Port number for replacement.
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
port_num=`awk '{
if ((/^port/||/[ ]+port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/get_unknown_svc\([0-9]+\);$/)) 
{print $0}
}' d02.txt|cut -d: -f2|cut -d")" -f1|cut -d"(" -f2|awk '/[0-9]+/ {print $0}'`
else
port_num=`awk '{
if ((/^# port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/[ ]/||//) && (/get_unknown_svc\([0-9]+\);$/)) 
{print $0}
}' d02.txt|cut -d: -f2|cut -d")" -f1|cut -d"(" -f2|awk '/[0-9]+/ {print $0}'`
fi

#=================================================================
# Insert the Port number for replacement.
#=================================================================
if [ -z ${port_num} ]; then
cp -pr d02.txt d03.txt
elif [ ! ${port_num} -eq 0 ] && [ ! ${row} -eq 1 ] && ([ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]); then
sed -e "${row}s/^/port = "${port_num}";\n#/" d02.txt > d03.txt
elif [ ! ${port_num} -eq 0 ] && [ ! ${row} -eq 1 ] && [ -z "${mode}" ]; then
sed -e "${row}s/^/port = "${port_num}";\n/" d02.txt > d03.txt
else
cp -pr b.txt d03.txt
fi
;;

*) ####### row_num >=2 #######
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
row_num_ar=`awk '{
if ((/^port/||/[ ]+port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/get_unknown_svc\([0-9]+\);$/)) 
{print NR}
}' d02.txt|xargs -r`
else
row_num_ar=`awk '{
if ((/^# port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/get_unknown_svc\([0-9]+\);$/)) 
{print NR}
}' d02.txt|xargs -r`
fi

#=================================================================
# Search the Port number for replacement.
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
port_num_ar=`awk '{
if ((/^port/||/[ ]+port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/[ ]/||//||/.*/) && (/get_unknown_svc\([0-9]+\);$/)) 
{print $0}
}' d02.txt|cut -d"=" -f2|cut -d"(" -f2|cut -d")" -f1|awk '/[0-9]+/ {print $0}'|xargs -r`
else
port_num_ar=`awk '{
if ((/^# port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/get_unknown_svc\([0-9]+\);$/)) 
{print $0}
}' d02.txt|cut -d"=" -f2|cut -d"(" -f2|cut -d")" -f1|awk '/[0-9]+/ {print $0}'|xargs -r`
fi

#}' d02.txt|cut -d"(" -f2|cut -d")" -f1|awk '/[0-9]+/ {print $0}'|xargs -r`     <- Quick, Very Quick
#}' d02.txt|cut -d: -f2|cut -d")" -f1|awk '/[0-9]+/ {print $0}'|xargs -r`       <- Normal


if [ ! -z "${row_num_ar}" ] && [ ! -z "${port_num_ar}" ]; then
  x=1
  for h in ${port_num_ar}
  do
  port_num_array[${x}]=${h}
  x=x+1
  done

#=================================================================
# Insert the Port number for replacement.
#=================================================================
  x=0
  for i in ${row_num_ar} 
  do
  row=`expr ${i} + ${x}`
  port_num=port_num_array[${x}+1]
    if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
    awk '{
    if ((/^port/||/[ ]+port/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/get_unknown_svc\([0-9]+\);$/)) 
    if ((/get_unknown_svc/) && (/[ ]/||//) && (/\([0-9]+\)/)) {gsub(/port = get_unknown_svc\('"${port_num}"'\);/, "port = '"${port_num}"';",$0)}
    {print $0} 
    }' d02.txt > d03.txt
    else
    sed -e "${row}s/^/port = "${port_num}";\n/" d02.txt > d03.txt
    fi
  rm -f d02.txt; cp -pr d03.txt d02.txt
  x=x+1  
  done
else
cp -pr b.txt d03.txt
fi
;;
esac

cp -pr d03.txt e.txt
rm -f d01.txt d02.txt d03.txt



################################################################################################################
# Replacement(3)(TCP)  Before: soc = open_sock_tcp(port);
#                      After:  # soc = open_sock_tcp(port);
#                              sleep(2); soc = open_priv_sock_tcp(sport:53, dport:port);sleep(2);
################################################################################################################
################################################################################################################
# Replacement(4)(UDP)  Before: soc = open_sock_udp(port);
#                      After:  # soc = open_sock_udp(port);
#                              sleep(2); soc = open_priv_sock_udp(sport:53, dport:port);sleep(2);
################################################################################################################
port_num=0; row_count=0; row=0
cp -pr e.txt f01.txt

#=================================================================
# Add "#"  [step:1/5]
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
mv f01.txt f02.txt
else
awk '{
if ((/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^socwww/||/^[ ]+socwww/||/^_acx_soc/||/^[ ]+_acx_soc/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\(port\);$/) && ! (/ENCAPS_.*/))
if      (/^soc/)          {gsub(/^soc/, "# soc",$0)}
else if (/^soc1/)         {gsub(/^soc1/, "# soc1",$0)}
else if (/^soc2/)         {gsub(/^soc2/, "# soc2",$0)}
else if (/^soc3/)         {gsub(/^soc3/, "# soc3",$0)}
else if (/^soc25/)        {gsub(/^soc25/, "# soc25",$0)}
else if (/^[ ]+soc/)      {gsub(/^[ ]+soc/, "# soc",$0)}
else if (/^[ ]+soc1/)     {gsub(/^[ ]+soc1/, "# soc1",$0)}
else if (/^[ ]+soc2/)     {gsub(/^[ ]+soc2/, "# soc2",$0)}
else if (/^[ ]+soc3/)     {gsub(/^[ ]+soc3/, "# soc3",$0)}
else if (/^[ ]+soc25/)    {gsub(/^[ ]+soc25/, "# soc25",$0)}
else if (/^sock/)         {gsub(/^sock/, "# sock",$0)}
else if (/^sock1/)        {gsub(/^sock1/, "# sock1",$0)}
else if (/^sock2/)        {gsub(/^sock2/, "# sock2",$0)}
else if (/^sock3/)        {gsub(/^sock3/, "# sock3",$0)}
else if (/^sock25/)       {gsub(/^sock25/, "# sock25=",$0)}
else if (/^[ ]+sock/)     {gsub(/^[ ]+sock/, "# sock",$0)}
else if (/^[ ]+sock1/)    {gsub(/^[ ]+sock1/, "# sock1",$0)}
else if (/^[ ]+sock2/)    {gsub(/^[ ]+sock2/, "# sock2",$0)}
else if (/^[ ]+sock3/)    {gsub(/^[ ]+sock3/, "# sock3",$0)}
else if (/^[ ]+sock25/)   {gsub(/^[ ]+sock25/, "# sock25",$0)}
else if (/^s/)            {gsub(/^s/, "# s",$0)}
else if (/^[ ]+s/)        {gsub(/^[ ]+s/, "# s",$0)}
else if (/^socwww/)       {gsub(/^socwww/, "# socwww",$0)}
else if (/^[ ]+socwww/)   {gsub(/^[ ]+socwww/, "# socwww",$0)}
else if (/^_acx_soc/)     {gsub(/^_acx_soc/, "# _acx_soc",$0)}
else if (/^[ ]+_acx_soc/) {gsub(/^[ ]+_acx_soc/, "# _acx_soc",$0)}
else if (/^_soctcp/)      {gsub(/^soctcp/, "# soctcp",$0)}
else if (/^[ ]+soctcp/)   {gsub(/^[ ]+_soctcp/, "# soctcp",$0)}
else if (/^_socudp/)      {gsub(/^socudp/, "# socudp",$0)}
else if (/^[ ]+socudp/)   {gsub(/^[ ]+_socudp/, "# socudp",$0)}
{print $0} 
}' f01.txt > f02.txt
fi

#=================================================================
# Count replace rows
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
row_count=`awk '{
if ((/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^socwww/||/^[ ]+socwww/||/^_acx_soc/||/^[ ]+_acx_soc/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\(port\);$/) )
{print NR}
}' f02.txt|wc -l`
else
row_count=`awk '{
if ((/^# soc/||/^# sock/||/^# s/||/^# socwww/||/^# _acx_soc/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\(port\);$/))
{print NR}
}' f02.txt|wc -l`
fi

if [ -z ${row_count} ]; then
row_count=0
fi


case ${row_count} in
0) ####### row_count = 0 #######
cp -pr e.txt f05.txt
;;


*) ####### row_count >= 1  #######
#=================================================================
# Duplicate replaced row. [step:2/5]
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
mv f02.txt f03.txt
else
awk '{
if ((/^# soc/||/^# sock/||/^# s/||/^# socwww/||/^# _acx_soc/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\(port\);$/)) 
if (/open_sock_tcp/) {print $0}
if (/open_sock_udp/) {print $0}
{print $0} 
}' f02.txt > f03.txt
fi

#=================================================================
# Search the Row number for replacement. [step:3/5]
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
row_num_ar=`awk '{
if ((/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^socwww/||/^[ ]+socwww/||/^_acx_soc/||/^[ ]+_acx_soc/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\(port\);$/)) 
{print NR}
}' f03.txt|xargs -r`
else
row_num_ar=`awk '{
if ((/^# soc/||/^# sock/||/^# s/||/^# socwww/||/^# _acx_soc/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\(port\);$/)) 
{print NR}
}' f03.txt|xargs -r`
fi

#-------------------------
# (1) Quick, Very Quick
#-------------------------
if [ ! -z "${row_num_ar}" ] && ([ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]); then
  x=1
  for i in ${row_num_ar}
  do
#  row=`expr ${i} + ${x}`
  sed -e "${i}s/^/${sleep_com}/" -e "${i}s/$/${sleep_com}/" f03.txt > f04.txt
#=======================================================================================
# open_sock_tcp(port); -> open_priv_sock_tcp(sport:53, dport:port) [step:5/5]
# open_sock_udp(port); -> open_priv_sock_udp(sport:53, dport:port)
#=======================================================================================
  awk '{
  if ((/^'"${sleep_com_bs}"'/) && (/[ ]/||//) && (/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^socwww/||/^[ ]+socwww/||/^_acx_soc/||/^[ ]+_acx_soc/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\(port\);/) && (/'"${sleep_com_bs}"'$/) && ! (/ENCAPS_.*/)) 
  if ((/^'"${sleep_com_bs}"'/) && (/[ ]/||//) && (/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^socwww/||/^[ ]+socwww/||/^_acx_soc/||/^[ ]+_acx_soc/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/) && (/[ ]/||//) && (/\(port\);'"${sleep_com_bs}"'$/)) {gsub(/open_sock_tcp\(port\);/, "open_priv_sock_tcp(sport:'"${src_port}"', dport:port);",$0)}
  if ((/^'"${sleep_com_bs}"'/) && (/[ ]/||//) && (/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^socwww/||/^[ ]+socwww/||/^_acx_soc/||/^[ ]+_acx_soc/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_udp/) && (/[ ]/||//) && (/\(port\);'"${sleep_com_bs}"'$/)) {gsub(/open_sock_udp\(port\);/, "open_priv_sock_udp(sport:'"${src_port}"', dport:port);",$0)}
  {print $0} 
  }' f04.txt > f05.txt
  rm -f f03.txt f04.txt; cp -pr f05.txt f03.txt
  x=x+1  
  done
#else
#cp -pr e.txt f05.txt
fi
#-------------------------
# (2) Normal
#-------------------------
if [ ! -z "${row_num_ar}" ] && [ -z "${mode}" ]; then
  x=1
  for i in ${row_num_ar} 
  do
#  row=`expr ${i} + ${x}`
  if [ `expr ${x} % 2` -eq 0 ]; then
#=================================================================
# Delete unnecessary "#". [2nd Even Rows]  [step:4/5]
#=================================================================
  sed -e "${i}s/^#/${sleep_com}/" -e "${i}s/$/${sleep_com}/" f03.txt > f04.txt
#=======================================================================================
# open_sock_tcp(port); -> open_priv_sock_tcp(sport:53, dport:port) [step:5/5]
# open_sock_udp(port); -> open_priv_sock_udp(sport:53, dport:port)
#=======================================================================================
  awk '{
  if ((/^'"${sleep_com_bs}"'/) && (/[ ]/||//) && (/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^socwww/||/^[ ]+socwww/||/^_acx_soc/||/^[ ]+_acx_soc/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\(port\);/) && (/'"${sleep_com_bs}"'$/) && ! (/ENCAPS_.*/)) 
  if ((/^'"${sleep_com_bs}"'/) && (/[ ]/||//) && (/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^socwww/||/^[ ]+socwww/||/^_acx_soc/||/^[ ]+_acx_soc/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/) && (/[ ]/||//) && (/\(port\);'"${sleep_com_bs}"'$/)) {gsub(/open_sock_tcp\(port\);/, "open_priv_sock_tcp(sport:'"${src_port}"', dport:port);",$0)}
  if ((/^'"${sleep_com_bs}"'/) && (/[ ]/||//) && (/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^socwww/||/^[ ]+socwww/||/^_acx_soc/||/^[ ]+_acx_soc/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_udp/) && (/[ ]/||//) && (/\(port\);'"${sleep_com_bs}"'$/)) {gsub(/open_sock_udp\(port\);/, "open_priv_sock_udp(sport:'"${src_port}"', dport:port);",$0)}
  {print $0} 
  }' f04.txt > f05.txt
  else
  cp -pr f03.txt f05.txt
  fi
  rm -f f03.txt f04.txt; cp -pr f05.txt f03.txt
  x=x+1  
  done
#else
#cp -pr e.txt f05.txt
fi

if [  -z "${row_num_ar}" ]; then
cp -pr e.txt f05.txt
fi

;;
esac

cp -pr f05.txt g.txt
rm -f f01.txt f02.txt f03.txt f04.txt f05.txt



################################################################################################################
# Replacement(5)(TCP)  Before: soc = open_sock_tcp(80);
#                      After:  # soc = open_sock_tcp(80);
#                              sleep(2); soc = open_priv_sock_tcp(sport:53, dport:80);sleep(2);
################################################################################################################
################################################################################################################
# Replacement(6)(UDP)  Before: soc = open_sock_udp(80);
#                      After:  # soc = soc = open_sock_udp(80);
#                              sleep(2); soc = open_priv_sock_udp(sport:53, dport:80);sleep(2);
################################################################################################################
port_num=0; row_count=0; row=0
cp -pr g.txt h01.txt

#=================================================================
# Add "#"    [step:1/5]
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
mv h01.txt h02.txt
else
awk '{
if ((/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/[0-9]+\);$/) && ! (/ENCAPS_.*/)) 
if      (/^soc/)         {gsub(/^soc/, "# soc",$0)}
else if (/^soc1/)        {gsub(/^soc1/, "# soc1",$0)}
else if (/^soc2/)        {gsub(/^soc2/, "# soc2",$0)}
else if (/^soc3/)        {gsub(/^soc3/, "# soc3",$0)}
else if (/^soc25/)       {gsub(/^soc25/, "# soc25",$0)}
else if (/^[ ]+soc/)     {gsub(/^[ ]+soc/, "# soc",$0)}
else if (/^[ ]+soc1/)    {gsub(/^[ ]+soc1/, "# soc1",$0)}
else if (/^[ ]+soc2/)    {gsub(/^[ ]+soc2/, "# soc2",$0)}
else if (/^[ ]+soc3/)    {gsub(/^[ ]+soc3/, "# soc3",$0)}
else if (/^[ ]+soc25/)   {gsub(/^[ ]+soc25/, "# soc25",$0)}
else if (/^sock/)        {gsub(/^sock/, "# sock",$0)}
else if (/^sock1/)       {gsub(/^sock1/, "# sock1",$0)}
else if (/^sock2/)       {gsub(/^sock2/, "# sock2",$0)}
else if (/^sock3/)       {gsub(/^sock3/, "# sock3",$0)}
else if (/^sock25/)      {gsub(/^sock25/, "# sock25=",$0)}
else if (/^[ ]+sock/)    {gsub(/^[ ]+sock/, "# sock",$0)}
else if (/^[ ]+sock1/)   {gsub(/^[ ]+sock1/, "# sock1",$0)}
else if (/^[ ]+sock2/)   {gsub(/^[ ]+sock2/, "# sock2",$0)}
else if (/^[ ]+sock3/)   {gsub(/^[ ]+sock3/, "# sock3",$0)}
else if (/^[ ]+sock25/)  {gsub(/^[ ]+sock25/, "# sock25",$0)}
else if (/^s/)           {gsub(/^s/, "# s",$0)}
else if (/^[ ]+s/)       {gsub(/^[ ]+s/, "# s",$0)}
else if (/^socktcp/)     {gsub(/^socktcp/, "# socktcp",$0)}
else if (/^[ ]+socktcp/) {gsub(/^[ ]+socktcp/, "# socktcp",$0)}
else if (/^sockudp/)     {gsub(/^sockudp/, "# sockudp",$0)}
else if (/^[ ]+sockudp/) {gsub(/^[ ]+sockudp/, "# sockudp",$0)}
{print $0} 
}' h01.txt > h02.txt
fi

#=================================================================
# Count replace rows
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
row_count=`awk '{
if ((/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^socktcp/||/^[ ]+socktcp/||/^sockudp/||/^[ ]+sockudp/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\([0-9]+\);$/) && ! (/sleep\([0-9]+\);$/))
{print NR}
}' h02.txt|wc -l`
else
row_count=`awk '{
if ((/^# soc/||/^# sock/||/^# s/||/^# socktcp/||/^# sockudp/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\([0-9]+\);$/) && ! (/sleep\([0-9]+\);$/))
{print NR}
}' h02.txt|wc -l`
fi

if [ -z ${row_count} ]; then
row_count=0
fi


case ${row_count} in
0) ####### row_count = 0 #######
cp -pr g.txt h05.txt
;;


*) ####### row_count >=1 #######
#=================================================================
# Duplicate replaced row. [step:2/5]
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
mv h02.txt h03.txt
else
awk '{
if ((/^# soc/||/^# sock/||/^# s/||/^# socktcp/||/^# sockudp/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\([0-9]+\);$/) && ! (/sleep\([0-9]+\);$/))
if (/open_sock_tcp/) {print $0}
if (/open_sock_udp/) {print $0}
{print $0} 
}' h02.txt > h03.txt
fi

#=================================================================
# Search the Row number for replacement. [step:3/5]
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
row_num_ar=`awk '{
if ((/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^socktcp/||/^[ ]+socktcp/||/^sockudp/||/^[ ]+sockudp/) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\([0-9]+\);$/) && ! (/sleep\([0-9]+\);$/))
{print NR}
}' h03.txt|xargs -r`
else
row_num_ar=`awk '{
if ((/^# soc/||/^# sock/||/^# s/||/^# socktcp/||/^# sockudp/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\([0-9]+\);$/) && ! (/sleep\([0-9]+\);$/))
{print NR}
}' h03.txt|xargs -r`
fi

#=================================================================
# Search the Port number for replacement.
#=================================================================
if [ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]; then
port_num_ar=`awk '{
if ((/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^socktcp/||/^[ ]+socktcp/||/^sockudp/||/^[ ]+sockudp/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\([0-9]+\);$/) && ! (/sleep\([0-9]+\);$/))
{print $0}
}' h03.txt|cut -d: -f2|cut -d")" -f1|cut -d"(" -f2|awk '/[0-9]+/ {print $0}'|xargs -r`
else
port_num_ar=`awk '{
if ((/^# soc/||/^# sock/||/^# s/||/^# socktcp/||/^# sockudp/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\([0-9]+\);$/) && ! (/sleep\([0-9]+\);$/))
{print $0}
}' h03.txt|cut -d: -f2|cut -d")" -f1|cut -d"(" -f2|awk '/[0-9]+/ {print $0}'|xargs -r`
fi

if [ ! -z "${row_num_ar}" ] && [ ! -z "${port_num_ar}" ]; then
  x=1
  for h in ${port_num_ar}
  do
  port_num_array[${x}]=${h}
  x=x+1
  done

#=================================================================
# Insert the Port number for replacement.
#=================================================================
  x=1
  for i in ${row_num_ar} 
  do
#  row=`expr ${i} + ${x}`
#  sed -e "${row}s/^/port = "${port_num}";\n/" f02.txt > f03.txt
#  rm -f f02.txt; cp -pr f03.txt f02.txt
  x=x+1  
  done

#-------------------------
# (1) Quick, Very Quick
#-------------------------
  if [ ! -z "${row_num_ar}" ] && ([ "${mode}" = "quick" ] || [ "${mode}" = "vq" ]); then
  x=1
  for i in ${row_num_ar} 
  do
#  row=`expr ${i} + ${x}`
  sed -e "${i}s/^/${sleep_com}/" -e "${i}s/$/${sleep_com}/" h03.txt > h04.txt
#==============================================================================================================
# open_sock_tcp(80);  -> open_priv_sock_tcp(sport:53, dport:80)  [step:5/5]
# open_sock_udp(123); -> open_priv_sock_udp(sport:53, dport:123)
#==============================================================================================================
  awk '{
  if ((/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^socktcp/||/^[ ]+socktcp/||/^sockudp/||/^[ ]+sockudp/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\([0-9]+\);/) && (/'"${sleep_com_bs}"'$/) && ! (/ENCAPS_.*/))
  if ((/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^socktcp/||/^[ ]+socktcp/) && (/open_sock_tcp/) && (/[ ]/||//) && (/\([0-9]+\);'"${sleep_com_bs}"'$/)) {gsub(/open_sock_tcp\(/, "open_priv_sock_tcp(sport:'"${src_port}"', dport:",$0)}
  if ((/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^sockudp/||/^[ ]+sockudp/) && (/open_sock_udp/) && (/[ ]/||//) && (/\([0-9]+\);'"${sleep_com_bs}"'$/)) {gsub(/open_sock_udp\(/, "open_priv_sock_udp(sport:'"${src_port}"', dport:",$0)}
  {print $0} 
  }' h04.txt > h05.txt
  rm -f h03.txt h04.txt; cp -pr h05.txt h03.txt    
  x=x+1  
  done
  fi

#-------------------------
# (2) Normal
#-------------------------
  if [ ! -z "${row_num_ar}" ] && [ -z "${mode}" ]; then
  x=1
  for i in ${row_num_ar} 
  do
#  row=`expr ${i} + ${x}`
    if [ `expr ${x} % 2` -eq 0 ]; then
#=================================================================
# Delete unnecessary "#". [2nd Even Rows]  [step:4/5]
#=================================================================
    sed -e "${i}s/^#/${sleep_com}/" -e "${i}s/$/${sleep_com}/" h03.txt > h04.txt
#==============================================================================================================
# open_sock_tcp(80)  -> open_priv_sock_tcp(sport:53, dport:80)  [step:5/5]
# open_sock_udp(123) -> open_priv_sock_udp(sport:53, dport:123)
#==============================================================================================================
    awk '{
    if ((/^'"${sleep_com_bs}"'/) && (/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^socktcp/||/^[ ]+socktcp/||/^sockudp/||/^[ ]+sockudp/) && (/[0-9]+/||/[ ]/||//) && (/[ ]/||//) && (/=/) && (/[ ]/||//) && (/open_sock_tcp/||/open_sock_udp/) && (/[ ]/||//) && (/\([0-9]+\);/) && (/'"${sleep_com_bs}"'$/) && ! (/ENCAPS_.*/))
    if ((/^'"${sleep_com_bs}"'/) && (/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^socktcp/||/^[ ]+socktcp/) && (/open_sock_tcp/) && (/[ ]/||//) && (/\([0-9]+\);'"${sleep_com_bs}"'$/)) {gsub(/open_sock_tcp\(/, "open_priv_sock_tcp(sport:'"${src_port}"', dport:",$0)}
    if ((/^'"${sleep_com_bs}"'/) && (/^soc/||/^[ ]+soc/||/^sock/||/^[ ]+sock/||/^s/||/^[ ]+s/||/^sockudp/||/^[ ]+sockudp/) && (/open_sock_udp/) && (/[ ]/||//) && (/\([0-9]+\);'"${sleep_com_bs}"'$/)) {gsub(/open_sock_udp\(/, "open_priv_sock_udp(sport:'"${src_port}"', dport:",$0)}
    {print $0} 
    }' h04.txt > h05.txt
    else
    cp -pr h03.txt h05.txt
    fi
    rm -f h03.txt h04.txt; cp -pr h05.txt h03.txt    
  x=x+1  
  done
  fi
#else
#cp -pr g.txt h05.txt
fi

if [  -z "${row_num_ar}" ]; then
cp -pr g.txt h05.txt
fi

;;
esac

cp -pr h05.txt i.txt
rm -f h01.txt h02.txt h03.txt h04.txt h05.txt



######################################################################
# Compare file size. ($file, i.txt)
######################################################################
if [ "${mode}" != "vq" ]; then
org_file_size=`ls -l $file | awk '{print $5}'`
replaced_file_size=`ls -l i.txt | awk '{print $5}'`
if [ "${replaced_file_size}" != "${org_file_size}" ]; then
files_replaced=${files_replaced}+1
echo ${file} | cut -d"/" -f7 >> ${DATE}_${TIME}_replaced_files.txt
fi
fi

##################################################
# Delete unnecessary files. (Loop process)
##################################################
rm -f ${file} a*.txt b*.txt c*.txt d*.txt e*.txt f*.txt g*.txt h*.txt 
mv i.txt ${file}
row=0
;;
esac
org_file_size=0; replaced_file_size=0
port_num=0
done

#############################################
# Delete unnecessary files at the END.
#############################################
rm -f a*.txt b*.txt c*.txt d*.txt e*.txt f*.txt g*.txt h*.txt i*.txt

##############################################################################
# Result of ths script execution.
##############################################################################
echo "-----------------------------------------------------------" 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
echo "### Script Results (Summary) ###" 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
echo "" 2>&1 | tee -a ${DATE}_${TIME}_replace.txt

##############################################################################
# The number of all files at /opt/nessus/lib/nessus/plugins.
##############################################################################
all_files=`ls -l /opt/nessus/lib/nessus/plugins/|wc -l`
all_files=${all_files}-1
echo "  All Files (at /opt/nessus/lib/nessus/plugins) = " ${all_files} 2>&1 | tee -a ${DATE}_${TIME}_replace.txt

##############################################################################
# The number of files of "nasl","inc","nes" and "nbin".
##############################################################################
nasl_files=`find /opt/nessus/lib/nessus/plugins -name "*.nasl"|wc -l`
inc_files=`find /opt/nessus/lib/nessus/plugins -name "*.inc"|wc -l`
nes_files=`find /opt/nessus/lib/nessus/plugins -name "*.nes"|wc -l`
nbin_files=`find /opt/nessus/lib/nessus/plugins -name "*.nbin"|wc -l`
echo " .nasl Files (at /opt/nessus/lib/nessus/plugins) =" ${nasl_files} 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
echo " .inc Files (at /opt/nessus/lib/nessus/plugins) =    " ${inc_files} 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
echo " .nes Files (at /opt/nessus/lib/nessus/plugins) =     " ${nes_files} 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
echo " .nbin Files (at /opt/nessus/lib/nessus/plugins) =   " ${nbin_files} 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
echo "" 2>&1 | tee -a ${DATE}_${TIME}_replace.txt

##############################################################################
# The number of Replaced files.
##############################################################################
if [ "${mode}" != "vq" ]; then
echo "Total Replaced Files =" ${files_replaced} 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
echo "" 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
fi
echo "-----------------------------------------------------------" 2>&1 | tee -a ${DATE}_${TIME}_replace.txt

##############################################################################
# Elapsed Time
##############################################################################
echo "### Elapsed time ###" 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
END_TIME=`date +%H:%M:%S`
echo ""

echo " START_TIME = "${START_TIME} 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
echo "  END_TIME  = "${END_TIME} 2>&1 | tee -a ${DATE}_${TIME}_replace.txt

echo "" 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
echo "END" 2>&1 | tee -a ${DATE}_${TIME}_replace.txt
echo ""

##############################################################################
# Error check
##############################################################################
temp_no=`egrep -i "command not found" ${DATE}_${TIME}_replace.txt | wc -l`
  error_count=${temp_no}
temp_no=`egrep -i " error" ${DATE}_${TIME}_replace.txt | wc -l`
  error_count=${error_count}+${temp_no}
temp_no=`egrep -i "error " ${DATE}_${TIME}_replace.txt | wc -l`
  error_count=${error_count}+${temp_no}
temp_no=`egrep -i " error " ${DATE}_${TIME}_replace.txt | wc -l`
  error_count=${error_count}+${temp_no}

if [ ${error_count} -gt 0 ]; then
echo "Error occured!!"
echo "Check the log file" ${DATE}_${TIME}_replace.txt
fi

echo ""
# END

#!/bin/bash

# Info:
#   Created: 2014-09-17
#   Author: Marcelo Martins
# 

# VARS
system_type=$1
account_type=$2
date=$(date +'%Y%m%d.%H%M%S.%Z')
log_file="/tmp/account_crawler_info_${date}.log"

# SQL QUERY
sql_query="select account, datetime(created_at,'unixepoch') as created, datetime(delete_timestamp,'unixepoch') as deleted, status, status_changed_at as changed from account_stat where account LIKE '%"${account_type}"%'"
 

# Usage
usage_display (){
cat << USAGE

Usage:
    Running Syntax: sudo -u swift account_crawler_info.sh [system_type] [account_type]   
    System Types: synnex, supermicro, container and proxy  
    Account Type: SOSO, JungleDisk and MossoCloudFS 

USAGE
exit 1
}

# Check arguments
if [[ -z ${system_type} ]]; then
  echo " Error: No system type provided "
  usage_display
  exit 1
fi

if [[ -z ${account_type} ]]; then
  echo " Error: No account type provided "
  usage_display
  exit 1
fi


# Create log file
if [[ ! -e "${log_file}" ]]; then
  echo -e " - Creatin log file : ${log_file} \n"
  touch ${log_file}
fi

echo -e "-------------- Starting Account Crawling : ${date} --------------" | /usr/bin/tee -a ${log_file}
echo -e " Header Order: account | created | deleted | status | changed \n " | /usr/bin/tee -a ${log_file}


if [[ ${system_type} == "synnex" ]]; then
  for i in {a..x}; do
    if [[ -d "/srv/node/sd${i}/accounts" ]]; then
      echo -e " Crawling directory : /srv/node/sd${i}/accounts" 
      find /srv/node/sd${i}/accounts -type f -iname "*.db" -exec /usr/bin/sqlite3 -separator "," {} "${sql_query}" >> ${log_file} \;
    else
      echo -e " Crawling directory : /srv/node/sd${i}/accounts (NO accounts directory found) " 
    fi
  done

elif [[ ${system_type} == "supermicro" ]]; then
  if [[ -d "/srv/node/c0u1/accounts" ]]; then
    echo -e " Crawling directory : /srv/node/c0u1/accounts " 
    find /srv/node/c0u1/accounts -type f -iname "*.db" -exec /usr/bin/sqlite3 -separator "," {} "${sql_query}" >> ${log_file} \;
  else
    echo -e " Crawling directory : /srv/node/c0u1/accounts (NO accounts directory found) "
  fi

elif [[ ${system_type} == "container" ]]; then
  if [[ -d "/srv/node/c0u1/accounts" ]]; then
    echo -e " Crawling directory : /srv/node/c0u1/accounts " 
    find /srv/node/c0u1/accounts -type f -iname "*.db" -exec /usr/bin/sqlite3 -separator "," {} "${sql_query}" >> ${log_file} \;
  elif [[ -d "/srv/node/sdb/accounts" ]]; then
    echo -e " Crawling directory : /srv/node/sdb/accounts " 
    find /srv/node/sdb/accounts -type f -iname "*.db" -exec /usr/bin/sqlite3 -separator "," {} "${sql_query}" >> ${log_file} \;
  else
    echo -e " Crawling directory : /srv/node/[c0u1|sdb]/accounts (NO accounts directory found) "
  fi

elif [[ ${system_type} == "proxy" ]]; then
  for i in 2 3 ; do
    if [[ -d "/srv/node/c0u${i}/accounts" ]]; then
      echo -e " Crawling directory : /srv/node/c0u${i}/accounts " 
      find /srv/node/c0u${i}/accounts -type f -iname "*.db" -exec /usr/bin/sqlite3 -separator "," {} "${sql_query}" >> ${log_file} \;
    else
      echo -e " Crawling directory : /srv/node/c0u${i}/accounts (NO accounts directory found) "
    fi
  done
fi

echo -e "\n-------------- Finishing Account Crawling of ${date} --------------\n" | /usr/bin/tee -a ${log_file}

exit 0

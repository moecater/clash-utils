#!/bin/bash
set -Eeo pipefail

pidpath="/run/clash-tuner.pid"
stopscriptpath="/etc/clash-tuner/on-stop-script"
startscriptpath="/etc/clash-tuner/on-start-script"

#_refresh_dns() {
#  local provider=${1:-system}
#  local confpath='/etc/NetworkManager/dnsmasq.d/zzz-clash_tuner_dnsfix_dns.conf'
#  if !(systemctl is-active --quiet NetworkManager && ps -ef | grep -E 'dnsmasq.*Net' | grep -v grep > /dev/null); then
#    echo "[DNS] You are not currently using Dnsmasq with Networkmanager, configuration skipped."
#    return 0
#  fi
#  if [[ $provider = system ]]; then
#    [[ -f $confpath ]] && rm $confpath && echo "[DNS] Dnsmasq config added by clash-tuner has been removed (rm: $confpath)"
#  elif [[ $provider = dns ]]; then
#    (echo 'server='; echo 'server=223.5.5.5') > $confpath && echo "[DNS] 233.5.5.5 will be used as Dnsmasq upstream server (edited: $confpath)"
#  elif [[ $provider = clash ]]; then
#    (echo 'server='; echo 'server=127.0.1.1') > $confpath && echo "[DNS] 127.0.1.1 will be used as Dnsmasq upstream server (edited: $confpath)"
#  fi
#  # dnspid=$(ps -ef | grep -E 'dnsmasq.*Net' | grep -v grep | awk '{print $2}') && kill -SIGHUP $dnspid && echo "[DNS] DNS cache have been flushed (reloaded pid: $dnspid)"
#  killall -SIGHUP dnsmasq && echo "[DNS] DNS cache have been flushed (killall: dnsmasq)"
#}

_stop() {
  [[ -s $pidpath ]] && ps "$(cat $pidpath)" 2> /dev/null | grep 'clash' >> /dev/null && (echo "[Kill] Try to stop the old clash process (kill: $(cat $pidpath))" && kill $(cat $pidpath) && rm $pidpath && echo "[Service] Removed cache PID. (rm: $pidpath)" || (echo "[ERR] Can not kill services or remove pid file, you should rm or kill it manually" && return 1))
  [[ -s $stopscriptpath ]] && ($stopscriptpath && echo "[Script] $stopscriptpath has been called" || echo "[ERR] $stopscriptpath not been correctly executed, please check your script (not-zero return)")
  #_refresh_dns 'system'
  echo [Kill] Process has been stopped
  return 0
}

# [user] eg. moe. The default is `moe`.
# [relconf] eg. if you set to `airplane`, then the realpath will be converted to `~$[user]/.config/clash/airplane`. The default is `` (aka. `~$[user]/.config/clash/`)
# [perm] bool, eg. true, enable addition permission for clash to setup TUN device or listen DNS on a limited port (For more info see the service unit). The default is `false`. 
# [backend], `clash` or `clash-meta`. The default is `clash-meta`
#
# Syntax:
# `/usr/bin/clash-tuner [user] [relconf] [perm] [backend]`
# or
# `/usr/bin/clash-tuner` (leave parameters list empty will use previous saved parameters from envfile)
#
# Example:
# `/usr/bin/clash-tuner moe airplane true clash-meta`

_start() {
  # main
  [[ -z $user ]] && local user=${1:-moe}
  [[ -z $relconf ]] && local relconf=${2:-} 
  [[ -z $perm ]] && local perm=${3:-false}
  [[ -z $backend ]] && local backend=${4:-clash-meta}
  conf="$(eval echo "~$user")/.config/clash/$relconf"
  # remove the text follow from the duplicated tailing slashes to avoid problems
  #conf=${conf%//*}
  _stop || return 1
  sleep 1 
  # dnsfix
  #echo "[WARN] Try to fix network error" && _refresh_dns 'dns' && sleep 1
  [[ $perm = true ]] && local sername="${backend}-daemon-perm@${user}" || local sername="${backend}-daemon@${user}"
  mkdir -p /etc/clash-tuner
  printf "conf=$conf\nuser=$user\nrelconf=$relconf\nperm=$perm\nbackend=$backend" > /etc/clash-tuner/env || return 1
  echo "[Env] Parameters has been saved to: /etc/clash-tuner/env (modified: /etc/clash-tuner/env)"
  # runuser -u "$user" -- systemctl --user start "$sername"
  # runuser -u "$user" -- systemctl --user show -p MainPID --value "$sername" > "$pidpath"
  echo [Service] Starting service: $sername
  systemctl start "$sername"
  #sleep 1 
  local servpid=$(systemctl show -p MainPID --value "$sername") && echo $servpid > "$pidpath" && echo "[Service] Service started with PID: $servpid (edited: $pidpath)"
  [[ -s $startscriptpath ]] && ($startscriptpath && echo "[Script] $startscriptpath has been called" || echo "[ERR] $startscriptpath not been correctly executed, please check your script (not-zero return)")
  #_refresh_dns 'clash'
  return 0
}

# check root
[[ $(id -u) -ne 0 ]] && echo "[ERR] You should run scirpt with root permission" && exit 1

([[ $1 != 'stop' ]] && _start "$@" || _stop "$@") && echo "[DONE] Script finished." || echo "[ERR] Previous clash process can not be stopped. Script aborted."

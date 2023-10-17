#!/bin/bash
set -Eeo pipefail
path="$(eval echo ~$USER)/.config/clash"
trap '_ERROR' ERR
trap 'rm -r -- $tmp' EXIT
tmp="$(mktemp -d)"

#! ALL THE PARAMETERS BELOW ARE LOAD FROM `$HOME/.config/clash/clash-updater.env`. YOU SHOULD NOT EDIT THIS FILE MANULLY

# Your Clash configs profiles
# please use `%` as the separator for dirived-configs (And note that any `%` will be replace to `_` as the finally config dirname)
# e.g. `example` will be saved to `$path/example/config.yaml`
# AND `example%tun` will be finally saved to `$path/example_tun/config.yaml`
# derived-configs: setting different URL params to the SAME base subscription url
# e.g. example and example%tun will both using the example_url
profiles=(example example%tun example_meta example_meta%tun)
# append `_url` to your profiles variable indicate the base url of the subscription
example_url="https://YOUR-BACKEND/"
example_meta_url="https://YOUR-BACKEND/"
# the default config will be saved to the `$path/config.yaml``
default=example
# paramaters needed for adding to the profiles using the same url
# e.g. append `&dns=true` to `${example_url}`
# leaft it empty or not to explicitly configured to disable the feature for the profile
# e.g. `example%tun` and `example` is sharing `example_paras`, leave `example_paras` empty to disable this feature
example_paras=(dns api lan tun)
example_meta_paras=(dns api lan tun)
# set the default vaule per param that profile will use
example_dns_deft=true
example_api_deft=true
example_lan_deft=true
example_tun_deft=false
example_meta_dns_deft=true
example_meta_api_deft=true
example_meta_lan_deft=true
example_meta_tun_deft=false
# derived-configs
# e.g. `example_tun%tun` is the derived-config profile `example%tun`, and the `tun` parameter defined by `example_paras` can set by variable `example_tun_tun` (substitute `example%tun` to `example_tun`, and append `_tun`, in this case: true) to replace the default `example_tun_deft` (in this case: false)
example_tun_tun=true
example_meta_tun_tun=true

##### END #####

_ERROR() {
  [[ -f ${tmp}/wconf ]] && echo "[LOG ECHO] last 15 lines from the downloaded config" && cat ${tmp}/wconf | tail -n15
  echo "[ERR] Script aborted"
}

# load conf or exit
confpath=$HOME/.config/clash/clash-updater.env
echo "[CONF] Loading config from $confpath"
[[ -f $confpath ]] && source $confpath || (echo "[ERR] Some errors happened in loading your config file." && echo "[INFO] You can check the syntax by typing: \`less $(which clash-updater)\`)" && exit 1 )

if [[ $1 != '--bypass-dat' ]]; then
  echo Downloading: Counrties-based GeoIP.dat
  if wget -O "$tmp"/dat "https://cdn.jsdelivr.net/gh/Loyalsoldier/geoip@release/geoip.dat" -q --show-progress; then
    cp "$tmp"/dat "$path"/GeoIP.dat
    echo Downloaded: "$path"/GeoIP.dat
  else
    exit 1
  fi
  echo Downloading: Counrties-based Country.mmdb
  if wget -O "$tmp"/dat "https://cdn.jsdelivr.net/gh/Dreamacro/maxmind-geoip@release/Country.mmdb" -q --show-progress; then
    cp "$tmp"/dat "$path"/Country.mmdb
    echo Downloaded: "$path"/Country.mmdb
  else
    exit 1
  fi
fi

for i in "${profiles[@]}"; do
  url="${i/\%*/}_url"
  exp_url="${!url}"
  dns=${dns_deft} api=${api_deft} lan=${lan_deft} tun=${tun_deft}
  parav="${i/\%*/}_paras[@]"
  for j in "${!parav}"; do
    exp="${i//%/_}"_"$j"
    expd="${i/\%*/}_${j}_deft"
    [[ -z "${!exp}" ]] && declare val="${!expd}" || declare val="${!exp}"
    exp_url="${exp_url}&${j}=${val}"
  done
  echo Downloading: ${i//%/_} FROM ${exp_url}
  if mkdir -p "$path"/${i//%/_} && wget -O "${tmp}/wconf" "$exp_url" -q --show-progress && [[ $(wc -l < ${tmp}/wconf) -ge 5 ]]; then
     cp ${tmp}/wconf "$path"/"${i//%/_}"/config.yaml
     [[ ${i//%/_} = $default ]] && cp "$path"/"${i//%/_}"/config.yaml "$path"/config.yaml
     if [[ $1 != '--bypass-dat' ]]; then
       cp "$path"/GeoIP.dat "$path"/${i//%/_}/
       cp "$path"/Country.mmdb "$path"/${i//%/_}/
     fi
     echo "Downloaded: "$path"/"${i//%/_}"/config.yaml"
  else
    echo "[ERR] Lines of the downloaded content < 5"
    exit 1
  fi
done

[[ $1 = '--bypass-dat' ]] && echo "[OK] Script successfully finished. (no GEOIP files updated)" || echo "[OK] Script successfully finished."

exit 0

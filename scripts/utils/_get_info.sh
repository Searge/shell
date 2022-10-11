function get_info() {
  whoami IP_=$(curl -s ifconfig.me)
  echo "WAN IP: ${IP_}"

  echo "OS:"
  cat /etc/os-release

  echo "LAN IP"
  ip a | grep 'inet '
}

function get_hostname() {
  echo "Hostname: $(hostname -fi)"
}

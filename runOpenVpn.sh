#!/bin/sh

if [ ! -z "$OPEN_VPN_CONFIG" ]
then
	if [ -f /etc/openvpn/"${OPEN_VPN_CONFIG}".ovpn ]
  	then
		echo "Starting OpenVPN using config ${OPEN_VPN_CONFIG}.ovpn"
		exec openvpn --config /etc/openvpn/"${OPEN_VPN_CONFIG}".ovpn
	else
		echo "Supplied config ${OPEN_VPN_CONFIG}.ovpn could not be found."
		echo "Using default OpenVPN gateway: Netherlands"
		exec openvpn --config /etc/openvpn/Netherlands.ovpn
	fi
else
	echo "No VPN configuration provided. Using default: Netherlands"
	exec openvpn --config /etc/openvpn/Netherlands.ovpn
fi

# override resolv.conf
if [ "$RESOLV_OVERRIDE" != "**None**" ];
then
  echo "Overriding resolv.conf..."
  printf "$RESOLV_OVERRIDE" > /etc/resolv.conf
fi

# add PIA user/pass
if [ "$PIA_USERNAME" != "**None**" ];
then
  echo "Setting PIA credentials..."
  echo $PIA_USERNAME > /config/pia-credentials.txt
  echo $PIA_PASSWORD >> /config/pia-credentials.txt
else
  echo "Not setting PIA credentials."
fi

dockerize \
  -template /etc/openvpn/config.ovpn:/etc/openvpn/config.ovpn \
  -template /etc/transmission-daemon/settings.json:/etc/transmission-daemon/settings.json \
  true

exec openvpn --config /etc/openvpn/config.ovpn

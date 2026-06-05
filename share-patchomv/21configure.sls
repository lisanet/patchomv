# workarounf for -2 and so added to hostnames

configure_avahi_daemon_conf_no2-ipv4:
  file.replace:
    - name: "/etc/avahi/avahi-daemon.conf"
    - pattern: "publish-aaaa-on-ipv4=yes"
    - repl: "publish-aaaa-on-ipv4=no"
    - backup: False

configure_avahi_daemon_conf_no2-ipv6:
  file.replace:
    - name: "/etc/avahi/avahi-daemon.conf"
    - pattern: "publish-a-on-ipv6=yes"
    - repl: "publish-a-on-ipv6=no"
    - backup: False



# workarounf for -2 and so added to hostnames

configure_avahi_daemon_conf_no2:
  file.replace:
    - name: "/etc/avahi/avahi-daemon.conf"
    - pattern: "#publish-aaaa.*a-on-ipv6=no"
    - repl: |-
        publish-aaaa-on-ipv4=no
        publish-a-on-ipv6=no
    - flags: ['DOTALL', 'MULTILINE']
    - backup: False



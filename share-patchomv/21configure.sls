# workarounf for -2 and so added to hostnames

configure_avahi_daemon_conf_no2:
  file.append:
    - name: "/etc/avahi/avahi-daemon.conf"
    - sources:
      - salt://{{ tpldir }}/files/etc-avahi-avahi-daemon_conf_no2.j2
    - template: jinja



# hdparm is now triggered via UDEV.
# See /lib/udev/rules.d/85-hdparm.rules and /lib/udev/hdparm scripts.

{% set config = salt['omv_conf.get']('conf.system.hdparm') %}

configure_hdparm_conf:
  file.managed:
    - name: "/etc/hdparm.conf"
    - source:
      - salt://{{ tpldir }}/files/etc-hdparm.conf.j2
    - template: jinja
    - context:
        config: {{ config | json }}
    - user: root
    - group: root
    - mode: 644

divert_hdparm_conf:
  omv_dpkg.divert_add:
    - name: "/etc/hdparm.conf"

# Usually '/lib/udev/hdparm' is executed by UDEV when a device is added
# to apply the hdparm.conf settings. At runtime it is not possible to
# force UDEV to do the same thing again to reload the settings, e.g.
# by running 'udevadm trigger'. For this reason, we simply run the script
# ourselves.
{% for device in config | selectattr('devicefile', 'is_block_device') %}
reload_hdparm_{{ device.devicefile }}:
  cmd.run:
    - name: "/lib/udev/hdparm"
    - env:
      - DEVNAME: "{{ device.devicefile }}"
#    - onchanges:
#      - file: configure_hdparm_conf
{% endfor %}


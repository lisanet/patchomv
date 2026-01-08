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

{% for device in config | selectattr('devicefile', 'is_block_device') %}
disable_smartmontools_hdparm_{{ device.uuid }}:
  file.replace:
    - name: "/etc/smartmontools/hdparm.d/openmediavault-{{ device.uuid }}"
    - pattern: ' smartctl'
    - repl: ' #smartctl'
    - backup: False

# Usually '/lib/udev/hdparm' is executed by UDEV when a device is added
# to apply the hdparm.conf settings. At runtime it is not possible to
# force UDEV to do the same thing again to reload the settings, e.g.
# by running 'udevadm trigger'. For this reason, we simply run the script
# ourselves.
# we run this, regardless of wether the configuration has changed or not,
# because an update of omv may change the smartcontrol settings
reload_hdparm_{{ device.devicefile }}:
  cmd.run:
    - name: "/lib/udev/hdparm"
    - env:
      - DEVNAME: "{{ device.devicefile }}"
{% endfor %}


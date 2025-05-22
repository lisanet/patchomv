{% set config = salt['omv_conf.get']('conf.system.hdparm') %}

{% for device in config %}

disable_smartmontools_hdparm_{{ device.uuid }}:
  file.replace:
    - name: "/etc/smartmontools/hdparm.d/openmediavault-{{ device.uuid }}"
    - pattern: ' smartctl'
    - repl: ' #smartctl'
    - backup: False

{% endfor %}

disable_smartmontools_hdparm:
  file.replace:
    - name: "/srv/salt/omv/deploy/smartmontools/20hdparm.sls"
    - pattern: ' smartctl{'
    - repl: ' #smartctl{'
    - backup: False

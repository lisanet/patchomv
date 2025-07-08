# Convert cron to systemd timer
#
# @license   MIT
# @copyright (c) 2025 Simone Lehmann simone at lisanet dot de
#

{% set script_prefix = salt['pillar.get']('default:OMV_CRONTAB_USERDEFINED_PREFIX', 'userdefined-') %}
{% set prefix = 'omv-' ~ script_prefix %}
{% set services = salt['file.find'](path='/etc/systemd/system', name=prefix ~ '*.service') %}

# stop, disable and remove exiting timers/service
{% for service_path in services %}
{% set service = service_path.split('/')[-1] %}
{% set timer = service | replace('.service', '.timer') %}

c2t_stop_disable_{{ timer }}:
  cmd.run:
    - name: systemctl stop {{ timer }}; systemctl disable {{ timer }} {{ service }}
    - onlyif: test -L /etc/systemd/system/timers.target.wants/{{ timer }}

c2t_stop_disable_{{ service }}:
  cmd.run:
    - name: systemctl stop {{ service }}; systemctl disable {{ service }}
    - onlyif: test -L /etc/systemd/system/multi-user.target.wants/{{ service }}

{% endfor %}

# remove timer and service units
c2t_remove_omv_systemd:
  module.run:
    - file.find:
      - path: "/var/lib/openmediavault/systemd"
      - iname: "{{ prefix }}*"
      - delete: "f"

cron2timer_convert_userdefined:
  cmd.run:
    - name: "if /usr/local/bin/cron2timer /etc/cron.d/openmediavault-userdefined; then rm -f /etc/cron.d/openmediavault-userdefined; fi"


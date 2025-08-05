# Use systemd timers instead of cron jobs for rsync in OpenMediaVault
#
# @license   MIT License
# @author    Simone Karin Lehmann - skl at lisanet dot de
# @copyright Copyright (c) 2025 Simone Karin Lehmann

{% set jobs = salt['omv_conf.get']('conf.service.rsync.job') %}
{% set systemd_dir = salt['pillar.get']('default:OMV_SYSTEMD_DIR', '/var/lib/openmediavault/systemd') %}
{% set prefix = salt['pillar.get']('default:OMV_SYSTEMD_RSYNC_PREFIX', 'omv-rsync-') %}
{% set scripts_dir = salt['pillar.get']('default:OMV_CRONSCRIPTS_DIR', '/var/lib/openmediavault/cron.d') %}
{% set script_prefix = salt['pillar.get']('default:OMV_RSYNC_CRONSCRIPT_PREFIX', 'rsync-') %}

{% set services = salt['file.find'](path = '/etc/systemd/system', name = prefix ~ '*.service') %}
{% for service_path in services %}
{% set service = service_path.split('/')[-1] %}
{% set timer = service | replace('.service', '.timer') %}

stop_disable_{{ timer }}:
  cmd.run:
    - name: systemctl stop {{ timer }}; systemctl disable {{ timer }} {{ service }}
    - onlyif: test -L /etc/systemd/system/timers.target.wants/{{ timer }}

stop_disable_{{ service }}:
  cmd.run:
    - name: systemctl stop {{ service }}; systemctl disable {{ service }}
    - onlyif: test -L /etc/systemd/system/multi-user.target.wants/{{ service }}

{% endfor %}

remove_rsync_systemd_units:
  module.run:
    - file.find:
      - path: "{{ systemd_dir }}"
      - iname: "{{ prefix }}*"
      - delete: "f"

remove_rsync_systemd_scripts:
  module.run:
    - file.find:
      - path: "{{ scripts_dir }}"
      - iname: "{{ script_prefix }}*"
      - delete: "f"

create_rsync_systemd_dir:
  file.directory:
    - name: "{{ systemd_dir }}"
    - makedirs: True

create_rsync_scripts_dir:
  file.directory:
    - name: "{{ scripts_dir }}"
    - makedirs: True

{% for job in jobs | selectattr('enable')%}
{% set rsync_id = loop.index ~ '-' ~ job.uuid[:8] %}
{% set service = prefix ~ rsync_id ~ '.service' %}
{% set timer = prefix ~ rsync_id ~ '.timer' %}
{% set service_path = systemd_dir | path_join(service) %}
{% set timer_path = systemd_dir | path_join(timer) %}
{% set script_path = scripts_dir | path_join(script_prefix ~ job.uuid) %}

create_rsync_systemd_{{ job.uuid }}_script:
  file.managed:
    - name: "{{ script_path }}"
    - source:
      - salt://{{ tpldir }}/files/cron-rsync-script.j2
    - context:
        job: {{ job | json }}
    - template: jinja
    - user: root
    - group: root
    - mode: 750

create_rsync_systemd_{{ job.uuid }}_service:
  file.managed:
    - name: "{{ service_path }}"
    - source:
      - salt://{{ tpldir }}/files/rsync_service.j2
    - template: jinja
    - context:
        job: {{ job | json }}
        script_path: "{{ script_path }}"
    - user: root
    - group: root
    - mode: 644

create_rsync_systemd_{{ job.uuid }}_timer:
  file.managed:
    - name: "{{ timer_path }}"
    - source:
      - salt://{{ tpldir }}/files/rsync_timer.j2
    - template: jinja
    - context:
        job: {{ job | json }}
        rsync_id: "{{ rsync_id }}"
    - user: root
    - group: root
    - mode: 644

link_enable_{{ job.uuid }}_timer_service:
  cmd.run:
    - name: systemctl link {{ timer_path }} {{ service_path }}; systemctl enable --now {{ timer }}

{% endfor %}

transition_remove_rsync_crontab:
  file.absent:
    - name: /etc/cron.d/openmediavault-rsync

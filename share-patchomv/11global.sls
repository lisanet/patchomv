{% set config = salt['omv_conf.get']('conf.service.smb') %}

remove_old_extra_options:
  file.replace:
    - name: "/etc/samba/smb.conf"
    - pattern: '^# Extra options.*'
    - repl: ""
    - flags: ['DOTALL', 'MULTILINE']
    - backup: False

configure_samba_global_mac:
  file.append:
    - name: "/etc/samba/smb.conf"
    - sources:
      - salt://{{ tpldir }}/files/global-mac.j2
    - template: jinja
    - context:
        config: {{ config | json }}
    - watch_in:
      - service: start_samba_service

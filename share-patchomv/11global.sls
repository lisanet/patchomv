# macOS global settings

{% set config = salt['omv_conf.get']('conf.service.smb') %}

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

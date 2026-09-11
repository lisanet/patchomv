{% set config = salt['omv_conf.get']('conf.service.smb') %}
{%- set fruit_model = salt['pillar.get']('default:OMV_SAMBA_HOMES_FRUIT_MODEL', 'MacSamba') -%}

remove_old_posix_rename:
  file.replace:
    - name: "/etc/samba/smb.conf"
    - pattern: 'fruit:posix_rename.*\n'
    - repl: ""
    - backup: False

remove_fruit_model_shares:
  file.replace:
    - name: "/etc/samba/smb.conf"
    - pattern: 'fruit:model.*\n'
    - repl: ""
    - backup: False

add_fruit_model_global:
  file.replace:
    - name: "/etc/samba/smb.conf"
    - pattern: '# fruit_model.*'
    - repl: "fruit:model = {{ fruit_model }}" 
    - backup: False

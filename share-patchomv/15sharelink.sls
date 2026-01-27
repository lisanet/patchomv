{% set sharedfolder_config = salt['omv_conf.get']('conf.system.sharedfolder') | rejectattr('name', 'equalto', 'home') | list %}
{% set shares = "/shares"  %}
{% set existing_files = salt['file.readdir'](shares) or [] %}

create_sharelink_shares_dir:
  file.directory:
    - name: {{ shares }}
    - user: root
    - group: users
    - mode: 775

{% for sharedfolder in sharedfolder_config %}
{% set sharedfolder_path = salt['omv_conf.get_sharedfolder_path'](sharedfolder.uuid) %}
create_sharelink_{{ sharedfolder.uuid }}:
  file.symlink:
    - name: {{ shares }}/{{ sharedfolder.name }}
    - target: {{ sharedfolder_path }}

{% endfor %}

{% for entry in existing_files %}
{% if entry not in ['.', '..'] and entry not in sharedfolder_config | map(attribute='name') %}
remove_sharelink_orphaned_{{ entry }}:
  file.absent:
    - name: {{ shares }}/{{ entry }}
    - onlyif: test -L "{{ shares }}/{{ entry }}"

{% endif %}
{% endfor %}

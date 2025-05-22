# beautify smb.conf

beautify_smb_conf:
  cmd.run:
    - name: "cp /etc/samba/smb.conf /etc/samba/smb.conf.omv; testparm -s > /tmp/smbconf; cp /tmp/smbconf /etc/samba/smb.conf; rm /tmp/smbconf"

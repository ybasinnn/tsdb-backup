# backup_user Ansible role

Creates the service user that runs the backups (`tsbackup` by default). The `backup_monitoring_data` role imports it, so you don't need to call it yourself.

The role has no defaults of its own: every variable is set by the calling role (see [`backup_monitoring_data/defaults/main.yml`](../backup_monitoring_data/defaults/main.yml)). If a child role defined defaults too, they would override the parent's values, which is confusing.

## Variables

| Variable | Example | Notes |
| --- | --- | --- |
| `backup_user` | `tsbackup` | User and group name. Avoid `backup`, which is a built-in Ubuntu system user. |
| `backup_user_comment` | `"TS backup service user"` | |
| `backup_user_uid` / `backup_user_gid` | `2001` | |
| `backup_user_homedir` | `/opt/tsbackup` | |
| `backup_user_groups` | `[docker]` | Extra groups. `docker` lets the user stop and start the Compose stacks. |
| `backup_user_shell` | `/bin/bash` | |
| `backup_user_create_home` | `true` | |
| `backup_user_sudoers_configs` | see below | Optional. Files copied into `/etc/sudoers.d/`. |
| `backup_user_authorized_keys_enabled` | `false` | Set to `true` to deploy an SSH public key for the user. |
| `backup_user_authorized_keys_content` | `"{{ lookup('file', 'authorized_keys') }}"` | Required only when the option above is `true`. |

## Example

```yaml
- hosts: all
  become: true
  vars:
    backup_user: tsbackup
    backup_user_comment: "TS backup service user"
    backup_user_uid: 2001
    backup_user_gid: 2001
    backup_user_homedir: /opt/tsbackup
    backup_user_groups: [docker]
    backup_user_shell: /bin/bash
    backup_user_create_home: true
    backup_user_authorized_keys_enabled: false
    backup_user_sudoers_configs:
      - src: etc/sudoers.d/user_tsbackup
        dest: /etc/sudoers.d/user_tsbackup
        owner: root
        group: root
        mode: "0440"
  roles:
    - backup_user
```

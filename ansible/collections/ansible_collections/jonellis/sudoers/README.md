# Ansible Sudoers Module

This is a basic Ansible module to facilitate adding Sudoers config to the /etc/sudoers.d/ directory.
While does manage to distribute the sudoers library directory, Ansible galaxy does not seem to show any content.
I assume you're supposed share more than supporting libraries...

This module does not currently attempt to support all options supported by Sudoers.
The case this module currently handles is when a Sudoers rule to grant a single or list of commands (or `ALL`) sudo access with or without a password requirement.

It supports granting by user or by group.

It does not currently support aliases, but it is probably not too difficult to add.

## Examples

##### Allow the `backup` user to run `sudo /usr/local/bin/backup` without requiring a password

```
- sudoers:
    name: allow-backup
    user: backup
    command: /usr/local/bin/backup
```

This will create a file `/etc/sudoers.d/allow-backup` containing:

```
backup ALL=NOPASSWD: /usr/local/bin/backup\n`
```

##### Allow the `monitoring` group to run `sudo /usr/local/bin/gather-app-metrics` without requiring a password

```
- sudoers:
    name: monitor-app
    group: monitoring
    command: /usr/local/bin/gather-app-metrics
```

This will create a file `/etc/sudoers.d/monitor-app` containing:

```
%monitoring ALL=NOPASSWD: /usr/local/bin/gather-app-metrics\n`
```

##### Allow `alice` to run `sudo /bin/systemctl restart my-service` or `sudo /bin/systemctl reload my-service`, but a password is required

```
- sudoers:
    name: alice-service
    user: alice
    command:
      - /bin/systemctl restart my-service
      - /bin/systemctl reload my-service
    nopassword: false
```

This will create a file `/etc/sudoers.d/alice-service` containing:

```
alice ALL=: /bin/systemctl restart my-service, /bin/systemctl reload my-service\n`
```

##### Revoke the previous sudo grants given to `alice`

```
- sudoers:
    name: alice-service
    state: absent
```

This will delete the file at `/etc/sudoers.d/alice-service`.

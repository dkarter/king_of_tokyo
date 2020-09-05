#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright: (c) 2019, Jon Ellis <ellis.jp@gmail.com>

from __future__ import absolute_import, division, print_function
__metaclass__ = type

ANSIBLE_METADATA = {'metadata_version': '2.8',
                    'status': ['unstableinterface'],
                    'supported_by': 'no-one'}

DOCUMENTATION = '''
---
module: sudoers
short_description: Manage Linux sudoers
description:
    - Manage Linux sudoers
options:
    command:
        required: true
        description:
            - The command allowed by the sudoers rule
            - Multiple can be added by passing a list of commands
        type: list
    group:
        required: false
        description:
            - Name of the group for the sudoers rule (cannot be used in conjunction with user)
    name:
        required: true
        description:
            - Name of the sudoers rule
    nopassword:
        required: false
        description:
            - Whether a password will be required to run the sudo'd command
        default: true
    state:
        required: false
        default: "present"
        choices: [ present, absent ]
        description:
            - Whether the rule should exist or not
    user:
        required: false
        description:
            - Name of the user for the sudoers rule (cannot be used in conjunction with group)
'''

EXAMPLES = '''
# Allow backup user to sudo /usr/local/bin/backup
- sudoers:
    name: allow-backup
    state: present
    user: backup
    command: /usr/local/bin/backup
'''

class Sudoers (object) :

    def __init__ (self, module) :
        self.module = module
        self.name = module.params['name']
        self.user = module.params.get('user')
        self.group = module.params.get('group')
        self.state = module.params['state']
        self.nopassword = bool(module.params.get('nopassword', True))
        self.file = '/etc/sudoers.d/{}'.format(self.name)

        command = module.params['command']
        if isinstance(command, list):
            self.commands = command
        else:
            self.commands = [command]

    def write(self):
        with open(self.file, 'w') as f:
            f.write(self.content())

    def delete(self):
        os.remove(self.file)

    def exists(self):
        return os.path.exists(self.file)

    def matches(self):
        with open(self.file, 'r') as f:
            return f.read() == self.content()

    def content(self):
        if self.user:
            owner = self.user
        elif self.group:
            owner = '%{}'.format(self.group)

        command_str = ', '.join(self.commands)
        nopasswd_str = 'NOPASSWD' if self.nopassword else ''
        return "{} ALL={}: {}\n".format(owner, nopasswd_str, command_str)

    def check(self):
        try:
            if self.state == 'absent' and self.exists():
                changed = True
            elif self.state == 'present':
                if not self.exists():
                    changed = True
                elif not self.matches():
                    changed = True
                else:
                    changed = False
            else:
                changed = False
        except Exception as e:
            self.module.fail_json (msg = str(e))

        self.module.exit_json (changed = changed)

    def run(self):
        changed = False

        try:
            if self.state == 'absent' and self.exists():
                self.delete()
                changed = True
            elif self.state == 'present':
                if not self.exists():
                    self.write()
                    changed = True
                elif not self.matches():
                    self.write()
                    changed = True
                else:
                    changed = False
            else:
                changed = False

        except Exception as e :
            self.module.fail_json (msg = str (e))

        self.module.exit_json (changed = changed)


def main ():

    argument_spec = {
        'command': {
            'type': 'list',
            'elements': 'str',
            'default': []
        },
        'group': {},
        'name': {
            'required': True
        },
        'state': {
            'default': 'present',
            'choices': ['present', 'absent']
        },
        'user': {},
    }
    mutually_exclusive = [['user', 'group']]

    module = AnsibleModule (
        argument_spec=argument_spec,
        mutually_exclusive=mutually_exclusive,
        supports_check_mode=True,
    )

    sudoers = Sudoers(module)

    if module.check_mode:
        sudoers.check()
    else:
        sudoers.run()

from ansible.module_utils.basic import *
main()

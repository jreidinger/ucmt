# UCMT
Unified Config Management Tool

## Project Description

The main goal is to provide tool for local configuration that allows easy transition to 1:N management. So here is vision:

- frontend: web-UI, GUI, TUI, CLI, whatever, for now lets start with CLI
- backend: salt/puppet/chef/ansible/cfengine. In general write config for CM and not config files directly itself.
- features: discovery/edit/create/apply on top of backend. Each step separated, so user can e.g. apply itself by using CM directly.
- default value is keep value as it is, so anything not specific is not modified, but when something is specified then it can "eat" modifications as do salt and others
- supported distros - openSUSE, SLE, ubuntu, debian, fedora at least
- communication between frontend and backend is a CLI and YAML file with defined structure, but not aiming to be any kind of new standard, just textual configuration to transfer data in human readable form.

### Advantages:

- easily extensible as it use plugins like e.g. git
- can run as service similar way like e.g. salt server can run it via ssh
- easy move from 1:1 to 1:N
- does not repeat what CM can already do and gets many features for free.
- distro agnostic, so user can use same tool in heterogenous environment
- can work remotely

### Disadvantages:

- Overwrite manual changes
- less features/configuration options then specialized tools like YaST

### Use Cases:

- I have one server that I am taking care. And as my project start growing I need more of them and want to have it consistently configured. So easily move from 1:1 to 1:N.
- Company already use salt and I get a task to manage also FTP server configuration over it. I want to experiment with it at first on single server with some UI that allows me to quickly create initial config and then tune it with more advanced settings.
- Company bought another one and they use salt and we are using ansible. Goal is to unify it. I want tool that helps me with conversion.
- I want to start with ansible and prefer GUI for easy start.
- We have old server and need to migrate it. I want a tool that helps me with digging what is in it.

### API Proposal:

- as said above communication is done via CLI and yaml file
- discovery using some CM tool to discover and convert to YAML
- backend is just CLI that do YAML->target file(-s) for given CM
- frontend works on top of YAML + can call that CLI
- apply is just different CLI for given backend, additional features like dry run can be also supported by this CLI. machine output is must have

## Discovery

There is discovery tool that try to extract yaml file describing configuration from system. It uses ansible as it is faster then salt-call to get that info. It can also extract info without root access, but information is mroe limited.

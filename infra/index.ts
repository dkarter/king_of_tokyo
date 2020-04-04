import * as Pulumi from '@pulumi/pulumi';
import * as DigitalOcean from '@pulumi/digitalocean';
import * as fs from 'fs';

const projectName = Pulumi.getProject();
const config = new Pulumi.Config();

const sshPubKeyFilename = config.require('sshPubKeyFilename');
const publicKey = fs.readFileSync(sshPubKeyFilename).toString();

const sshKeyName = config.require('sshKeyName');

const sshKey = new DigitalOcean.SshKey(sshKeyName, {
  name: sshKeyName,
  publicKey,
});

const droplet = new DigitalOcean.Droplet(`${projectName}-web`, {
  size: DigitalOcean.DropletSlugs.DropletS1VCPU1GB,
  region: DigitalOcean.Regions.SFO2,
  image: 'docker-18-04',
  monitoring: true,
  ipv6: true,
  sshKeys: [sshKey.fingerprint],
});

const domainName = config.require('domainName');

const domain = new DigitalOcean.Domain(domainName, {
  name: domainName,
  ipAddress: droplet.ipv4Address,
});

new DigitalOcean.Project(projectName, {
  name: domainName,
  resources: [
    droplet.id.apply(id => `do:droplet:${id}`),
    domain.id.apply(id => `do:domain:${id}`),
  ],
});

const defaultFirewallAddresses = ['0.0.0.0/0', '::/0'];

new DigitalOcean.Firewall(`${projectName}-firewall`, {
  inboundRules: [
    {
      protocol: 'tcp',
      portRange: '22',
      sourceAddresses: defaultFirewallAddresses,
    },
    {
      protocol: 'tcp',
      portRange: '80',
      sourceAddresses: defaultFirewallAddresses,
    },
    {
      protocol: 'tcp',
      portRange: '443',
      sourceAddresses: defaultFirewallAddresses,
    },
  ],
  outboundRules: [
    {
      protocol: 'icmp',
      portRange: '1-65535',
      destinationAddresses: defaultFirewallAddresses,
    },
    {
      protocol: 'tcp',
      portRange: '1-65535',
      destinationAddresses: defaultFirewallAddresses,
    },
    {
      protocol: 'udp',
      portRange: '1-65535',
      destinationAddresses: defaultFirewallAddresses,
    },
  ],
  dropletIds: [droplet.id.apply(i => +i)],
});

export const ip = droplet.ipv4Address;
export const ipv6 = droplet.ipv6Address;

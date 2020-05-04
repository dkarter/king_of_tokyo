# KingOfTokyo

![Elixir CI](https://github.com/dkarter/king_of_tokyo/workflows/Elixir%20CI/badge.svg)

A "King of Tokyo" Game Written in Elixir, Phoenix and Phoenix Live View.

I created this app for playing one of my favorite board games in the age of social distancing. It is meant to be used in a multi person video chat app, such as Zoom.

The person who owns the game needs to point a camera at the cards and share them with the rest of the group. Every player must then go to [https://theking.live](https://theking.live) and join the same room code.

## Running

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `yarn install --cwd assets`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Deployment

1. Set up a [DigitalOcean](https://m.do.co/c/8cd5d34769f8) account

2. Get an API token from the API section on the sidebar and export an API token like so:

```bash
$ export DIGITALOCEAN_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

3. Create an ssh key for the project for the project:

```bash
$ ssh-keygen -f ~/.ssh/theking
```

4. Install Pulumi dependencies:

```bash
$ yarn --cwd infra
```

5. Run Pulumi to associate your ssh key, create a droplet, domain and firewall:

```bash
$ mix pulumi up
```

6. Store the Ansible Vault password in `ansible/.vault-password`

7. Run Ansible to provision the droplet:

```bash
$ mix ansible
```

8. Build the release using edeliver:

```bash
$ mix edeliver build release
```

9. Deploy using edeliver:

```bash
$ mix edeliver deploy release to production --version=VERSION_FROM_RELEASE_OUTPUT --start-deploy
```

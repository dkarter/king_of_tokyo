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
export DIGITALOCEAN_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

3. Create an ssh key for the project for the project like so:

```bash
ssh-keygen
```

4. Run pulumi to create a droplet, domain and firewall:

```bash
pushd infra/ && yarn && pulumi up ; popd
```

5. Run ansible to provision the droplet:

```bash
pushd ansible/ && ansible-playbook main.yml ; popd
```

6. Build the release using edeliver:

```bash
mix edeliver build release
```

7. Deploy using edeliver:

```bash
mix edeliver deploy release to production
```

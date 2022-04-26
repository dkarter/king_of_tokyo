<p align="center">
  <img src="./king.svg" width="250" />
</p>


<img alt="The King Live" src="./assets/static/images/logo.png" width="250" /> &nbsp;&nbsp; ![Elixir CI](https://github.com/dkarter/king_of_tokyo/workflows/Elixir%20CI/badge.svg)

An online multiplayer game inspired by the King Of Tokyo board game. 

Written in Elixir, Phoenix and Phoenix LiveView.

I created this app to enable playing one of my favorite board games in the age of social distancing. It is meant to be used in a multi person video chat app, such as Zoom, with **at least one person in the group owning a copy of the original board game**.

The person who owns the game needs to point a camera at the cards and share them with the rest of the group. Every player must then go to [https://theking.live](https://theking.live) and join the same room code.

## Disclaimer
I do not own or claim to own the copyrights or trademark to King of Tokyo board game by Richard Garfield and IELLO. This application was built for educational purposes only and you must own the original game to play it. The purpose of this application is not to replace the original game, but to enable playing it over a video conferencing software.

If you enjoy it - please [purchase the game from IELLO and support the authors](https://iellousa.com/collections/king-of-tokyo-collection/products/king-of-tokyo).

## Running

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `yarn install --cwd assets`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Deployment

1. Set up a [DigitalOcean](https://m.do.co/c/8cd5d34769f8) account

2. Get an API token from the API section on the sidebar and export an API token like so:

    ```sh
    $ export DIGITALOCEAN_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    ```

3. Create an ssh key for the project:

    ```sh
    $ ssh-keygen -f ~/.ssh/theking
    ```

4. Install Pulumi dependencies:

    ```sh
    $ yarn --cwd infra
    ```

5. Run Pulumi to associate your ssh key, create a droplet, domain and firewall:

    ```sh
    $ mix pulumi up
    ```

6. Store the Ansible Vault password in `ansible/.vault-password`

7. Run Ansible to provision the droplet:

    ```sh
    $ mix ansible
    ```

8. Deploy using edeliver:

    ```sh
    $ mix edeliver update production --branch=[OPTIONAL_BRANCH_TO_DEPLOY]
    ```

    (do not use edeliver's restart / start / stop - the app will automatically
    restart the systemd service when deployed)

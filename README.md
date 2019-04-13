# Phoenix API App LunchboxAPI backed by CockroachDB
##### Setting up local dev env with 3x nodes of CockroachDB clustered.
  * Spin up 3 nodes of cockroachdb 2.1 and link them up as a singular cluster:
  ```
  > bash _build/dev/rel/lunchbox_api/releases/0.1.0/commands/start_cdb_cluster.sh
  ```
  * Test you can connect to either one of the cockroachdb node:
  ```
  > cockroach sql --insecure --host=localhost:26257
  ```
  * Verify [CockroachDB Admin UI](https://www.cockroachlabs.com/docs/stable/admin-ui-overview-dashboard.html) is reachable and check monitoring status of your cockroachdb cluster at `http://localhost:8080`.
 ---
##### Setting up local dev/test elixir-phoenix env with postgrex-cdb and ecto_replay_sandbox (used in testing) connecting to local clustered CockroachDB.
  * Update local hex with `mix local.hex --force`.
  * Install dependencies with `mix deps.get`.
  * Change `config/dev.exs` and `config/test.exs` to have `Repo` `username` as `root` and no `password` and include `port` pointing to 1 instance of running CockroachDB node:
  ```
  config :lunchbox_api, LunchboxApi.Repo,
    username: "root",
    password: "",
    database: "lunchbox_api_dev",
    hostname: "localhost",
    port:      26257,
    pool_size: 10
  ```
  * Create and migrate your database with `mix ecto.setup`.
  * Run `mix ecto.migrate`.
  * Run tests.
  ```
  DB_PORT=26257 mix test
  ```
---
##### Running and interacting with local instance of lunchbox_api phoenix app with local clustered CockroachDB.
  * Start lunchbox_api phoenix app with:
  ```
  PHX_PORT=7000 DB_PORT=26257 mix phx.server
  ```
  * Signup for an account via `http://localhost:7000/api/v1/sign_up` by entering a desired user name and password
  * Copy the JWT auth Bearer token returned for your above sign-up
  * Login using JWT auth Bearer token to proceed at `http://localhost:7000/api/v1/sign_in` using user name and password used for sign_up
  * Hit lunchbox_api REST endpoint at `http://localhost:4000/api/v1/foods` from your browser, setting your JWT auth Bearer token received from your login into the POST request 'authentication' HEADER
  * Use [Insomnia](https://insomnia.rest/) to test above `GET` query supplying JWT auth Bearer token in 'authentication' HEADER of GET request and expect response as (assuming fresh clean empty cockroachdb instance):
  ```
  {"data":[]}
  ```
  * Test `POST` to create a food record using Insomnia to `http://localhost:4000/api/v1/foods` using sample `POST` JSON payload:
  ```
  {
    "food": {
      "name": "coffee",
      "status": "roasted"
    }
  }
  ```
  * Visit [`http://localhost:4000`](http://localhost:4000) from your browser. Route for root of web app is connected to same api `GET` route of `/api/v1/foods` and you should thus see response of JSON payload as (given above `POST` succeeded):
  ```
  {
    "data": [
        {
          "id": 430696076795871233,
          "name": "coffee",
          "status": "roasted"
        }
    ]
  }
  ```
---
##### Setup and configure Gigalixir account-app and deploy distillery OTP release to Gigalixir and run lunchbox_api against PostgreSQL.
  * Generate prod OTP release for release into Gigalixir (**N/B: currently gigalixir only has PostgreSQL; However, the code will work as-is**)
  ```
  MIX_ENV=prod mix release --env=prod
  ```
  * Create gigalixir app `APP_NAME=$(gigalixir create)`
  * Verify app created in gigalixir `gigalixir apps` and expect something similar as:
  ```
  [
    {
      "cloud": "gcp",
      "region": "v2018-us-central1",
      "replicas": 1,
      "size": 0.3,
      "stack": "gigalixir-14",
      "unique_name": "blue-glistening-xenopus"
    }
  ]
  ```
  * Check config `gigalixir config`
  ```
  {}
  ```
  * Create free-tier PostgreSQL DB in gigalixir `gigalixir pg:create --free`
  * Obtain instantiated `DATABASE_URL` and update `config/prod.exs`
  ```
  {
    "DATABASE_URL": "ecto://2dd78a9e-7870-455c-842f-322f4c405dca-user:pw-b3f386dd-9c0b-4125-8290-218d8ab89011@postgres-free-tier-1.gigalixir.com:5432/2dd78a9e-7870-455c-842f-322f4c405dca"
  }
  ```
  * Add gigalixir env config to store BASIC AUTH credentials:
  ```
  gigalixir config:set DB_PORT=5432,
  gigalixir config:set PHX_PORT=7000,
  gigalixir config
  {
    "DB_PORT": 5432
    "PHX_PORT": 7000,
    "DATABASE_URL": "ecto://2dd78a9e-7870-455c-842f-322f4c405dca-user:pw-b3f386dd-9c0b-4125-8290-218d8ab89011@postgres-free-tier-1.gigalixir.com:5432/2dd78a9e-7870-455c-842f-322f4c405dca"
  }
  ```
  * Add your ssh key to gigalixir for ssh command access
  ```
  gigalixir add_ssh_key "$(cat ~/.ssh/id_rsa.pub)"
  ```
  * Git commit and deploy to Gigalixir (assuming you've signed up to gigalixir and created an app instance along with your PostgreSQL free-tier DB):
  ```
  git push gigalixir master
  ```
  * Run ecto migrations in Gigalixir (ensure you've a valid account and used the Gigalixir-CLI to perform login):
  ```
  gigalixir ps:migrate
  ```
  * Test your app using `curl`:
    * `SIGNIN`
    ```
    JWT_TOKEN=$(curl -s -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' --data '{"email":"${USERNAME}","password":"${PASSWORD}"}' https://blue-glistening-xenopus.gigalixirapp.com/api/v1/sign_in | jq -r '.jwt')
    ```
    * `GET` list of foods
    ```
    > curl -H "Accept: application/json" -H "Authorization: Bearer ${JWT_TOKEN}" https://blue-glistening-xenopus.gigalixirapp.com/api/v1/foods
    {"data":[]}
    ```
    * `POST`
    ```
    > curl -i -H "Authorization: Bearer ${JWT_TOKEN}" -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d '{"food":{"name":"cheese", "status":"really old and getting stinky"}}' https://blue-glistening-xenopus.gigalixirapp.com/api/v1/foods
    HTTP/2 201
    server: nginx/1.15.8
    date: Sat, 02 Mar 2019 12:50:25 GMT
    content-type: application/json; charset=utf-8
    content-length: 74
    cache-control: max-age=0, private, must-revalidate
    location: /api/v1/foods/3
    x-request-id: 8f39541ccb761c422d1c19ee51f492f1
    via: 1.1 google
    alt-svc: clear

    {"data":{"id":1,"name":"cheese","status":"really old and getting stinky"}}
    ```
    * `GET` list of foods
    ```
    > curl -H "Accept: application/json" -H "Authorization: Bearer ${JWT_TOKEN}" https://blue-glistening-xenopus.gigalixirapp.com/api/v1/foods
    {"data":[{"id":1,"name":"cheese","status":"really old and getting stinky"}]}
    ```

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

### Learn more
  * CockroachDB: https://www.cockroachlabs.com/
  * Postgrex-CDB hex package: https://hexdocs.pm/postgrex_cdb/readme.html
  * EctoReplaySandbox hex package (used in testing): https://hexdocs.pm/ecto_replay_sandbox/readme.html
  * Gigalixir: https://gigalixir.com/
  * Distillery 2.0: https://dockyard.com/blog/2018/08/23/announcing-distillery-2-0
  * Official Phoenix: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

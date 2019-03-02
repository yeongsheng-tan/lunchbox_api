# LunchboxApi

To start your Phoenix server:

  * Update local hex with `mix local.hex --force`
  * Install dependencies with `mix deps.get`.
  * Spin up 3x nodes of cockroachdb 2.1 and link them up as a singular cluster:
  ```
  cockroach start --insecure --listen-addr=localhost &
  
  cockroach start \
            --insecure \
            --store=node2 \
            --listen-addr=localhost:26258 \
            --http-addr=localhost:8081 \
            --join=localhost:26257 &
            
  cockroach start \
            --insecure \
            --store=node3 \
            --listen-addr=localhost:26259 \
            --http-addr=localhost:8082 \
            --join=localhost:26257 &
  ```
  * Test you can connect to either one of the cockroachdb node:
  ```
  cockroach sql --insecure --host=localhost:26257
  ```
  * Verify admin UI is reachable and check monitoring status of your cockroachdb cluster at `http://localhost:8080`.
  * Create and migrate your database with `mix ecto.setup`.
  * Run `mix ecto.migrate`.
  * Run tests
  ```
  BASIC_AUTH_USERNAME=specialUserName BASIC_AUTH_PASSWORD=superSecretPassword mix test
  ```
  * Start lunchbox_api app with:
  ```
  BASIC_AUTH_USERNAME=specialUserName BASIC_AUTH_PASSWORD=superSecretPassword mix phx.server
  ```
  * Hit lunchbox_api REST endpoint at `http://localhost:4000/api/v1/foods`. You will be prompted for `BASIC_AUTH` and login using `BASIC_AUTH_USERNAME` and `BASIC_AUTH_PASSWORD` used to start phoenix server.
  * Use [Insomnia](https://insomnia.rest/) to test above `GET` query supplying `BASIC_AUTH` details as above and expect response as (assuming fresh clean empty cockroachdb instance):
  ```
  {"data":[]}
  ```
  * Test POST to create a food record using Insomnia to `http://localhost:4000/api/v1/foods` using sample `POST` JSON payload:
  ```
  {
    "food": {
      "name": "coffee",
      "status": "roasted"
    }
  }
  ```
  * Visit [`localhost:4000`](http://localhost:4000) from your browser. Route for root of web app is connected to same api `GET` route of `/api/v1/foods` and you should thus see response of JSON payload as (given above `POST` succeeded):
  ```
  {"data":[{"id":430696076795871233,"name":"coffee","status":"roasted"}]}
  ```
  * Generate prod OTP release
  ```
  BASIC_AUTH_USERNAME=specialUserName BASIC_AUTH_PASSWORD=superSecretPassword MIX_ENV=prod mix release --env=prod
  ```
  * Git commit and deploy to Gigalixir (assuming you've signed up to gigalixir and created an app instance along with your PostgreSQL free-tier DB):
  ```
  git push gigalixir master
  ```
  * Run ecto migrations in Gigalixir (ensure you've a valid account and used the Gigalixir-CLI to perform login):
  ```
  gigalixir ps:migrate
  ```

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more
  * CockroachDB website: https://www.cockroachlabs.com/
  * Gigalixir website: https://gigalixir.com/
  * Distillery 2.0: https://dockyard.com/blog/2018/08/23/announcing-distillery-2-0
  * Official Phoenix website: http://www.phoenixframework.org/
  * Postgrex-CDB hex package: https://hexdocs.pm/postgrex_cdb/readme.html
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

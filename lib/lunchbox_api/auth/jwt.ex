defmodule LunchboxApi.Auth.JWT do
  @moduledoc """
  JWT token generation and verification.
  """
  use Joken.Config

  @behaviour LunchboxApi.Auth.JWT.Behaviour

  @impl true
  def token_config do
    default_claims(skip: [:aud, :iss])
    |> add_claim(
      "iss",
      fn -> "lunchbox_api" end,
      &(&1 == "lunchbox_api")
    )
    |> add_claim(
      "aud",
      fn -> "lunchbox_api_client" end,
      &(&1 == "lunchbox_api_client")
    )
  end

  # Use the configured signer for the environment
  def signer do
    Joken.Signer.create("HS256", Application.get_env(:joken, :default_signer, "default_secret"))
  end

  @doc """
  Generates a JWT token for the given user.
  """
  @impl true
  @spec generate_token(map()) :: {:ok, String.t()}
  def generate_token(user) do
    extra_claims = %{
      "sub" => to_string(user.id),
      "email" => user.email,
      "name" => user.name,
      "provider" => user.provider
    }

    {:ok, token, _claims} = generate_and_sign(extra_claims, signer())
    {:ok, token}
  end

  @doc """
  Verifies a JWT token and returns the claims.
  """
  @impl true
  @spec verify_token(String.t()) :: {:ok, map()} | {:error, String.t()}
  def verify_token(token) do
    case verify_and_validate(token, signer()) do
      {:ok, claims} -> {:ok, claims}
      {:error, reason} -> {:error, "Invalid token: #{inspect(reason)}"}
    end
  end
end

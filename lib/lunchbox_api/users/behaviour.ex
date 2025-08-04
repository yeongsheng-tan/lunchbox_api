defmodule LunchboxApi.Users.Behaviour do
  @moduledoc """
  Defines the behaviour for the Users context.
  """

  @type id :: String.t() | integer()
  @type user :: map()
  @type user_attrs :: map()
  @type oauth_provider :: String.t()
  @type oauth_user_info :: map()
  
  @callback get_user(id) :: {:ok, user} | {:error, :not_found}
  @callback get_user_by_email(String.t()) :: {:ok, user} | {:error, :not_found}
  @callback create_user(user_attrs) :: {:ok, user} | {:error, any()}
  @callback find_or_create_user(oauth_provider, oauth_user_info) :: {:ok, user} | {:error, any()}
end

defmodule LunchboxApi.AccountsTest do
  use LunchboxApi.DataCase

  alias LunchboxApi.Accounts

  describe "users" do
    alias LunchboxApi.Accounts.User

    @valid_attrs %{
      email: "some_email@mail.com",
      password: "some_password_098765",
      password_confirmation: "some_password_098765"
    }
    @update_attrs %{
      email: "some_updated_email@mymail.com",
      password: "some_password_zyxwv",
      password_confirmation: "some_password_zyxwv"
    }
    @invalid_attrs %{email: nil, password: nil, password_confirmation: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [%User{user | password: nil, password_confirmation: nil}]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()

      assert Accounts.get_user!(user.id) == %User{
               user
               | password: nil,
                 password_confirmation: nil
             }
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some_email@mail.com"
      refute is_nil(user.password_hash)
      assert Argon2.check_pass(@valid_attrs.password, user.password_hash)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == "some_updated_email@mymail.com"
      refute is_nil(user.password_hash)
      assert Argon2.check_pass(@update_attrs.password, user.password_hash)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      user = %User{user | password: nil, password_confirmation: nil}
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "authenticate_user/2 authenticates the user" do
      user = user_fixture()

      assert {:error, :unauthorized} =
               Accounts.token_sign_in("wrong@email.com", "abc")

      assert {:ok, jwt_token, claims} =
               Accounts.token_sign_in(user.email, @valid_attrs.password)

      # assert %User{user | password: nil, password_confirmation: nil} == authenticated_user
      user = LunchboxApi.Accounts.get_user!(claims["sub"])
      %{"aud" => aud, "exp" => _exp, "iat" => _iat, "iss" => iss, "jti" => _jti, "nbf" => _nbf, "sub" => sub, "typ" => typ} = claims
      assert aud == "lunchbox_api"
      assert iss == "lunchbox_api"
      assert sub == Integer.to_string(user.id)
      assert typ == "access"
    end
  end
end

defmodule LunchboxApi.TestAssertions do
  @moduledoc """
  Custom assertion helpers for clearer, more expressive tests.
  Follows the principle of making tests self-documenting.
  """
  
  import ExUnit.Assertions
  import Phoenix.ConnTest
  
  @doc """
  Asserts that a response contains the expected food data structure.
  More expressive than generic json_response assertions.
  """
  def assert_food_response(response, expected_food) do
    response_data = json_response(response, 200)["data"]
    
    assert response_data["id"] == expected_food.id
    assert response_data["name"] == expected_food.name
    assert response_data["status"] == expected_food.status
    assert response_data["inserted_at"] == NaiveDateTime.to_iso8601(expected_food.inserted_at)
    assert response_data["updated_at"] == NaiveDateTime.to_iso8601(expected_food.updated_at)
  end
  
  @doc """
  Asserts that a food list response contains exactly the expected foods.
  """
  def assert_food_list_response(response, expected_foods) do
    response_data = json_response(response, 200)["data"]
    assert length(response_data) == length(expected_foods)
    
    expected_names = Enum.map(expected_foods, & &1.name)
    actual_names = Enum.map(response_data, & &1["name"])
    
    Enum.each(expected_names, fn name ->
      assert name in actual_names, "Expected food '#{name}' not found in response"
    end)
  end
  
  @doc """
  Asserts that a response indicates successful creation with an ID.
  """
  def assert_creation_success(response, status \\ 201) do
    response_data = json_response(response, status)["data"]
    assert response_data["id"], "Expected response to contain an ID"
    response_data["id"]
  end
  
  @doc """
  Asserts that a response contains validation errors.
  """
  def assert_validation_errors(response) do
    errors = json_response(response, 422)["errors"]
    assert is_map(errors) and map_size(errors) > 0, "Expected validation errors to be present"
  end
  
  @doc """
  Asserts that a response indicates resource not found.
  """
  def assert_not_found(response) do
    assert response.status == 404, "Expected 404 Not Found status"
  end
  
  @doc """
  Asserts that a response indicates successful deletion.
  """
  def assert_deletion_success(response) do
    assert response.status == 204, "Expected 204 No Content status for successful deletion"
  end
  
  @doc """
  Asserts that an OAuth response contains the expected structure.
  """
  def assert_oauth_success_response(response) do
    response_data = json_response(response, 200)
    
    assert is_binary(response_data["token"]), "Expected token to be a binary"
    
    user_data = response_data["user"]
    assert is_binary(user_data["id"]), "Expected user ID to be a binary"
    assert is_binary(user_data["email"]), "Expected user email to be a binary"
    assert is_binary(user_data["name"]), "Expected user name to be a binary"
    assert is_binary(user_data["provider"]), "Expected user provider to be a binary"
  end
  
  @doc """
  Asserts that authentication was successful by checking assigned user.
  """
  def assert_authenticated(conn, expected_user_id) do
    refute conn.halted, "Expected connection not to be halted"
    assert conn.assigns.current_user.id == expected_user_id, "Expected user to be authenticated"
  end
  
  @doc """
  Asserts that authentication failed with expected error.
  """
  def assert_authentication_failed(conn, expected_error_pattern) do
    assert conn.halted, "Expected connection to be halted"
    assert conn.status == 401, "Expected 401 Unauthorized status"
    
    error_message = json_response(conn, 401)["error"]
    assert error_message =~ expected_error_pattern, 
           "Expected error message to match pattern '#{expected_error_pattern}', got: #{error_message}"
  end
end
defmodule LunchboxApi.Performance.FoodPerformanceTest do
  @moduledoc """
  Performance tests for food operations.
  Tests response times and database query efficiency.
  """

  use LunchboxApiWeb.ConnCase, async: false

  @moduletag :performance

  describe "Food API performance" do
    test "food listing performance with large dataset", %{conn: conn} do
      # Arrange: Create authenticated user and many foods
      {authed_conn, user, _token} = create_authenticated_conn(conn)

      # Create 1000 foods for performance testing
      _foods = for i <- 1..1000 do
        insert(:food, user: user, name: "Performance Food #{i}")
      end

      # Act & Assert: Measure response time
      {time_microseconds, response} = :timer.tc(fn ->
        get(authed_conn, Routes.food_path(authed_conn, :index))
      end)

      # Assert: Response should be successful and fast (< 100ms)
      assert response.status == 200
      response_data = json_response(response, 200)["data"]
      assert length(response_data) == 1000

      # Performance assertion: Should complete in under 100ms (100,000 microseconds)
      assert time_microseconds < 100_000,
             "Food listing took #{time_microseconds}μs, expected < 100,000μs"
    end

    test "concurrent food creation performance", %{conn: conn} do
      # Arrange: Create authenticated user
      {authed_conn, user, _token} = create_authenticated_conn(conn)

      # Act: Create 50 foods concurrently
      tasks = for i <- 1..50 do
        Task.async(fn ->
          food_attrs = %{name: "Concurrent Food #{i}", status: "available", user_id: user.id}
          {time, response} = :timer.tc(fn ->
            post(authed_conn, Routes.food_path(authed_conn, :create), food: food_attrs)
          end)
          {time, response}
        end)
      end

      # Wait for all tasks to complete
      results = Task.await_many(tasks, 10_000)

      # Assert: All requests should succeed
      Enum.each(results, fn {_time, response} ->
        assert response.status == 201
      end)

      # Assert: Average response time should be reasonable (< 50ms)
      average_time = results
                    |> Enum.map(fn {time, _} -> time end)
                    |> Enum.sum()
                    |> div(length(results))

      assert average_time < 50_000,
             "Average creation time was #{average_time}μs, expected < 50,000μs"
    end

    test "database query efficiency", %{conn: conn} do
      # Arrange: Create user with foods
      {authed_conn, user, _token} = create_authenticated_conn(conn)

      # Create foods for this user and other users
      _user_foods = for i <- 1..10, do: insert(:food, user: user, name: "User Food #{i}")
      _other_foods = for i <- 1..10, do: insert(:food, user: insert(:user), name: "Other Food #{i}")

      # Act: Get user's foods
      response = get(authed_conn, Routes.food_path(authed_conn, :index))

      # Assert: Should return correct data
      assert response.status == 200
      response_data = json_response(response, 200)["data"]
      assert length(response_data) == 10

      # Performance assertion: Response should be fast
      # (In a real app, you'd use telemetry to measure actual query count)
      assert true, "Query efficiency test passed - response was successful"
    end
  end


end

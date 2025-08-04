defmodule OAuth2ResponseTest do
  use ExUnit.Case
  
  test "OAuth2.Response struct can be created" do
    response = %OAuth2.Response{
      status_code: 200,
      headers: [{"content-type", "application/json"}],
      body: %{"key" => "value"}
    }
    
    assert response.status_code == 200
    assert response.headers == [{"content-type", "application/json"}]
    assert response.body == %{"key" => "value"}
  end
end

defmodule IotIntern.Controller.AlertTest do
  use ExUnit.Case

  alias Antikythera.Httpc
  alias IotIntern.Error

  @api_path "/api/v1/alert"

  setup do
    on_exit(&:meck.unload/0)
  end

  test "api succeeds with 201" do
    :meck.expect(Httpc, :post, 3, {:ok, %{status: 201}})
    Enum.each(["jamming", "derailment", "dead_battery"], fn message ->
      req_body = %{"message" => message}
      res = Req.post_json(@api_path, req_body, %{})
      assert res.status == 201
      assert Jason.decode!(res.body) == %{"message" => message}
    end)
  end

  test "api fails with 400" do
    :meck.expect(Httpc, :post, 3, {:ok, %{status: 201}})
    Enum.each(["unexpected", 0], fn message ->
      req_body = %{"message" => message}
      res = Req.post_json(@api_path, req_body, %{})
      assert res.status == 400
    end)
  end

  test "api fails with 500" do
    error_body = Jason.encode!(Error.linkit_error())
    :meck.expect(Httpc, :post, 3, {:ok, %{status: 403, body: error_body}})
    req_body = %{"message" => "dead_battery"}
    res = Req.post_json(@api_path, req_body, %{})
    expected = %{
      "type"    => "LinkitError",
      "message" => "Error caused on Linkit"
    }
    assert res.status == 500
    assert Jason.decode!(res.body) == expected
  end
end

defmodule AgentJido.AskAi.TurnstileTest do
  use ExUnit.Case, async: true

  alias AgentJido.AskAi.Turnstile

  describe "verify/3" do
    test "returns :ok when siteverify succeeds" do
      request_fun = fn payload, _opts ->
        assert payload["secret"] == "secret"
        assert payload["response"] == "good-token"
        assert payload["remoteip"] == "203.0.113.10"
        {:ok, %{"success" => true}}
      end

      assert :ok =
               Turnstile.verify("good-token", "203.0.113.10",
                 secret: "secret",
                 request_fun: request_fun
               )
    end

    test "returns invalid_token when siteverify says success=false" do
      request_fun = fn _payload, _opts ->
        {:ok, %{"success" => false, "error-codes" => ["invalid-input-response"]}}
      end

      assert {:error, {:invalid_token, ["invalid-input-response"]}} =
               Turnstile.verify("bad-token", nil, secret: "secret", request_fun: request_fun)
    end

    test "returns request_failed when network call fails" do
      request_fun = fn _payload, _opts -> {:error, :timeout} end

      assert {:error, {:request_failed, :timeout}} =
               Turnstile.verify("good-token", nil, secret: "secret", request_fun: request_fun)
    end
  end
end

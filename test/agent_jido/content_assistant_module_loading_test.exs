defmodule AgentJido.ContentAssistantModuleLoadingTest do
  use ExUnit.Case, async: false

  alias AgentJido.ContentAssistant
  alias AgentJido.ContentAssistant.Response
  alias AgentJido.ContentAssistant.Retrieval

  describe "respond/2 module loading" do
    test "loads retrieval module before export checks" do
      :code.purge(Retrieval)
      :code.delete(Retrieval)

      refute function_exported?(Retrieval, :query_with_status, 2)

      assert {:ok, %Response{} = response} =
               ContentAssistant.respond("how do I build a jido agent?",
                 retrieval_module: Retrieval,
                 llm: nil
               )

      assert response.answer_mode != :error
      assert response.retrieval_status in [:success, :fallback]
      assert function_exported?(Retrieval, :query_with_status, 2)
    end
  end
end

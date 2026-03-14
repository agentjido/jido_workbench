defmodule AgentJido.Jido do
  @moduledoc """
  Application-specific Jido runtime wrapper configured under the `:agent_jido` OTP app.
  """

  use Jido, otp_app: :agent_jido
end

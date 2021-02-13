defmodule MinecraftControllerWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import MinecraftControllerWeb.ConnCase

      alias MinecraftControllerWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint MinecraftControllerWeb.Endpoint

      def assert_response(response, status, expected) do
        string_key_expected = Enum.into(expected, %{}, fn {key, value} -> {to_string(key), value} end)

        assert status == response.status
        assert Jason.decode!(response.resp_body) == string_key_expected
      end
    end
  end

  setup do
    on_exit(&:meck.unload/0)
    [conn: Phoenix.ConnTest.build_conn()]
  end
end

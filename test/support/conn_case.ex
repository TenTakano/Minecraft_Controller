defmodule MinecraftControllerWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use MinecraftController.CommonCase

      import Plug.Conn
      import Phoenix.ConnTest
      import MinecraftControllerWeb.ConnCase

      alias MinecraftControllerWeb.Error
      alias MinecraftControllerWeb.Router.Helpers, as: Routes

      @endpoint MinecraftControllerWeb.Endpoint

      def assert_response(response, status, expected) do
        string_key_expected =
          Enum.into(expected, %{}, fn {key, value} -> {to_string(key), value} end)

        assert response.status == status
        assert Jason.decode!(response.resp_body) == string_key_expected
      end

      def assert_error(response, error_module) do
        {expected_status, expected_body} =
          error_module.new()
          |> Map.from_struct()
          |> Enum.into(%{}, fn {key, value} -> {to_string(key), value} end)
          |> Map.pop("status")

        assert response.status == expected_status
        assert Jason.decode!(response.resp_body) == expected_body
      end
    end
  end

  setup do
    [conn: Phoenix.ConnTest.build_conn()]
  end
end

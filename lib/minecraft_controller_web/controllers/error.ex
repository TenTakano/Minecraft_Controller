defmodule MinecraftControllerWeb.Error do
  defmodule ErrorBase do
    defmacro __using__(default) do
      quote do
        defstruct [:status, :type, :message]

        def new() do
          struct(__MODULE__, unquote(default))
        end
      end
    end
  end

  defmodule BadRequest do
    use ErrorBase, %{
      status: 400,
      type: "BadRequest",
      message: "Given parameters were invalid."
    }
  end

  defmodule ResourceNotFound do
    use ErrorBase, %{
      status: 404,
      type: "ResourceNotFound",
      message: "Specified resource does not exist."
    }
  end

  defmodule InstanceNotFound do
    use ErrorBase, %{
      status: 404,
      type: "InstanceNotFound",
      message: "EC2 instance has not been setup."
    }
  end

  defmodule AwsError do
    use ErrorBase, %{
      status: 409,
      type: "AWSError",
      message: "Something occurs on AWS."
    }
  end
end

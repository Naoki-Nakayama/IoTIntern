defmodule IotIntern.Linkit do
  alias Antikythera.Httpc

  @linkit_base_url  "https://linkit-api.jin-soku.biz"

  def post_message(message) do
    %{
      "linkit_api_key"               => api_key,
      "notification_user_credential" => credential,
      "linkit_app_id"                => app_id,
      "linkit_group_id"              => group_id,
      "chatroom_id"                  => chatroom_id,
    } = IotIntern.get_all_env()

    endpoint_url = Enum.join([
      @linkit_base_url,
      app_id,
      group_id,
      "chatrooms",
      chatroom_id,
      "messages"
    ], "/")

    header = %{
      "authorization" => credential,
      "x-api-key"     => api_key,
    }

    body = %{
      "type"    => "string",
      "message" => message,
    }

    case Httpc.post(endpoint_url, {:json, body}, header) do
      {:ok, %{status: 201}}             -> {201, nil}
      {:ok, %{status: 403, body: body}} -> {403, Jason.decode!(body)}
    end
  end
end

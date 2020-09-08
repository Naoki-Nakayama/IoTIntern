# 課題1
#   以下のコードは空のレスポンスをステータス200で返すようになっています．
#   仕様にそったレスポンスの一例を返すようにAPIを実装してください．
#   （この課題ではリクエストに応じてレスポンスを変える必要はありません）
#
# 課題2
#   課題1を元に，リクエストボディに応じてレスポンスが変わるように実装を変更してください．
#   ただし，33行目から37行目のコメントアウトを解除して用いること．
#   ヒント：リクエストボディは%{body: _body}を%{body: body}とするとbodyをコードで利用することが出来ます
#
# 課題3
#   lib/linkit.exにLinkitのAPIを叩くための関数があります．
#   コメントアウトを解除し，適宜コードを補完して関数を完成させて，Linkitへ通知が送れるようにしてください．
#
# 課題4
#   テストコードの課題を出す予定（TBD）
#
# 課題5
#   新規のAPIを課題として出す予定（TBD）
#
# 課題6
#   Cromaによるバリデーションを課題として出す予定（TBD）

defmodule IotIntern.Controller.Alert do
  use Antikythera.Controller

  alias Antikythera.Conn
  alias IotIntern.{Linkit, Error}

  defmodule RequestBody do
    use Croma

    defmodule Message do
      use Croma.SubtypeOfAtom, values: [:dead_battery, :derailment, :jamming]
    end

    use Croma.Struct, recursive_new?: true, fields: [
      message: Message,
    ]
  end

  def post_alert(%{request: %{body: body}} = conn) do
    case RequestBody.new(body) do
      {:ok,    %{message: message} = validated_body} ->
        case Linkit.post_message(message) do
          {201, nil} -> Conn.json(conn, 201, validated_body)
          _          -> Conn.json(conn, 500, Error.linkit_error())
        end
      {:error, _}              ->
        Conn.json(conn, 400, Error.bad_request_error())
    end
  end
end

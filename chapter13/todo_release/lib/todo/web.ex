defmodule Todo.Web do
  use Plug.Router

  plug :match
  plug :dispatch

  def start_server do
    case Application.get_env(:todo, :port) do
      nil -> raise("Todo port not specified!")
      port ->
        Plug.Adapters.Cowboy.http(__MODULE__, nil, port: port)
    end

  end

  post "/add_entry" do
    conn
    |> Plug.Conn.fetch_params
    |> add_entry
    |> respond
  end

  def add_entry(conn) do
    conn.params["list"]
    |> Todo.Cache.server_process
    |> Todo.Server.add_entry(
      %{
        date: Date.from_iso8601!(conn.params["date"]),
        title: conn.params["title"]
      }
    )

    Plug.Conn.asign(conn, :response, "OK")
  end

  def respond(conn) do
    conn
    |> Plug.Conn.put_resp_content_type("tex/plain")
    |> Plug.Conn.send_resp(200, conn.asigns[:response])
  end

end

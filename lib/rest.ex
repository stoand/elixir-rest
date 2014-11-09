defmodule Rest do
  alias Http.Response
  @moduledoc """
  # Make sure you have [Redis](http://redis.io/download) and [Elixir](http://elixir-lang.org/install.html) installed


  ## Create a new project

  _In the Terminal_

      elixir new my_app

  ## Put the following in your *mix.exs* file:
      
      defmodule MyApp do
        use Mix.Project

        alias Http.Server
        alias Http.Response
        alias Http.Request

        def project do
          [app: :my_app,
           version: "0.0.1",
           elixir: "~> 1.0.0",
           deps: deps]
        end

        def application do
            [applications: [], mod: {__MODULE__, []}]
          end

        def start(_type, _args) do
          auth_func = fn(auth_params, user) ->
            case auth_params do
              # Read
              {"posts", data} -> true
              # Write
              {"posts", newData, data} -> user != nil
              _ -> false
            end
          end

          Server.start(fn(socket) ->
            {:ok, redis} = :eredis.start_link()
            header = Request.header(socket)
            case tl String.split(header.path, "/") do
              ["data" | _] -> Rest.serve(socket, redis, header, auth_func)
              _ ->
                Response.header(socket, 404, "Invalid Url")
                Response.close(socket, "Invalid Url: \#\{header.path}")
            end
          end, 3030)
        end

        defp deps do
          [{:http, github: "Arubaruba/elixir-http"},
            {:eredis, github: "wooga/eredis"}]
        end
      end


  ## Running the project

  _In the Terminal_

      mix deps.get
      mix run --no-halt

  Going to [http://localhost:3030/data/posts](http://localhost:3030/data/posts) should return:\n

      {}

  """

  @doc """
  Handle REST data

  argument | description
  --- | ---
  socket | the socket of a started server
  redis | an eredis link **github "wooga/eredis"**
  header | A parsed request header
  auth_func | a function that validates read and write operations - see example

  ## Sample auth_func
      auth_func = fn(auth_params, user) ->
        case auth_params do
          # Read
          {"posts", data} -> true
          # Write
          {"posts", newData, data} -> user != nil
          _ -> false
        end
      end

  """
  def serve(socket, redis, header, auth_func) do
    case header.method do
      _ ->
        message = "Invalid Method: " <> header.method
        Response.header(socket, 400, message)
        Response.close(socket, message)
    end
  end
end
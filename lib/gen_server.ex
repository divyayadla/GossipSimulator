defmodule GenService do
  use GenServer 

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  # def push_sum_init(server, nodes) do
  #   GenServer.call(server, {:push_sum_init, nodes})
  # end

  def print_graph(server) do
    GenServer.call(server, {:print_pids, 1})
  end

  # @doc """
  # Ensures there is a bucket associated with the given `name` in `server`.
  # """
  # def create(server, name) do
  #   GenServer.cast(server, {:create, name})
  # end

  ## Server Callbacks

  def init(args) do
    # IO.inspect(self())
    construct_graph(args)
    # {:ok, %{}}
  end

  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
  end

  # def handle_call({:push_sum_init, nodes}, _from, bucket) do
  #   # IO.puts "inside hc psinit"
  #   {:reply, True, push_sum_helper(bucket, 1, nodes)}
  #       # {:reply, Map.fetch(names, name), names}
  # end

  # Todo to remove nodes from the variables
  def handle_call({:print_pids, nodes}, _from, bucket) do
    print_bucket(bucket)
    {:noreply, bucket}
  end

  def push_sum_helper(bucket, i, n) do
    # IO.puts "in pshelper"
    if (i <= n) do
      mug =
        bucket[i] 
          |> Map.put(:s, i) 
          |> Map.put(:w, 1)
      bucket 
        |> Map.put(i, mug) 
        |> push_sum_helper(i+1, n)
    else 
      bucket
    end
  end

  defp construct_graph(args) do
    # IO.puts("construct")
    [n | tail] = args
    [topology | tail] = tail
    [algorithm | tail] = tail
    [main_pid | tail] = tail
    bucket = Graph.create_nodes(n, algorithm, main_pid)
    # Enum.each bucket, fn {k, v} -> IO.puts inspect(k) <> " " <> inspect(v) end

    bucket = Graph.create_edges(topology, bucket, n)
    # print_bucket(bucket)
    # for {k, v} <- bucket do
    #   IO.puts "Node: " <> k <> inspect(v)
    # end
    {:ok, bucket}
  end

  def print_bucket(bucket) do
    Enum.each bucket, fn {k, v} -> IO.puts inspect(k) <> " " <> inspect(v) end
  end


  # def handle_cast({:create, name}, names) do
  #   if Map.has_key?(names, name) do
  #     {:noreply, names}
  #   else
  #     {:ok, bucket} = NodeService.create_actors(5)
  #     {:noreply, Map.put(names, name, bucket)}
  #   end
  # end
end
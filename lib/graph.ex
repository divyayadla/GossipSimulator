defmodule Graph do

  def create_nodes(n, algorithm, main_pid) do
    node_map = %{:total_nodes => n}
    create_nodes(1, n, node_map, algorithm, main_pid)
  end

  def create_nodes(k, n, node_map, algorithm, main_pid) do
    if k <= n do
      {:ok, pid} = 
        case algorithm do
          "push-sum" -> Task.start_link(PushSumService, :run, [k, self(), main_pid])
          _ -> Task.start_link(GossipService, :run, [k,self(),  main_pid])
        end
      node_map = Map.put(node_map, k, %{:node => pid})
      create_nodes(k+1, n, node_map, algorithm, main_pid)
    else
      node_map
    end
  end

  def create_edges(type, bucket, n) do
    case type do
      "full" -> create_full_network(bucket, n)
      "2D" -> create_2d_network(bucket, n)
      "line" -> create_line_network(bucket, n)
      _ -> create_imp2D_network(bucket, n)
    end
  end

  def create_full_network(bucket, n) do
    update_bucket_for_full_network(bucket, 1, n)
  end

  def update_bucket_for_full_network(bucket, i, n) do
    if i <= n do
      mug = 
        bucket[i]
          |> Map.put(:is_full, True)
          |> Map.put(:edges, n)
      bucket |> Map.put(i, mug) |> update_bucket_for_full_network(i+1, n)
    else
      bucket
    end
  end

  def create_2d_network(bucket, n) do
    bucket |> connect_nodes_in_grid(1, n, false)
  end

  def create_imp2D_network(bucket, n) do
    # IO.puts ("inside create_imp2D_network")
    bucket = bucket |> connect_nodes_in_grid(1, n)
    bucket
  end
  
  def connect_nodes_in_grid(bucket, i, n, include_random_node \\ true) do
    if i <= n do
      bucket 
        |> connect_adj_grid_nodes(i, n, include_random_node) 
        |> connect_nodes_in_grid(i+1, n, include_random_node)
    else 
      bucket
    end
  end
  
  def connect_adj_grid_nodes(bucket, i, nodes, include_random_node) do
    n = nodes
      |> :math.sqrt
      |> round
    pids = []
    adj_list = []
    # adj_list = [i]
    #backward
    {adj_list, pids} = 
      if i > n do
        { [i-n | adj_list], [bucket[i-n][:node] | pids]}
      else
        # { nodes-n+i, [bucket[nodes-n + i][:node] | pids]}
        {adj_list, pids}
      end
    # IO.puts("hello")

    #left connection
    {adj_list, pids} = 
      if rem(i,n) != 1 do
        {[i-1 | adj_list], [bucket[i-1][:node] | pids]}
      else
        # {i+n-1, [bucket[i+n-1][:node] | pids]}
        {adj_list, pids}
      end

    #right connection
    {adj_list, pids} = 
      if rem(i,n) != 0 do
        {[i+1 | adj_list],[bucket[i+1][:node] | pids]}
      else
        # {i-n+1, [bucket[i-n+1][:node] | pids]}
        {adj_list, pids}
      end
        # IO.puts("hello")

    #bottom 
    {adj_list, pids} = 
      if i <= nodes-n do
        {[i+n | adj_list], [bucket[i+n][:node] | pids]}
      else 
      #   n1 = rem(i,n)
      #   n1 =
      #     if n1 == 0 do
      #       n
      #     else
      #       n1
      #     end
      #   {n1, [bucket[n1][:node] | pids]}
      {adj_list, pids}
      end
          # IO.puts("hello")
    # {pids, edges} = 
    adj_list = 
      if include_random_node do
        random_pid = RandomUtil.get_random([i | adj_list], nodes)
        # IO.puts "here"
        [random_pid | adj_list]
      else
        adj_list
        # {pids, 4}
      end
          # IO.puts("hello")
    edges = Enum.count(adj_list)
    i_node_map = bucket[i]
    i_node_map = Map.put(i_node_map, :edges, edges)
    i_node_map = Map.put(i_node_map, :adj_nodes, adj_list)
    bucket = Map.put(bucket, i, i_node_map)
  end

  def create_line_network(bucket, n) do
    join_nodes_in_line(bucket, 1, n)
  end

  def join_nodes_in_line(bucket, i, n) do
    if i <= n do
      pids = []
      pids = 
        if i == 1 do
          # pids = [bucket[n][:node] | pids]
          pids
        else 
          # pids = [bucket[i-1][:node] | pids]
          [i-1 | pids]
        end
      pids = 
        if i == n do
          # pids = [bucket[1][:node] | pids]
          pids
        else
          # pids = [bucket[i+1][:node] | pids]
          [i+1 | pids]
        end
      # got the pids
      mug = 
        bucket[i] 
          |> Map.put(:edges, Enum.count(pids)) 
          |> Map.put(:adj_nodes, pids)
      bucket |> Map.put(i, mug) |> join_nodes_in_line(i+1, n)
    else
      bucket
    end
  end

  def run() do
    # unless Node.alive?() do
    #   {:ok, _} = Node.start(String.to_atom(name), :shortnames)
    # end
    # cookie = :gossip
    # Node.set_cookie(cookie)
    # IO.puts "Pid: " <> inspect(self()) <> ", Node: " <> inspect(Node.self)
  end

end 
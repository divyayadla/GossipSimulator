defmodule MN do

  def main(args) do
    # if length(args) == 3 do
      Process.flag(:trap_exit, true)
      {nodes, _} = Enum.at(args, 0) |> Integer.parse
      topology = Enum.at(args, 1)
      algorithm = Enum.at(args, 2)
      # IO.puts "main process id " <> inspect(self())
      :ets.new(:mem_cache, [:public, :named_table])
      # nodes = 100000
      # topology = "imp2D"
      # topology = "2D"
      # topology = "line"
      # topology = "full"
      # algorithm = "push-sum"
      # algorithm = "gossip"
      nodes = nodes |> :math.sqrt |> round
      nodes = nodes*nodes
      params = [self()]
      params = [algorithm | params]
      params = [topology | params]
      params = [nodes | params]
      # IO.inspect(params)
      IO.puts "build topology"
      # IO.puts "Processes before genserver " <> inspect(Process.list())
      # IO.puts "No.of processes before genserver " <> inspect(Enum.count(Process.list()))
      {:ok, pid} = GenService.start_link(params)
      # IO.puts "No.of processes after genserver " <> inspect(Enum.count(Process.list()))
      # :ets.insert(:mem_cache, {"gen_server_pid", pid})
      # IO.puts "genserver pid: " <> inspect(pid)
      :timer.sleep(500)
      # IO.puts "lookup:" <> inspect(GenService.lookup(pid, 10))
      start_time = :os.system_time(:millisecond)
      # IO.puts "start time: " <> inspect(start_time)
      :ets.insert(:mem_cache, {"start_time", start_time})
      case algorithm do
        "push-sum" -> PushSumService.get_average(pid, nodes)
        _ -> GossipService.start_gossip(pid, nodes)
      end

      # loop(3000)
      mail_box(nodes)
    # end
  end

  def mail_box(nodes) do
    receive do
      {:increment} -> 
        count = 
          if length(:ets.lookup(:mem_cache, :nodes_visited_count)) > 0 do
            elem(Enum.at(:ets.lookup(:mem_cache, :nodes_visited_count), 0),1)
          else
            1
          end
        # IO.puts "count:" <> to_string(count) 
        if count == nodes do
          start_time = elem(Enum.at(:ets.lookup(:mem_cache, "start_time"), 0),1)
          stop_time = :os.system_time(:millisecond)
          # IO.puts "stop time: " <> to_string(stop_time)
          IO.puts "time taken to converge => " <> to_string(stop_time-start_time)
          # System.halt(0)
        else 
          :ets.insert(:mem_cache, {:nodes_visited_count, count+1})
          nodes |> mail_box
        end 
      {:exit_push_sum, s, w, stop_time} ->
        # IO.puts "The End"
        start_time = elem(Enum.at(:ets.lookup(:mem_cache, "start_time"), 0),1)
        # IO.puts "stop time: " <> to_string(stop_time)
        # IO.puts "s:" <> to_string(s) <> ", w: " <> to_string(w) 
        IO.puts "avg: " <> to_string(s/w)
        IO.puts "time taken to converge => " <> to_string(stop_time-start_time)
        # System.halt(0)
    end
  end

  def loop (time) do
    if time > 0 do
      :timer.sleep(1000)
      loop(time-1)
    else
      System.halt(0)
    end
  end

end

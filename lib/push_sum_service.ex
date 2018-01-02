defmodule PushSumService do
  
  def get_average(gen_pid, n) do
    {:ok, adj_map} = gen_pid |> GenService.lookup(1)
    pid = adj_map[:node]
    IO.puts "Start push-sum protocol"
    send pid, {:start}
  end

  def run(i, gen_pid, main_pid) do
    start(%{:s => i, :w => 1, :num => i, :gen_pid => gen_pid, :diff_count => 0, :main_pid => main_pid})
  end

  def start(state) do
    receive do
      {:start} -> state 
                    |> start_helper 
                    |> start
      {:msg, s, w, sender_pid} -> 
                                  # IO.puts inspect(self()) 
                                  #   <> " received s: " <> to_string(s) 
                                  #   <> ", w: " <> to_string(w) <> " from " <> inspect(sender_pid)
                                  if state[:diff_count] > 3 do
                                    stop_time = :os.system_time(:millisecond)
                                    # :ets.insert(:mem_cache, {"st_time", stop_time})
                                    # IO.puts "s:" <> to_string(s) <> ", w:" <> to_string(w)
                                    # IO.puts "average is " <> to_string(s/w)
                                    # System.halt(0)
                                    # IO.inspect(stop_time)
                                    send state[:main_pid], {:exit_push_sum, s, w, stop_time}
                                  end
                                  state = diff(state, s/w, state[:s]/state[:w])
                                  state 
                                    |> Map.put(:s, s+state[:s]) 
                                    |> Map.put(:w, w+state[:w])  
                                    |> start_helper() 
                                    |> start
    end
  end

  def diff(state, v1, v2) do
    # IO.puts "new: " <> to_string(v1) <> ",prev: " <> to_string(v2)
    if abs(v1-v2) < 0.0000000001 do
      # IO.puts "updated for pid, " <> inspect(self())
      state |> Map.put(:diff_count, state[:diff_count]+1)
    else
      state |> Map.put(:diff_count, 0)
    end 
  end
  
  def start_helper(state) do
    gen_pid = state[:gen_pid]
    # IO.puts "gen_pid: " <> inspect(gen_pid)
    mug =   
      if !state[:adj] do
        i = state[:num]
        # IO.puts "i:" <> to_string(i)
        # {:ok, mug} = gen_pid |> GenService.lookup(i)
        {:ok, mug} = gen_pid |> GenService.lookup(i)
        state = state |> Map.put(:adj,mug)
        state[:adj]
      else 
        state[:adj]
      end
    # mug = state[:adj]
    # IO.puts "edges: " <> inspect(mug)
    rand = mug[:edges] |> RandomUtil.get_random
    # IO.puts to_string(rand)
    random_node_pid = 
      if mug[:is_full] do
        {:ok, rand_mug} = gen_pid |> GenService.lookup(rand)
        rand_mug[:node]
      else
        rand_val = mug[:adj_nodes] |> Enum.at(rand-1)
        {:ok, rand_mug} = gen_pid |> GenService.lookup(rand_val)
        rand_mug[:node]
      end
    s = state[:s]/2
    w = state[:w]/2
    send random_node_pid, {:msg, s, w, self()}
    state |> Map.put(:s, s) |> Map.put(:w, w)
  end

end
defmodule GossipService do
  
  def start_gossip(gen_pid, nodes) do
    {:ok, adj_map} = gen_pid |> GenService.lookup(1)
    pid = adj_map[:node]
    IO.puts "Start gossip protocol"
    send pid, {:start, "Hello world!"}
  end

  def run(i, gen_pid, main_pid) do
    start(%{:num => i, :gen_pid => gen_pid, :gossip_count => 3, :main_pid => main_pid}, %{:receive_count => %{}})
  end

  def update_fmap(fmap, key) do
    if !fmap[key] do
      {1, Map.put(fmap, key, 1)}
    else
      {fmap[key]+1, Map.put(fmap, key, fmap[key]+1)}
    end
  end

  def start(state, fmap) do
    receive do
      {:start, mesg} -> {frequency, fmap} = update_fmap(fmap, mesg)
                        # IO.inspect(state)
                          if frequency == 1 do
                            # IO.puts inspect(self()) <> "mpid: " <> inspect(state[:main_pid]) 
                            #        <> " received " <> mesg 
                            send state[:main_pid], {:increment}
                          end
                        state 
                          |> start_helper(mesg, state[:gossip_count])
                          |> start(fmap)
      {:gossip, mesg} -> 
                          # IO.puts inspect(self()) 
                          #          <> " received " <> mesg 
                          {frequency, fmap} = update_fmap(fmap, mesg)
                          if frequency == 1 do
                            # IO.puts inspect(self()) <> "mpid: " <> inspect(state[:main_pid]) 
                            #        <> " received " <> mesg 
                            send state[:main_pid], {:increment}
                          end
                          if frequency < 10 do
                            state 
                              |> start_helper(mesg, state[:gossip_count])
                              |> start(fmap)
                          end
                                  # if state[:diff_count] > 3 do
                                  #   IO.puts "s:" <> to_string(s) <> ", w:" <> to_string(w)
                                  #   System.halt(0)
                                  # end
    end
  end
  
  def start_helper(state, mesg, count) do
    if count > 0 do
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
      send random_node_pid, {:gossip, mesg}
      state |> start_helper(mesg, count-1)
    else 
      state
    end
  end

end
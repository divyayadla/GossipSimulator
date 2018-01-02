defmodule RandomUtil do
  
  def get_random(n) do
    :rand.uniform(n)
  end

  def get_other_random(n, p) do
    r = :random.uniform(n)
    if r == p do
      get_other_random(n, p)
    else
      r
    end
  end

  def get_random(adj_list, n) do
    r = :rand.uniform(n)
    r
    # IO.puts r
    # Todo to handle the adjcent and current node

    # if inside_list(adj_list, r) do
    #   IO.puts("fe1")
    #   get_random(adj_list, n)
    # else
    #   IO.puts("fe")
    #   r
    # end
  end

  def inside_list(adj_list, k) do
    [head | tail] = adj_list
    if head == k do
      True
    else
      inside_list(tail, k)
    end
  end
  def inside_list([], k) do 
    False 
  end
end
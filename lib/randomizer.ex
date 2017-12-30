defmodule Randomizer do
    @chars_list \
      Enum.map(?0..?z, &to_string [&1])
      |> Enum.filter(&Regex.match? ~r{\w}, &1)
  
    def string(_ \\ nil) do
      @chars_list
      |> Enum.shuffle
      |> Enum.take(:rand.uniform(10))
      |> Enum.join
    end
  
    def strings(count) do
      Enum.map 1..count, &Randomizer.string/1
    end
  end
  
  #IO.puts Randomizer.string
  #IO.inspect Randomizer.strings(3)
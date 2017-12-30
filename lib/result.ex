defmodule Final do
    use GenServer

    def init(args) do
        count = args
        {:ok, [count]}
    end


    def startResultServer do
        GenServer.start_link(__MODULE__,0,name: String.to_atom("result"))
    end

    def handle_cast({:add},state) do
        count = Enum.at(state,0) + 1
        state = List.replace_at(state,0,count)
        {:noreply,state}
    end

    def handle_call({:display},_from,state) do
        IO.puts Enum.at(state,0)
        {:reply,state,state}
    end
end
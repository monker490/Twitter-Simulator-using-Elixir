defmodule Tweeter do

    def main(args) do
        n = String.to_integer(Enum.at(args,0))
        Final.startResultServer
        Server.startLinkServer
        User.startLinkClient(n,[],0,n)
        IO.gets ""
    end
    
    # def main(args) do
    #     args |> parse_args
    # end

    # def parse_args([]) do
    #     IO.puts "Username not entered"
    # end

    # def parse_args(args) do
    #     {_,[userName,password],_} = OptionParser.parse(args)
    #     Server.Server.startLink
    #     Server.Server.checkUser(userName)
    #     # Server.Server.newUser(userName,password)
    # end
end
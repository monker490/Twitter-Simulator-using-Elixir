defmodule Server do
    use GenServer
    
    def init(args) do
      userinfo = %{}
      subsmap = %{}
      userconnection = %{}
      hashtags = %{}
      storedtweets = %{}
      storedretweets = %{}
      servercalls = 0
      {:ok,[userinfo,subsmap,userconnection,hashtags,storedtweets,storedretweets,servercalls]}
    end
    
    
    def startLinkServer do
        
      {:ok , servid} = GenServer.start_link(__MODULE__,%{},name: :server)
        
        #THIS BLOCK ONLY FOR TESTING

        # addUser("Arslan","password",1)
        # addUser("Jamshed","popli",1)
        # addUser("Arslan","pass",1)
        
        # Enum.each(1..10, fn(z)->
        #   addFollower("Arslan",z)
        # end)
        # Enum.each(1..10, fn(z)->
        #   addFollower("Jamshed",z)
        # end)
    
        # addFollower("Sachdev",1)
        
        # IO.gets("")
    end
    
    def addUser(username, password,status) do
      list = [username, password, status]  
      GenServer.cast(:server,{:registerNewUser,list})
    end
    
    def addFollower(user,follower) do 
      list = [user,follower]
      GenServer.cast(:server,{:follow,list})
      # IO.puts "w"
    end
  
    def handle_cast({:registerNewUser,list},state) do #list has the form [username,password,connection status]
      # count = Enum.at(state,6) + 1
      # state = List.replace_at(state,6,count)
      temp = Enum.at(state,0)
      temp2 = Enum.at(state,1)
      temp3 = Enum.at(state,2)
      if (Map.has_key?(temp,Enum.at(list,0))) do
        IO.puts "user already exists"
        {:noreply,state}
      else
        # IO.puts "user added"
        # IO.puts Enum.at(list,0)
        # IO.puts Enum.at(list,1)
        temp = Map.put(temp,Enum.at(list,0),Enum.at(list,1)) #user added to database with password
        temp2 = Map.put(temp2,Enum.at(list,0),[]) #empty follower list created
        temp3 = Map.put(temp3,Enum.at(list,0),Enum.at(list,2)) #Connection status
        state = List.replace_at(state,0,temp)
        state = List.replace_at(state,1,temp2)
        state = List.replace_at(state,2,temp3)
        {:noreply,state}
      end
    end
    

    def handle_cast({:follow,list},state) do #list has the form [user,follower]
      # count = Enum.at(state,6) + 1
      # state = List.replace_at(state,6,count)
      temp = Enum.at(state,1)
      if (Map.has_key?(temp,Enum.at(list,0))) do
        followlist = Map.get(temp,Enum.at(list,0))
        followlist = followlist ++ [Enum.at(list,1)]
        temp = Map.put(temp,Enum.at(list,0),followlist)
        state = List.replace_at(state,1,temp)
        #IO.inspect Enum.at(state,1)
        {:noreply,state}  
      else
        IO.puts "no such user"
        {:noreply,state}
      end
    end
  
    def handle_cast({:distribute,tweet},state) do #tweet has the form [user,tweet] || [user,tweet,Originalcreator]
      # count = Enum.at(state,6) + 1
      # state = List.replace_at(state,6,count)
      # IO.inspect tweet
      temp = Enum.at(state,1)
      connstatus = Enum.at(state,2)
      # IO.inspect connstatus
      if (Map.get(connstatus,Enum.at(tweet,0))==1) do
        followlist = Map.get(temp,Enum.at(tweet,0)) #finds all followers of the tweeter
        # IO.inspect followlist
        if (Enum.count(tweet) == 2) do #this is the case of tweets
          Enum.each(followlist, fn(z)->
            if (Map.get(connstatus,z) == 1) do
              GenServer.cast(String.to_atom(z),{:receive,tweet}) ##cast to the user who will receive the tweet
            else
              # IO.puts z
              list = tweet ++ [z]
              GenServer.cast(:server,{:storeTweet,list})
              # IO.puts "store hua?"
            end
          end)
        end
        if (Enum.count(tweet) == 3) do#this is the case of retweets
          Enum.each(followlist, fn(z)->
            # IO.puts z
            # IO.puts Enum.at(tweet,0)
            # IO.puts Enum.at(tweet,1)
            # IO.puts Enum.at(tweet,2)
            # if (Map.get(connstatus,z) == 1) do
              GenServer.cast(String.to_atom(z),{:receiveRetweet,tweet})
              # IO.puts "cast hua?"
            # else
            #   IO.puts z
            #   list = tweet ++ [z]
            #   GenServer.cast(:server,{:storereTweet,list})
            #   IO.puts "store hua?"
            # end
            
          end)
        end
      else
        # IO.puts Enum.at(tweet,0)
      
      end
      
      {:noreply, state}
    end
    
    def handle_cast({:flush},state) do
      # count = Enum.at(state,6) + 1
      # state = List.replace_at(state,6,count)
      connstatus = Enum.at(state,2)
      keylist = Map.keys(connstatus)
      storedtweets = Enum.at(state,4)
      Enum.each(keylist, fn(z)->
        if(Map.get(connstatus,z)==1 && Map.get(storedtweets,z)) do
          list=Map.get(storedtweets,z)
          sendthem(list,z)
          # Enum.each(list, fn(x) ->
          #   {a,b}=x
          #   tweet=[a,b]
          #   # IO.inspect tweet
          #   # IO.inspect z
          #   GenServer.cast(String.to_atom(z),{:receive,tweet})
          # end)
          GenServer.cast(:server,{:deletestore,z})
        end
      end)
      {:noreply,state}
    end

    def sendthem(list,z) do
      Enum.each(list, fn(x) ->
        {a,b}=x
        tweet = [a,b]
        GenServer.cast(String.to_atom(z),{:receive,tweet})
      end)
      
    end

    def handle_cast({:deletestore,z},state) do
      # count = Enum.at(state,6) + 1
      # state = List.replace_at(state,6,count)
      storedtweets = Enum.at(state,4)
      storedtweets = Map.delete(storedtweets,z)
      # IO.puts "hello"
      # IO.inspect storedtweets
      state = List.replace_at(state,4,storedtweets)
      {:noreply,state}
    end

    def handle_cast({:changestatus,user},state) do
      # count = Enum.at(state,6) + 1
      # state = List.replace_at(state,6,count)
      statusmap = Enum.at(state,2)
      # Enum.each(user, fn(x)->
        if (Map.get(statusmap,user) == 1) do
          statusmap = Map.put(statusmap,user,0)
        else
          statusmap = Map.put(statusmap,user,1)
        end
      # end)
      state = List.replace_at(state,2,statusmap)
      {:noreply,state}
    end

    def handle_cast({:searchtags},state) do
      # count = Enum.at(state,6) + 1
      # state = List.replace_at(state,6,count)
      tags = Enum.at(state,3)
      if(Enum.count(tags)>0) do
        keys = Map.keys(tags)
        list = Map.get(tags,Enum.random(keys))
        # IO.inspect Enum.random(list)
      end
      {:noreply,state}
      
    end


    def handle_cast({:storeTweet,list},state) do #list has the form [user,tweet,receiver]
      # IO.puts "idhar aa jaa raani"
      # count = Enum.at(state,6) + 1
      # state = List.replace_at(state,6,count)
      storage = Enum.at(state,4)
      if(Map.has_key?(storage,Enum.at(list,2))) do 
        alreadystored = Map.get(storage,Enum.at(list,2)) #get tweets that need to be deliverd to user
        alreadystored = alreadystored ++ [{Enum.at(list,0),Enum.at(list,1)}]
      else
        # IO.puts "storing"
        alreadystored = [{Enum.at(list,0),Enum.at(list,1)}]
      end
      storage = Map.put(storage,Enum.at(list,2),alreadystored)
      #IO.inspect storage
      state = List.replace_at(state,4,storage)
      {:noreply,state}

    end


    # def handle_call({:parseText,list},state) do #list is of the form [user,tweet]
    #   text = Enum.at(list,1)
    #   text = String.split(text," ")
    #   Enum.each(text, fn(word) -> 
    #     if (String.first(word) == "#" && String.length(word) > 1) do ##NEED TO DO THE MAGIC HERE
    #       # IO.inspect word
    #       hashTweet = list ++ [word]
    #       # IO.inspect hashTweet
    #       GenServer.cast(:server,{:addHashtag,hashTweet})
    #     end
    #     if (String.first(word) == "@" && String.length(word) > 1) do
    #       word = String.slice(word,1..String.length(word)-1)
    #       #IO.inspect word
    #       GenServer.cast(String.to_atom(word),{:receive,list})
    #     end
    #   end)
    #   {:noreply,state}
    # end

  def parseText(tweet) do #tweet has the form [user,tweet]
    text = Enum.at(tweet,1)
    text = String.split(text," ")
    Enum.each(text, fn(word) -> 
      if (String.first(word) == "#" && String.length(word) > 1) do ##NEED TO DO THE MAGIC HERE
        # IO.inspect word
        hashTweet = tweet ++ [word]
        # IO.inspect hashTweet
        GenServer.cast(:server,{:addHashtag,hashTweet})
      end
      if (String.first(word) == "@" && String.length(word) > 1) do
        word = String.slice(word,1..String.length(word)-1)
        #IO.inspect word
        GenServer.cast(String.to_atom(word),{:receive,tweet})
      end
    end)
  end

  
    def handle_cast({:addHashtag,hashTweet},state) do #hashTweet has the form [user,tweet,hashtag]
    # count = Enum.at(state,6) + 1
    # state = List.replace_at(state,6,count)  
    hashTags = Enum.at(state,3)
      if (Map.has_key?(hashTags,Enum.at(hashTweet,2))) do
        hashlist = Map.get(hashTags,Enum.at(hashTweet,2))
        hashlist = hashlist ++ [{Enum.at(hashTweet,0),Enum.at(hashTweet,1)}] ##make a tuple {username,tweet} and it to the corresponding haslist
      else
        hashlist = [{Enum.at(hashTweet,0),Enum.at(hashTweet,1)}]
      end
        hashTags = Map.put(hashTags,Enum.at(hashTweet,2),hashlist)
        state = List.replace_at(state,3,hashTags)
        {:noreply,state}
    end

    def handle_call({:info}, _from ,state) do
      # IO.puts "AAJ HUM PRINT KARENGE"
      # IO.inspect Enum.at(state,0) ##Userinfo
      # IO.inspect Enum.at(state,1) ##Subscribersmap
      # IO.inspect Enum.at(state,2) ##connectioninfo
      # IO.inspect Enum.at(state,3) ##hashtags
      # IO.inspect Enum.at(state,4) ##tweetstorage
      # IO.inspect Enum.at(state,5) ##following
      # IO.inspect Enum.at(state,6)
      {:reply,state,state}
    end

    def hello do
      :world
    end
  end
  
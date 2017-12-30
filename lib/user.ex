defmodule User do
    use GenServer

    def init(x) do
        userName = x
        password = x <> "password"
        myTweets = []
        myFeed = %{}
        myFollowers = []
        myFollowing = []
        reTweets = %{}
        requests = 0
        {:ok, [userName, password, myTweets, myFeed, myFollowers, myFollowing,reTweets,requests]}
    end

    def startLinkClient(n,userRank,zipfC,totalUsers) do
        if (n>=1) do
            s = 3 #VALUE OF S IN ZIPF DISTRIBUTION
            zipfC = zipfC + (1/(:math.pow(n,s)))
            x = "User" <> Integer.to_string(n)
            #userRank = Map.put(userRank,x,0)
            userRank = userRank ++ [x]
            processID = GenServer.start_link(__MODULE__,x, name: String.to_atom(x))
            GenServer.cast(String.to_atom(x), :registerNewUser)
            # GenServer.cast(String.to_atom(x), :toggleStatus)
            startLinkClient(n-1,userRank,zipfC,totalUsers)
        else
            userRank = Enum.shuffle userRank
            # IO.inspect Enum.at(userRank,0)
            zipfC = 1/zipfC
            # IO.inspect zipfC
            followerPopulate(userRank,zipfC,totalUsers,0)
            
            # Enum.each(userRank, fn(z)->
            #     # IO.puts rank
            #     zipfMaker(z, userRank, zipfC, totalUsers,1) 
            # end)
            IO.puts "Subscribers ho gaye :)" 
            

            # toggleStatus("User6")
            # toggleStatus("User7")

            # :timer.sleep(1000)

            # maketweet(Enum.at(userRank,0),"SAMPLE TWEET HAI YE BC")
            #
            # maketweet(Enum.at(userRank,0), "YE SECOND TWEET HAI BROSSSSSSSSSS")
            # maketweet(Enum.at(userRank,0),"this is a #hashtag tweet")
            # maketweet(Enum.at(userRank,9),"this is a @User2 mention tweet")
            # reTweet("User1")

            maxThreshold = 10000
            
            
            startsimulation(userRank,0,totalUsers,maxThreshold)      
                
                # rn=:rand.uniform
            #     # toggler(userRank,rn)
            #     Enum.each(1..round(maxThreshold/t), fn(y)->
            #         # spawn ( __MODULE__, parameters , [])
            #         spawn(__MODULE__,:maketweet,[Enum.at(userRank,t-1),wordGenerator(:rand.uniform(10),:rand.uniform(4),userRank)])
            #         # maketweet(Enum.at(userRank,t-1),wordGenerator(:rand.uniform(10),:rand.uniform(4),userRank))
            #         # random_number = :rand.uniform(100)
            #         # if (random_number<6) do
            #         #     retweet(Enum.at(userRank,t-1))
            #         # end
            #         # if (random_number<11) do
            #         #     search()
            #         # end
            #     end)
                
            # end)   
            
            # toggleStatus(["User6"])
            # toggleStatus(["User7"])
            
            
            
            # flushtweets();
            # :timer.sleep(1000)
            # GenServer.cast(:server,{:addHashtag,["User1","Hello #polis","#polis"]})
            # GenServer.cast(:server,{:addHashtag,["User2","Hello #polis","#polis"]})

            # search()

            # GenServer.call(:server,{:info})

            #THIS IS FOR PRINTING
            
            # result(0,totalUsers,0,userRank)

            # Enum.each(userRank,fn(z) -> 
            #     GenServer.call(String.to_atom(z),{:print})
            # end)

            GenServer.call(:result,{:display})
        
        # IO.inspect processID
        
        # set time out for the below mentioned casts
        
        
        #TWEETING
        # list = ["username","tweet"]
        #GenServer.cast(String.to_atom("server"),{:distribute,list})
        IO.gets ""
        end
    end

    # def result(iterator,totalUsers,0,userRank) do
        
    # end

    def toggler(userRank,counter,n) do
        if (counter<n) do
            toggleStatus(Enum.random(userRank))
        end
        flushtweets()
    end

    def startsimulation(userRank,recursioncounter,totalUsers,maxThreshold) do
        if (recursioncounter<totalUsers) do
            spawn(User, :maketweet,[Enum.at(userRank,recursioncounter),wordGenerator(:rand.uniform(10),:rand.uniform(4),userRank),round(maxThreshold/(recursioncounter+1)),0])
            # currnode=Enum.at(userRank,recursioncounter+1,totalUsers)
            toggler(userRank,1,totalUsers/10)
            startsimulation(userRank,recursioncounter+1,totalUsers,maxThreshold)
        end
    end

    def wordGenerator(maxWordsLength,typeOfTweet,userRank) do
        word_list = Randomizer.strings(maxWordsLength);
        #IO.inspect word_list
        solo_word = Randomizer.string
        # IO.inspect solo
        hashtag = Enum.join(["#",solo_word])
        mention = Enum.join(["@",String.to_atom(Enum.random(userRank))])
        hashtag_list = word_list ++ [hashtag]
        mention_list = word_list ++ [mention]
        bothlist = word_list ++ [mention] ++ [hashtag]
    
        cond do
            typeOfTweet == 1 -> string_list = Enum.join(word_list, " ") #just text
            typeOfTweet == 2 -> string_list = Enum.join(hashtag_list, " ") #hashtag
            typeOfTweet == 3 -> string_list = Enum.join(mention_list, " ") #mention user
            typeOfTweet == 4 -> string_list = Enum.join(bothlist, " ") #both
        end

        string_list
    end

    def followerPopulate(userRank,zipfC,totalUsers,n) do
        if (n<totalUsers) do
            zipfMaker(Enum.at(userRank,n),userRank,zipfC,totalUsers,n+1)
            followerPopulate(userRank,zipfC,totalUsers,n+1)
        end
    end

    def flushtweets do
        GenServer.cast(:server,{:flush})
    end

    def zipfMaker(user,userRank,zipfC,totalUsers,rank) do
        # rank = Enum.find_index(userRank, fn(p)-> p==user end) + 1
        numFollowers = round(Float.ceil((totalUsers*zipfC)/rank))
        #IO.puts numFollowers
        #IO.puts node
        for n <- 1..numFollowers, do:
        followerCreator(user,userRank)

    end

    def followerCreator(user,userRank) do
        follower = Enum.random(userRank)
        list = [user,userRank,follower]
        GenServer.cast(String.to_atom(user),{:followerAdd,list})
    end

    def handle_cast({:followerAdd,list},state) do #list is of the form username,list of all users,follower
        followers = Enum.at(state,4)
        userRank = Enum.at(list,1)
        follower = Enum.at(list,2)
        user = Enum.at(list,0)
        if (Enum.member?(followers,follower) || follower==user) do
            followerCreator(user,userRank)
            
        else
            followers = followers ++ [follower]
            details = [user,follower]
            state = List.replace_at(state,4,followers)
            GenServer.cast(String.to_atom("server"),{:follow,details})
            GenServer.cast(String.to_atom(follower),{:followingAdd,user})
            
        end
        {:noreply,state}
    end

    def handle_cast({:followingAdd,user},state) do
        following = Enum.at(state,5)
        following = following ++ [user]
        state = List.replace_at(state,5,following)
        {:noreply,state}
    end
    
    def toggleStatus(user) do
        
        GenServer.cast(:server,{:changestatus,user})
    end

    def search() do
        GenServer.cast(:server,{:searchtags})
    end


    def handle_cast(:registerNewUser,state) do
        #RANDOMISE CONNECTION STATUS
        connectionStatus = 1 #1 is for online 0 for offline
        userCredentials = [Enum.at(state,0), Enum.at(state,1),connectionStatus]
        GenServer.cast(String.to_atom("server"), {:registerNewUser,userCredentials})
        
        {:noreply,state}
    end

    def handle_cast({:receive,tweet},state) do #tweet has tha form [username,tweet]
        ##ONLY IF THE CONNECTION STATUS IS LIVE
        ##HAVE TO FIGURE OUT WHAT TO DO FOR WHEN USER IS OFFLINE
        feed = Enum.at(state,3)
        if(Map.has_key?(feed,Enum.at(tweet,0))) do 
            tweetlist = Map.get(feed,Enum.at(tweet,0)) #get all tweets from user
            tweetlist = tweetlist ++ [Enum.at(tweet,1)]
        else
            tweetlist = [Enum.at(tweet,1)]
        end
        feed = Map.put(feed,Enum.at(tweet,0),tweetlist)
        state = List.replace_at(state,3,feed)
        {:noreply,state}
    end

    def handle_cast({:myTweet,tweet},state) do
        tweetList = Enum.at(state,2)
        tweetList = tweetList ++ [tweet]
        state = List.replace_at(state,2,tweetList)
        {:noreply,state}
    end
    #function for tweeting
    def maketweet(user,tweet,numtweets,counter) do
        if (counter<numtweets) do    
            list = [user,tweet]
            GenServer.cast(:server,{:distribute,list})
            GenServer.cast(String.to_atom(user),{:myTweet,tweet})
            Server.parseText(list)
            maketweet(user,tweet,numtweets,counter+1)
            random_number=:rand.uniform(100)
            if (random_number<5) do
                reTweet(user)
            end
            if (random_number<9) do
                search()
            end
        end
        GenServer.cast(:result,{:add})
    end
    
    def handle_cast({:add},state) do
        count = Enum.at(state,7)+1
        state = List.replace_at(state,7,count)
        {:noreply,state}
    end
    def reTweet(user) do
        
        GenServer.cast(String.to_atom(user),{:reTweeter})
    end

    def handle_cast({:reTweeter},state) do
        # IO.puts "retweeting"
        tweetlist = Enum.at(state,3) #Get all tweets received
        if (Enum.count(tweetlist)>0) do
            retweetHim = Enum.random(Map.keys(tweetlist))
            tweet = Enum.random(Map.get(tweetlist,retweetHim))
            # IO.puts tweet
            # IO.puts retweetHim
            GenServer.cast(:server,{:distribute,[Enum.at(state,0),tweet,retweetHim]})
        end
        {:noreply,state}
    end

    

    def handle_cast({:receiveRetweet,tweet},state) do #tweet is of the form [retweeter,tweet,original creator]
        retweets = Enum.at(state,6)
        # IO.inspect Enum.at(tweet,0)
        # IO.inspect Enum.at(tweet,1)
        # IO.inspect Enum.at(tweet,2)

        if(Map.has_key?(retweets,Enum.at(tweet,2))) do 
            retweetlist = Map.get(retweets,Enum.at(tweet,2)) #get all tweets from user
            retweetlist = retweetlist ++ [{Enum.at(tweet,0),Enum.at(tweet,1)}]
        else
            # IO.puts "Idhar"
            retweetlist = [{Enum.at(tweet,0),Enum.at(tweet,1)}]
        end
        retweets = Map.put(retweets,Enum.at(tweet,2),retweetlist)
        state = List.replace_at(state,6,retweets)
        {:noreply,state}

    end

    def handle_call({:print}, _from ,state) do
        #IO.puts "AAJ HUM PRINT KARENGE"
        # IO.inspect Enum.at(state,0) ##Username
        # IO.inspect Enum.at(state,2) ##myTweets
        # IO.inspect Enum.at(state,3) ##feed
        # IO.inspect Enum.at(state,4) ##followers
        # IO.inspect Enum.at(state,5) ##following
        # IO.inspect Enum.at(state,7) ##retweets
        {:reply,state,state}
    end
    
end

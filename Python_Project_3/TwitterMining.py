##This program will ask for a "#something" such as #womensrights
##or #stockmarket. 
##It will then ask for the number of tweets you want to get
##It will OUTPUT a file called:
##"file_"+nohashname+".txt"
##For example, if you input #womensrights, it will 
##create a file called file_womensrights.txt where the tweets will be placed. 
##From here you can call the next program called TweepyJSONReader.py
#------------------------------------------------------------------------------
#-------------------------------Loading Libraries------------------------------
#------------------------------------------------------------------------------
import tweepy
import json
import sys
#------------------------------------------------------------------------------
#---------------------Authorising script to access Twitter---------------------
#------------------------------------------------------------------------------
##Go to https://developer.twitter.com/ and create a developer account
##Create all the keys and secrets needed to use twitter api
consumer_key ='Add your consumer key'
consumer_secret = 'add your consumer secret'
access_token = 'add your access token'
access_secret = 'add your access secret'

##access token and secret gives tweepy complete access to twitters api
auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_secret)
#------------------------------------------------------------------------------
#------------------------Expanding on the StreamListener-----------------------
#------------------------------------------------------------------------------
##create class with tweepy.StreamListener
##This uses the Streaming API
#We need to extend the StreamListener() to customise the way we process the incoming data
class Listener(tweepy.StreamListener):
    print("In Listener Class...") 
    tweet_number=0
    
    def __init__(self, max_tweets, hfilename, rawfile):
        ##creating a max_tweets attribute
        self.max_tweets=max_tweets
        print('Max number of tweets to collect: ', self.max_tweets)     
    
    ##on_data() method of a StreamListener instance receives all Respones 
    ##and writes the data to the designated files 
    def on_data(self, data):
        self.tweet_number+=1 
        print("In on_data method", self.tweet_number)
        try:
            print("In on_data in try")
            with open(hfilename, 'a') as f:
                with open(rawfile, 'a') as g:
                    ##tweet variable is a dict that contains all data 
                    tweet=json.loads(data)
                    ##dict indexing using the text key to get only the text data
                    tweet_text=tweet["text"]
                    print(tweet_text,"\n")
                    #write the text of the tweet to hfilename
                    f.write(tweet_text)
                    #write the raw tweet
                    json.dump(tweet, g)
        except BaseException:
            print("NOPE")
            pass
        if self.tweet_number>=self.max_tweets:
            sys.exit('Limit of '+str(self.max_tweets)+' tweets reached.')
            
    #error codes are passed to on_error() method by StreamListener
    def on_error(self, status):
        print("ERROR")
        ##the rate limit is the limit that the twitter api sets
        ##its the max number of tweeps we can gather in a certain amount of time
        if status==420:
            print("Error ", status, "rate limit reached")
            ##return False in on_error() disconnects the stream
            return False
#------------------------------------------------------------------------------
#------------------------Loading Data into Python------------------------------
#------------------------------------------------------------------------------
hashname=input("Enter the hash name, such as #womensrights: ") 
numtweets=eval(input("How many tweets do you want to get?: "))
##removing the #
if hashname[0]=="#" :
    #remove the hash
    nohashname=hashname[1:]
else:
    nohashname=hashname
    hashname="#"+hashname
#Create a file for any arbitrary hash mine    
hfilename="file_"+nohashname+".txt"
rawfile="file_rawtweets_"+nohashname+".txt"


##creating stream object
##tweepy.Stream establishes a continuous streaming session and routes Responses to Listener instance
##which is a class that inherits StreamListener class
twitter_stream = tweepy.Stream(auth, Listener(numtweets, hfilename, rawfile))

##starting stream object
##we use filter() method to filter out the data and send the data that matches our specified hashtag
##to the Listener instance, which then goes to the on_data() method
twitter_stream.filter(track=[hashname])





##This program will read a .txt file
##that was created by TwitterMining.py
##Set the filename correctly
##This program will create two files:
##"TwitterResultsRaw.txt" which is all the words
##"TwitterWordFrq.txt" which is each word and its frequency
#------------------------------------------------------------------------------
#------------------------Loading Data into Python------------------------------
#------------------------------------------------------------------------------

from nltk.tokenize import TweetTokenizer
import re  

linecount=0
hashcount=0
wordcount=0
BagOfWords=[]
BagOfHashes=[]
BagOfLinks=[]

##set the file name that contains the tweet text to be parsed
##file is created from TwitterMining.py
tweetsfile="file_investing.txt"
#------------------------------------------------------------------------------
#-------------------Opening file, and sorting through each word----------------
#------------------------------------------------------------------------------
with open(tweetsfile, 'r') as file:
    for line in file:
          
        tweetSplitter = TweetTokenizer(strip_handles=True, reduce_len=True)
        WordList=tweetSplitter.tokenize(line)
        
        ##creating the pattern that we want to match the Wordlist too
        ##matches for hashtag's
        regex1=re.compile('#')  
        ##matches any word characters followed by no digits
        regex2=re.compile('[^\W\d]')

        ##matches for links/urls
        regex3=re.compile('http*')
        regex4=re.compile('.+\..+')
        
        for item in WordList:
            ##ignore strings less than 2 letters 
            if(len(item)>2):
                ##matches for hashtags in each token
                if((re.match(regex1,item))):
                    #removes #
                    newitem=item[1:]
                    BagOfHashes.append(newitem)
                    hashcount=hashcount+1
                elif(re.match(regex2,item)):
                    if(re.match(regex3,item) or re.match(regex4,item)):
                        BagOfLinks.append(item)
                    else:
                        BagOfWords.append(item)
                        wordcount=wordcount+1
                        
#------------------------------------------------------------------------------
#------------------------2nd round of Word Filtering ------------------------------
#------------------------------------------------------------------------------         
##In this section, we're filtering words into the seenit list and the WordDict dictionary
##There is a list of words in the IgnoreThese list that we will ignore 
##Words that are not in IgnoreThese list are written in Rawfilename
##Words and their respective frequency are written in Freqfilename


BigBag=BagOfWords+BagOfHashes


#list of words seen
seenit=[]
#dict of seen word with frequency 
WordDict={}


Rawfilename="TwitterResultsRaw.txt"
Freqfilename="TwitterWordFrq.txt"


R_FILE=open(Rawfilename,"w")
F_FILE=open(Freqfilename, "w")

IgnoreThese=["and", "And", "AND","THIS", "This", "this", "for", "FOR", "For", 
             "THE", "The", "the", "is", "IS", "Is", "or", "OR", "Or", "will", 
             "Will", "WILL", "God", "god", "GOD", "Bible", "bible", "BIBLE",
             "CanChew", "Download", "free", "FREE", "Free", "will", "WILL", 
             "Will", "hits", "hit", "within", "steam", "Via", "via", "know", "Study",
             "study", "unit", "Unit", "always", "take", "Take", "left", "Left",
             "lot","robot", "Robot", "Lot", "last", "Last", "Wonder", "still", "Still",
             "ferocious", "Need", "need", "food", "Food", "Flint", "MachineCredit",
             "Webchat", "luxury", "full", "fifdh17", "New", "new", "Caroline",
             "Tirana", "Shuayb", "repro", "attempted", "key", "Harrient", 
             "Chavez", "Women", "women", "Mumsnet", "Ali", "Tubman", "girl","Girl",
             "CSW61", "IWD2017", "Harriet", "Great", "great", "single", "Single", 
             "tailoring", "ask", "Ask","can","Can",'news','Check','your']

##add words into Rawfilename if they are not in the IgnoreThese list 
##Also keep track of word count
##loop over the words to determine the frequency of each word
for word in BigBag:
    if word not in IgnoreThese:
        rawWord=word+" "
        R_FILE.write(rawWord)
        if word in seenit:
            #increment the times word is seen
            WordDict[word]=WordDict[word]+1 
        else:
            ##add word to dict and seenit
            seenit.append(word)
            WordDict[word]=1
    
    
##writing the words into Freqfilename from WordDict
for key in WordDict:
    ##will not include words with frequency of 1
    if WordDict[key]>1:
        Key_Value=key + "," + str(WordDict[key]) + "\n"
        F_FILE.write(Key_Value)


R_FILE.close()
F_FILE.close()
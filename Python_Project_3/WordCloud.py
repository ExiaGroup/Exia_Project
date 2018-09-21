##WordCloud.py
##This program parses the file called TwitterResultsRaw.txt from
##TweepyJSONReader.py


import matplotlib.pyplot as plt
import wordcloud

##make sure TwitterResultsRaw.txt is placed in the current working directory
Rawfilename="TwitterResultsRaw.txt"


text = open(Rawfilename).read()
wordcloud = wordcloud.WordCloud().generate(text)
#plt.imshow() display an image that is array-like or a PIL image
plt.imshow(wordcloud)
plt.axis("off")



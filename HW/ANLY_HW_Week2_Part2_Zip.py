import requests
import pandas as pd

def main():
      ziplist = getZip();
      GetAirNowData(ziplist)

##function retrieves zip codes from input.txt file
##strip() method is used to strip \n for every x in zipList
def getZip():
      filePointer = open("input.txt","r")
      zipList = filePointer.readlines()
      zipList = [x.strip() for x in zipList]
      return zipList

##this function GETS the data from the server through the API endpoint.
##function iterates through each zip code and query the server for air data corresponding with every
      ##zip code.
##air data is indexed using labels variable to get desired information, and then written in a csv file.
def GetAirNowData(ziplist):
      labels = ['AQI','ParameterName','DateIssue','ReportingArea','StateCode','Category']
      for zipCode in ziplist:
            baseURL="http://www.airnowapi.org/aq/forecast/zipCode/current/?"
            zipURL=({'format': "application/json",
                     'zipCode':zipCode,
                     'distance':'5',
                     'API_KEY':'7214E5AC-EF63-407D-9C88-4F434E31C9B5'
                     })
            response=requests.get(baseURL,zipURL)
            jsondata = response.json()
            requested_df = pd.DataFrame.from_dict(jsondata)
            requested_df = requested_df[labels]
            requested_df.to_csv("AQI_output.csv",mode = 'a', sep = ',',header = True)
            print(requested_df)


main()






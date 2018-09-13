import requests
import pandas as pd
import csv


def main():
      latLongList = getLatLong();
      GetAirNowData(latLongList)

##returning a csv object that houses the latitude and longitude that allows us to 
##iterate over the object like a dict-like to retrieve the data
def getLatLong():
      filePointer = open("inputLatLong.txt","r")
      latLongList = csv.reader(filePointer)
      return latLongList

##this function GETS the data from the server through the API endpoint.
##function iterates through each zip code and query the server for air data corresponding with every
      ##zip code.
##air data is indexed using labels variable to get desired information, and then written in a csv file.
def GetAirNowData(latLongList):
      labels = ['AQI','ParameterName','DateIssue','ReportingArea','StateCode','Category']
      for lat,long in latLongList:
            baseURL="http://www.airnowapi.org/aq/forecast/latLong/current/?"
            zipURL=({'format': "application/json",
                     'latitude':lat,
                     'longitude':long,
                     'distance':'25',
                     'API_KEY':'7214E5AC-EF63-407D-9C88-4F434E31C9B5'
                     })
            response=requests.get(baseURL,zipURL)
            jsondata = response.json()
            requested_df = pd.DataFrame.from_dict(jsondata)
            requested_df = requested_df[labels]
            requested_df.to_csv("AQI_output_lat_long.csv",mode = 'a', sep = ',',header = True)
            print(requested_df)

main()






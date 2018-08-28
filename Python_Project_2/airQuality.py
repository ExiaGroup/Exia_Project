##Uses the AirNow API to gather data on today's air quality for a given zipcode
import requests
import datetime 
import pandas as pd

##creating text file to contain air quality data
FileName="OUTFILE.txt"
File=open(FileName, "w")
File.close()

max_n = 4
n = 0

def main():
    ziplist = input("Please enter a zip code for today's air quality: ")
    ##gets today's date
    date = datetime.datetime.today().strftime('%Y-%m-%d')
    AirNowInfo = GetAirNowData(FileName, ziplist, date)
    print(AirNowInfo)


def GetAirNowData(FileName, ziplist,date):
    baseURL="http://www.airnowapi.org/aq/forecast/zipCode/?"
    ##Go to https://docs.airnowapi.org/login to get your personal API_Key
    zipURL=({'format': "application/json",
             'zipCode':ziplist,
             'date':date,
             'distance':'5',
             'API_KEY':'Need API key'
             })
    response=requests.get(baseURL,zipURL)
    jsondata = response.json()
    requested_df = pd.DataFrame.from_dict(jsondata)
    labels = ['AQI','ParameterName','DateIssue','ReportingArea','StateCode']
    requested_df = requested_df[labels]
    ##creating a ZipCode column that incides the zipcode of the corresponding area
    requested_df.insert(4,'ZipCode',ziplist)
    requested_df.to_csv("OUTFILE.txt",mode = 'a', sep = ',',index = False)
    return requested_df


while n<4:
    main()
    if n < 3:
        continue_ = input('Do you want to continue?(y/n) ')
    if continue_ == 'n':
        break
    n = n+1






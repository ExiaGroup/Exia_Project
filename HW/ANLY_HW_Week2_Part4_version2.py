import requests
import json

open('outputWeather.txt','w')

##global Vars
cnt = '3'
lat = '55.5'
lon = '37.5'


def main():
      jsonData = getWeatherData(lat, lon)
      ##cityData is a list of dicts
      ##indexing for the list that contains city information
      cityData = jsonData['list']
      
      ##creating new variables to house info for each city
      cityOne = cityData.pop()
      cityTwo = cityData.pop()
      cityThree = cityData.pop()
      
      cityOne = nestedDictIter(cityOne)
      cityTwo = nestedDictIter(cityTwo)
      cityThree = nestedDictIter(cityThree)
      
      outputTextFile(cityOne)
      outputTextFile(cityTwo)
      outputTextFile(cityThree)
      createJsonFile(jsonData)

##dumping the json data into a json file
def createJsonFile(jsonData):
      with open('outputJson.json','w') as file:
            json.dump(jsonData,file)

##creating a text file that contains data on tempreature, max and min temperature, name of city, cnt
            ## and humidity in the special specified format
def outputTextFile(data):
      with open('outputWeather.txt','a') as file:
            file.write('|'.join([data[0],cnt]))
            file.write('\n')
            file.write('|'.join([str(data[1]),str(data[3]),str(data[4]),str(data[2])]))
            file.write('\n')
            file.write('\n')
            
##iterate through dict keys to obtain the desired values.
##cityListTemp is a list that contains the desired weather data on a city passed to nestedDictIter.
##function accepts json data for each city that was retrieved through the API.
def nestedDictIter(city):
      cityListTemp = []
      for key in city:
            if key == 'name':
                  cityListTemp.append(city[key])
            elif key == 'main':
                  mainKey = city[key]
                  for key in mainKey:
                        if key == 'temp':
                              cityListTemp.append(mainKey[key])
                        elif key == 'humidity':
                              cityListTemp.append(mainKey[key])
                        elif key == 'temp_min':
                              cityListTemp.append(mainKey[key])
                        elif key == 'temp_max':
                              cityListTemp.append(mainKey[key])
      return cityListTemp
      
##this function GETS the data from the server through the API endpoint.
##the key parameters that can be set by the user are latitude, longitude, and the number of 
      ##cities around the point that should be returned
def getWeatherData(lat,lon):
      baseURL="http://api.openweathermap.org/data/2.5/find?"
      zipURL=({'lat': lat,
               'lon': lon,
               'cnt': cnt,
               'APPID':'dd9b00c5448c30cee01fadc4a4af4325'
               })
      ##GET requests
      response=requests.get(baseURL,zipURL)
      jsonData = response.json()
      return jsonData

##runs the script
main()

import requests
import json

valueList = []
keyList = []

def main():
      cityName = 'Boston'
      jsonData = getWeatherData(cityName)
      with open('outputJson.json','w') as file:
            json.dump(jsonData,file)
      valueList = nestedDictIter(jsonData)
      with open('outputWeather.txt','w') as file:
            file.write('|'.join(str(item) for item in valueList))

##using recusion to iterate through a dict and a list nested inside of another dict.
##if the value v is a dict, then we use recusion and call the same function
      ##to go 1 nest deeper into the dict.
##isinstance determines if value is of the class that was passed as  the 2nd argument.
##if the value v is not a dict, then we create a key value pair.
##if the value is a list, then the nested for loop iterates through each element in the list
      ##and then invokes recursion
def nestedDictIter(a):
      for key, value in a.items():
            if isinstance(value, type({})):
                  nestedDictIter(value)
            elif isinstance(value,type([])):
                  for item in value:
                        nestedDictIter(item)
            else:
                  valueList.append(value)
                  keyList.append(key)
      return valueList

##this function GETS the data from the server through the API endpoint.
def getWeatherData(cityName):
      baseURL="http://api.openweathermap.org/data/2.5/weather?"
      zipURL=({'q': cityName,
               'APPID':'dd9b00c5448c30cee01fadc4a4af4325'
               })
      ##GET requests
      response=requests.get(baseURL,zipURL)
      jsonData = response.json()
      return jsonData

##runs the script
main()

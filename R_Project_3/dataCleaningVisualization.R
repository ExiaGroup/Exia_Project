#------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------Library------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
library(leaflet)
library(sp) ## --> polygons objects and addpolygon function
library(maps)
library(htmlwidgets)
library(magrittr)
library(plyr)
library(rgdal)
library(raster)
library(stringr)
library(tidyr)  ## --> we use the separate function to separate a column into 2 columns 
library(ggplot2)
library(scales)
library(dplyr)
#------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------Loading Data------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
CancerRates <- read.csv('CancerCountyFIPS.csv')
LandUse <- read.csv('LandUseDatasetREALLatlong.csv')
leadingcausedeath <- read.csv('leading_cause_death.csv', header = TRUE, sep = ',', dec = '.', na.strings=c('NA',''))
uscounty_presidentialresults <- read.csv('US_County_Level_Presidential_Results_12-16.csv', header = TRUE, sep = ',', dec = '.',
                                         na.strings = c("NA",''))
county_info <- read.csv('county_info_2016.csv',header = TRUE, sep = ',', dec = '.', na.strings = c('NA','','na'))
#------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------Data Cleaning------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##selecting only 2013 data in leadingcausedeath
##more elegant method to use compared to boolean indexing; not sure which way is faster
leadingcausedeath <- subset(leadingcausedeath, YEAR == 2013)


##selecting columns of interest
uscounty_presidentialresults <- uscounty_presidentialresults[c(3,4,5,10,11,12)]
county_info <- county_info[c(1,2,4,7,8)]


##exclude Alaska
##more elegant method to use besides boolean indexing; not sure which way is faster
##subset is a function from base r
uscounty_presidentialresults <- subset(uscounty_presidentialresults, state_abbr != 'AK')
county_info <- subset(county_info, USPS != 'AK')


##resets the row count
rownames(county_info) <- NULL
rownames(uscounty_presidentialresults) <- NULL


##removing unnecessary column from leadingcausedeath
leadingcausedeath <- leadingcausedeath[,-2]


##Rename columns to make for a clean df merge later in the code.
##GEOID is the same as FIPS
##colnames() does the same thing as names()
colnames(CancerRates) <- c("location", "GEOID", "rate")
colnames(LandUse) <- c("offset", "lat", "lng", "url", "name")
colnames(uscounty_presidentialresults)[c(5,6)] <- c('location','GEOID')
colnames(leadingcausedeath)[3] <- c('NAME')
##colnames(leadingcausedeath[3]) <- c('NAME') does not change the name of the column
##x[3] is a data frame, but it's a brand new data frame that just happens to be the 3rd column of x. 
##Changing the column name of the new data frame doesn't cause a change of the column names in x


##Add leading zeros to any FIPS code that's less than 5 digits long to get a good match.
##formatC uses C code formatting--> function used to creates a 5 digit int
##width sets the length of the integer, in this case we want it to be 5 digits long
##format sets the type of digit we want, in this case 'd' means integer
##think flag determines what to input in to get width of digit to be 5.
CancerRates$GEOID <- formatC(CancerRates$GEOID, width = 5, format = "d", flag = "0")
uscounty_presidentialresults$GEOID <- formatC(uscounty_presidentialresults$GEOID, width = 5, format = "d", flag = "0")
county_info$GEOID <- formatC(county_info$GEOID, width = 5, format = 'd',flag = '0')


##removing united states as a state
leadingcausedeath <- filter(leadingcausedeath, !(NAME == 'United States'))


##dropping unused levels from data.frames
leadingcausedeath <- droplevels(leadingcausedeath)
uscounty_presidentialresults <- droplevels(uscounty_presidentialresults)
county_info <- droplevels(county_info)


##converting factor into int or numeric
leadingcausedeath$DEATHS <- as.integer(leadingcausedeath$DEATHS)
##have to convert to character then numeric or decimals get removed
leadingcausedeath$AADR <- as.character(leadingcausedeath$AADR) 
##NA's get introduced because there are non numeric values in the aadr column
leadingcausedeath$AADR <- as.numeric(leadingcausedeath$AADR) 


##turning int type into character type 
uscounty_presidentialresults$GEOID <- as.character(uscounty_presidentialresults$GEOID)
LandUse$offset <- as.character(LandUse$offset)


##there is a warning output because some entries are non-numeric; this does not have any significant effect
##removing leadingcausedeath$aadr non-numeric values
leadingcausedeath <- filter(leadingcausedeath, !(is.na(AADR)))


##Convert column called location to two columns: State and County
CancerRates <- separate(CancerRates, location, into = c("county", "state"), sep = ", ")
##we get NA for one entry because there is no state associated with District of columbia
##we proceed to fix this entry by inputing district of columbia as a state
CancerRates$state[2084] = 'District of Columbia'


##Remove the (x,y) from the state values with an empty string
##gsub function allows for pattern matching and replacement
CancerRates[] <- lapply(CancerRates, function(x) gsub("\\s*\\([^\\)]+\\)", "", x))


#Change CancerRates$rate to a number
CancerRates$rate <- as.numeric(as.character(CancerRates$rate))


##Convert full state names to abbreviations for a clean df merge later.
##match function tells us where each element in CancerRates$state matches to the same element in state.name 
CancerRates$state <- state.abb[match(CancerRates$state,state.name)]


##selecting 1 disease data from leadingcausedeath
stroke_death <- filter(leadingcausedeath, CAUSE_NAME == 'Stroke')
#------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------Clean Data to CSV------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
write.csv(CancerRates, file = 'Cleaned_CancerRates.csv',row.names = FALSE, na='')
write.csv(county_info, file = 'Cleaned_CountyInfo.csv', row.names = FALSE, na='')
write.csv(stroke_death,file = 'Cleaned_strokedeath.csv', row.names = FALSE, na='')
write.csv(uscounty_presidentialresults, file = 'Cleaned_uscounty_presidentialresults.csv',row.names = FALSE, na='')
#------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------loading US Map Polygon data--------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
#Download county shape file and state shape file
#I downloaded the zip and placed all files in the zip into my RStudio folder
us.map <- readOGR(dsn = ".", layer = "cb_2017_us_county_20m", stringsAsFactors = FALSE)
us.state.map <- readOGR(dsn = ".", layer = "cb_2017_us_state_20m", stringsAsFactors = FALSE)


#Remove Alaska(2), Hawaii(15), Puerto Rico (72), Guam (66), Virgin Islands (78), American Samoa (60)
#Mariana Islands (69), Micronesia (64), Marshall Islands (68), Palau (70), Minor Islands (74)
us.map <- us.map[!us.map$STATEFP %in% c("02", "15", "72", "66", "78", "60", "69",
                                        "64", "68", "70", "74"),]
us.state.map <- us.state.map[!us.state.map$STATEFP %in% c("02", "15", "72", "66", "78", "60", "69",
                                        "64", "68", "70", "74"),]


#Make sure other islands are removed.
us.map <- us.map[!us.map$STATEFP %in% c("81", "84", "86", "87", "89", "71", "76",
                                        "95", "79"),]
us.state.map <- us.state.map[!us.state.map$STATEFP %in% c("81", "84", "86", "87", "89", "71", "76",
                                        "95", "79"),]
us.state.map$NAME <- as.factor(us.state.map$NAME)


##Merge spatial df with downloaded data.
cancermap <- merge(us.map, CancerRates, by=c("GEOID"))
strokedeathmap <- merge(us.state.map, stroke_death, by=c("NAME"))
presidentialresults <- merge(us.map,uscounty_presidentialresults, by =c("GEOID"))
county_info <- merge(us.map,county_info, by=c("GEOID"))
##for some reason 
##presidentialresults <- merge(uscounty_presidentialresults, us.map, by =c("GEOID"))
##does not create the right data variable; it does not include the polygon data
#------------------------------------------------------------------------------------------------------------------------------
#--------------------------------------------------------------popup data------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
# Format popup data for leaflet map.
##paste0() takes a vector and concatenates into a character vector 
popup_dat <- paste0("<strong>County: </strong>", 
                    cancermap$county, 
                    "<br><strong>Cancer Rate (Age Adjusted) Out of 100,000: </strong>", 
                    cancermap$rate)

##Make pop up for the land use sites
# Format popup data for leaflet map.
popup_LU <- paste0("<strong>Use Name: </strong>", 
                   LandUse$name, 
                   "<br><strong>Link: </strong>", 
                   LandUse$url)
popup_SD <- paste0("<strong>Use State: </strong>", strokedeathmap$NAME,
                   "<br><strong>Age-Adjusted Death Rate: </strong>", strokedeathmap$AADR)
popup_PR <- paste0("<strong>Use County: </strong>",
                   presidentialresults$location,
                   "<br><strong>Total Vote:",
                   presidentialresults$total_votes_2016)
popup_LD <- paste0("<strong>Use County: </strong>",
                   county_info$NAME,
                   "<br><strong>Total Land Area in square miles",
                   county_info$ALAND_SQMI)
popup_WT <- paste0("<strong>Use County: </strong>",
                   county_info$NAME,
                   "<br><strong>Total Water Area in square miles",
                   county_info$AWATER_SQMI)
#------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------Leaflet Map------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
##YlOrRd is the color palette
pal <- colorQuantile("YlOrRd", NULL, n = 9)


gmap <- leaflet(data = cancermap) %>%
  # Base groups
  addTiles() %>%
  setView(lng = -105, lat = 40, zoom = 4) %>% 
  # Overlay groups
  addPolygons(fillColor = ~pal(rate), 
              fillOpacity = .9, 
              weight = 1,
              popup = popup_dat,
              group="Cancer Rate/100,000 by Counties") %>% 
  addPolygons(data = presidentialresults,
              fillColor = ~pal(total_votes_2016),
              fillOpacity = .8,                 
              weight = 1,                
              popup = popup_PR,
              group = "Total Votes per County") %>%
  addMarkers(data=LandUse,lat=~lat, lng=~lng, popup=popup_LU, group = "Land Use Sites") %>% 
  addPolygons(data=strokedeathmap, 
              fillOpacity = .7,
              fillColor = ~pal(AADR),
              weight =1, 
              popup = popup_SD,
              group = 'Stroke Age-Adjusted Death Rate') %>%
  addPolygons(data =county_info, 
              fillOpacity  = .6,
              fillColor = ~pal(ALAND_SQMI),
              weight = 1,
              popup = popup_LD,
              group = 'County Land Area in square miles') %>%
  addPolygons(data =county_info, 
              fillOpacity  = .5,
              fillColor = ~pal(AWATER_SQMI),
              weight = 1,
              popup = popup_WT,
              group = 'County Water Area in square miles') %>%
  # Layers control
  addLayersControl(
    overlayGroups = c("Land Use Sites",'Stroke Age-Adjusted Death Rate',"Cancer Rate/100,000 by Counties",
                      "Total Votes per County", 'County Land Area in square miles','County Water Area in square miles'),
    options = layersControlOptions(collapsed= FALSE))
gmap
saveWidget(gmap, 'US_county_cancer_poll_map.html', selfcontained = TRUE)
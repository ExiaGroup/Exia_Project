##Scrapes real-time stock price off of yahoo finance
from bs4 import BeautifulSoup  
from urllib.request import urlopen 

##takes in any stock ticker symbol
def main():
    User_stock = input('Enter a stock ticker(Case Sensitive): ')
    Stocks(User_stock)
    

def Stocks(symbol):
    stock_url = symbol+'?p='+symbol
    url = 'https://finance.yahoo.com/quote/'+stock_url
    page = urlopen(url)
    soup = BeautifulSoup(page, 'lxml')
    ##index =1 contains the current stock price value
    ##it seems beautifulsoup reads the website in mobile format
    currentprice = soup.findAll('span',attrs={'data-reactid':'21'})[1].text
    print(currentprice)
    
##loops until user wants to stop scarping
while True:
    main()
    keep_going = input('Do you want to continue(case sensitive):(y/n) ')
    if keep_going == 'n':
        break
    
    



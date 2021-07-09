*! version on 1.0 22feb2020

/*
 version0.1 - This version broke when Yahoo changed its Finance API. 
 version1.0 - While reparing a stata/python workshop for the 2020 German Stata Conference
 it occured to me that this command could be rescued using the new python integration in stata 16
 and be part of the workshop too. Several people contacted me since the Yahoo API chances broke  stockquote. I hope it finds its audience again. 
*/

program def stockquote
	version 16.0

	syntax [anything(name=ticksym)], [start_date(string)] [end_date(string)]
	
	*if we got nothing we help 
	
	if "`ticksym'" == "" | "`start_date'"=="" | "`end_date'"=="" {
		di "Command uses Python module 'yfinance' to get stock prices from Yahoo Finance."
		di as smcl "{help stockquote args:Read the help page to get started}"
		exit
	}
	*check yfinance is present
	capture python which yfinance 
	if _rc != 0 {
		
		di as smcl "You need to install the Python module yfinance: see {help stockquote args: help stockquote}"
		exit
	}
	
	
	clear
	
	python: from sfi import Macro
	python: ticksym = Macro.getLocal('ticksym')
	python: max = Macro.getLocal('max')
	python: print(max)
	python: start_date 	= Macro.getLocal('start_date')
	python: end_date 	= Macro.getLocal('end_date')
	python: yahoo(ticksym, start_date, end_date)
	
	label data "Symbol: `ticksym', Source: http://finance.yahoo.com"
	label variable  open "Opening price"
	label variable  high "High price"
	label variable  low "Low price"
	label variable  close "Closing price"
	label variable  volume "Volume traded"
	label variable  adjclose "Adjusted Closing price"
	replace date = dofc(date)
	format date %td
	
end


*** Python below here


version 16.0
python:

from sfi import Macro
from sfi import Data as data
from sfi import Datetime as dt
import re
import pandas as pd
import yfinance as yf


def yahoo(ticksym, start_date, end_date):
	
	x = yf.download(ticksym, start=start_date, end=end_date)		
		
	print("")
	#print(x.head())
	#print(list(x.index.values))
	sd = [dt.getSIF(pd.to_datetime(z), '%tcDDmonCCYY_HH:MM:SS') for z in list(x.index.values) ]
	#print(sd)
	data.setObsTotal(len(x))
	
	data.addVarFloat('open')
	data.addVarFloat('high')
	data.addVarFloat('low')
	data.addVarFloat('close')
	data.addVarFloat('adjclose')
	data.addVarFloat('volume')
	data.addVarFloat('date')

	
	data.store('open',range(len(x['Open'])),x['Open'])
	data.store('high',range(len(x['High'])),x['High'])
	data.store('low',range(len(x['Low'])),x['Low'])
	data.store('close',range(len(x['Close'])),x['Close'])
	data.store('adjclose',range(len(x['Adj Close'])),x['Adj Close'])
	data.store('volume',range(len(x['Volume'])),x['Volume'])
	data.store('date',range(len(sd)),sd)

end




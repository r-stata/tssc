* Google Geochart wrapper for Stata
* Create interactive web pages with maps plotting Stata data
* 2.0.0 Sergiy Radyakin, Economist, 
* Development Economics Research Group (DECRG) The World Bank, 19 February 2014


program define geochart
  version 9.0
  syntax varlist , save(string) [ nostart replace ///
                   title(string) note(string) ///
		           region(string) resolution(string) ///
		           width(real 556) height(real 347) ///
		           colorlow(string) colorhigh(string) savebtn]
  
  local outcome : word 1 of `varlist'
  local country : word 2 of `varlist'
  
  if (`"`region'"'!="") local region ", region: '`region''" 
  else local region ""
  
  if (`"`resolution'"'!="") local resolution ", resolution: '`resolution''"
  else local resolution ""
  
  if (`"`colorlow'"'=="") local colorlow "green" 
  if (`"`colorhigh'"'=="") local colorhigh "red"

  if (`"`replace'"'=="replace") capture erase `"`save'"' 

  mata geochart()
  
  display `"`nostart'"'
  
  if (`"`start'"'=="") {

    display as text "Starting: " as result "`save'"

    view browse "`save'"
  }

end

*** END OF FILE

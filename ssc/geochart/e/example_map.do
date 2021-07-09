
// Sergiy Radyakin 2013
// Create example web page

use "hcpov_2usd.dta"

local webpage "c:\temp\example.html"
local indicator "Poverty headcount ratio at $2 a day (PPP) (% of population)"
local notetext `"Source: data.worldbank.org/indicator/SI.POV.2DAY, most recent data for each country plotted"'

// for World
//geochart p0 name2 , width(800) height(600) save(`"`webpage'"') replace title("`indicator'") note(`"`notetext'"') 

// for a specific region
geochart p0 name2 , width(800) height(600) save(`"`webpage'"') replace title("`indicator'") note(`"`notetext'"') region("142") savebtn


// END OF FILE

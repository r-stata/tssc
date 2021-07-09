// GEOCHART in Stata example

// Plot the poverty map of Indonesia using the INDO-DAPOER 
// (Indonesia Database for Policy and Economic Research) data
// http://databank.worldbank.org/data/views/variableselection/selectvariables.aspx?source=1266#
// and Google's Geochart services

// 2014 Sergiy Radyakin, The World Bank

insheet using "http://radyakin.org/stata/geochart/example/indonesia_p0_2012.csv", comma clear
generate province=subinstr(country_name, ", Prop.","",.)

geochart poverty province , ///
    region("ID") resolution("provinces") ///
    title("Poverty rate in Indonesia by province, 2012") ///
	note("INDO-DAPOER (Indonesia Database for Policy and Economic Research) data") ///
    width(1280) height(800) save(`"c:\temp\ind.htm"') replace savebtn
	
// END OF FILE

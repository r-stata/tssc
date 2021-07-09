/**********************************************************************************************************************************
DISCLAIMER: The World Economic Forum is the provider of the Global Competitiveness Index 2017-2018, a framework and a corresponding set of indicators for 137 economies. The software gciget.ado provides a practical way to read the indicators into Stata (R). The responsibility of complying with the terms and conditions of use under which the owner of the data grants access to the indicators is entirely with the user but not with the authors of the software gciget.ado. Any user of gciget.ado is responsible for making him or herself familiar with the terms of use under which she or he is allowed to work with the data of the Global Competitiveness Index. For more information and methodology, please see "`disclink'". In no event will the authors, owners, and creators of gciget.ado, or their employers or any other party who may modify and/or redistribute this software, accept liability for any loss or damage suffered as a result of using the gciget.ado software.  
**********************************************************************************************************************************/

***********************************************************************************************************************************
* Obtaining varibles from http://reports.weforum.org/global-competitiveness-index-2017-2018/downloads/
***********************************************************************************************************************************
*! version 1.4 2018-05-23
*! version 1.3 2018-05-11
*! version 1.2 2018-05-06
*! version 1.1 2018-04-27
*! version 1.0 2018-04-26
*! authors Harald Tauchmann & Oleg Badunenko
capture program drop gciget
program gciget, nclass
	version 12.1
    syntax [anything], [CLEAR] [noXTset] [noWARNings] [noQUERY] [PANELVar(name)] [URL(string asis)] [SHEET(string asis)] [CELLRANGE(string asis)]
    tempfile mydataraw myrunningfile myexcelfile mydatarawcn olddata
    ** DISPLAY DISCLAIMER **
    local ls = c(linesize)+0
    local disclink "in smcl `"{browse "http://wef.ch/gcr17":http://wef.ch/gcr17}"'"
    local discdata "The World Economic Forum is the provider of the Global Competitiveness Index 2017-2018, a framework and a corresponding set of indicators for 137 economies. The software gciget.ado provides a practical way to read the indicators into Stata (R). The responsibility of complying with the terms and conditions of use under which the owner of the data grants access to the indicators is entirely with the user but not with the authors of the software gciget.ado. Any user of gciget.ado is responsible for making him or herself familiar with the terms of use under which she or he is allowed to work with the data of the Global Competitiveness Index. For more information and methodology, please see "`disclink'". In no event will the authors, owners, and creators of gciget.ado, or their employers or any other party who may modify and/or redistribute this software, accept liability for any loss or damage suffered as a result of using the gciget.ado software."
    if c(noisily) == 0 {
        local dstyle1 "input"
        local dstyle2 "text"
    }
    else {
        local dstyle1 "text"
        local dstyle2 "input"
    }
    noisily di as `dstyle1' _newline "{p 0 2 2 `ls'}DISCLAIMER: `discdata'{p_end}" _newline
    if "`anything'" != "" {
		local mynamelist = subinstr("`anything'",".","_",.)
	}
    if "`url'" == "" | "`url'" == "http://www3.weforum.org/docs/GCR2017-2018/GCI_Dataset_2007-2017.xlsx" {
        local url "http://www3.weforum.org/docs/GCR2017-2018/GCI_Dataset_2007-2017.xlsx"
    }
    else {
        if "`warnings'" != "nowarnings" {
            di as error "{p 0 2 2 `ls'}warning: you have specified a download link that differs from the default; make sure that this link is valid{p_end}"
        }
    }
    local lru = strreverse("`url'")
    local lru : subinstr local lru "\" "/", all
    gettoken lecxe link : lru, parse("/")
    local excel = strreverse("`lecxe'")
    if "`sheet'" == "" | "`sheet'" == "Data" {	
        local sheet "Data" 
    }
    else {
        if "`warnings'" != "nowarnings" {
            di as error "{p 0 2 2 `ls'}warning: you have specified an excel sheet that differs from the default; make sure that the sheet is valid{p_end}" 
        }   
    }
    if "`cellrange'" == "" | "`cellrange'" == "A3:FM6527" {	
        local cellrange "A3:FM6527" 
    }
    else {
        if "`warnings'" != "nowarnings" {
            di as error "{p 0 2 2 `ls'}warning: you have specified a cell range that differs from the default; make sure that the sheet is valid; if not, the results are unpredictable{p_end}"    
        }
    }
	local novars = c(k) == 0
	if ("`clear'" == "clear") {
        if(`novars' == 0){
            qui save `olddata'
        }
		clear
	}
	if (`novars' == 0) & "`clear'" != "clear" {
		display as error "no; data in memory would be lost"
		exit 4
	}
	di as txt "Downloading the " as `dstyle2' "`excel'" as txt " file"
	capture copy "`url'" `myexcelfile', replace
	if _rc != 0 {
        if "`url'" == "http://www3.weforum.org/docs/GCR2017-2018/GCI_Dataset_2007-2017.xlsx" {
            display as error "Could not download excel file from http://reports.weforum.org/global-competitiveness-index-2017-2018/downloads/"
        }
        else {
		  display as error "Could not download excel file from `url'"
        }
        if "`clear'" == "clear" & `novars' == 0 {
            use `olddata', clear
        }
 		exit _rc
	}
	di as txt "Importing the " as `dstyle2' "`excel'" as txt " file"
	cap import excel `myexcelfile', sheet("`sheet'") cellrange(`cellrange') firstrow clear
    if _rc != 0 {
        di as error "{p 0 2 2 `ls'}import of GCI data failed; check structure of the excel file `excel'{p_end}"
        if "`clear'" == "clear" & `novars' == 0 {
            use `olddata', clear
        }
 		exit _rc            
    }
	qui drop in 1
	qui keep if Attribute == "Value"
	qui drop Placement Dataset Seriescode Seriesunindented Attribute FE GCREAP GCRMENA GCRLATAM GCREUROPENA GCREURASIA GCRSSA GCRSASIA FM
	g year = substr(Edition,1,4)
	qui replace GLOBALID = subinstr(GLOBALID,".","_",.)
	qui levelsof GLOBALID, local(uniqVarList) separate(" ")
	*di `uniqVarList'
    if "`anything'" != "" {
        local mylist: list uniqVarList & mynamelist
        if "`mylist'" == "" {
            display as error "no requested variable found in GCI"
            clear
            if "`clear'" == "clear" & `novars' == 0 {
                use `olddata', clear
            }
            exit 111
        }
    }
    else {
        local mylist "`uniqVarList'"
    }
	
	qui drop Edition
	order year
	qui destring year, replace
	qui save `mydataraw', replace
	
	* get the country names and charecteristics
	import excel `myexcelfile', sheet("Entities") cellrange(A3:F155) first clear
	ren Entitycode 	countrycode
	lab var countrycode "Country code"
	ren Entity country
	lab var country "Country"
	drop Entitytype
	ren IncomegroupWorldBankJuly2 imfincgroup
	lab var imfincgroup "Income group (World Bank, July 2016)"
	ren RegionIMFApril2016 imfregion
	lab var imfregion "Region (IMF, April 2016)"
	ren Forumclassification wefregion
	lab var wefregion "World Economic Forum classification"
	qui save `mydatarawcn', replace
	
    local varcount = 0
	foreach var of local mylist {
        local varcount = `varcount'+1
        tempfile _myfilename`varcount'
        local _mytemplist "`_mytemplist' `_myfilename`varcount''"
		* open all
		use `mydataraw', clear
		*display "Current variable is " as result "`var'"
		local varname = subinstr("`var'",".","_",.)
		*di "`myfilename'"
		*work with only one var at a time
		qui keep if GLOBALID == "`var'"
		drop GLOBALID
		qui destring, replace
		qui save `myrunningfile', replace
		local mylabel = Series[1]
		*di "`mylabel'"
		local mylabel = strltrim("`mylabel'")
		*di "`mylabel'"
		display as text "Processing " as `dstyle2' "`var'" as text ":  " as res "`mylabel'"
		* work over years
		qui su year
		local year_b `r(min)'
		local year_c `r(max)'
		forval time = `year_b'/`year_c'{
		*di `time'
		use `myrunningfile', clear
		qui keep if year == `time'
		* transpose
		xpose, clear varname
		g year = `time'
		order year _varname v1
		ren _varname countrycode
		qui drop if countrycode == "Series"
		qui drop if countrycode == "year"
		label var v1 "`mylabel'"		
		ren v1 `varname'
		if `time' == `year_b'{
			qui save  "`_myfilename`varcount''", replace
		} 
		else {
			qui append using "`_myfilename`varcount''"
		}
		sort year countrycode	
		qui save "`_myfilename`varcount''", replace
		}	
	}
 	qui merge year countrycode using `_mytemplist'
 	drop _merge*
 	lab var countrycode "Country code"
 	lab var year "Year"
 	
	qui merge m:1 countrycode using `mydatarawcn'
	drop _merge*
    if "`xtset'" != "noxtset" {
        if "`panelvar'" != "" {
            cap confirm new variable `panelvar'
            if _rc == 110 {
                di as error "{p 0 2 2 `ls'}variable {bf:`panelvar'} alreday defined; name of panelvar set to default{p_end}"
                local panelvar "cnNumber"
            }
            if _rc == 198 {
                di as error "{p 0 2 2 `ls'}{bf:`panelvar'} invalid varname; name of panelvar set to default{p_end}"
                local panelvar "cnNumber"
            }
        }
        else {
            local panelvar "cnNumber"
        }
    	egen `panelvar' = group(countrycode)
    	order year `panelvar' countrycode country imfincgroup imfregion wefregion
    	qui xtset `panelvar' year, `query' yearly
    }
    else {
        order year countrycode country imfincgroup imfregion wefregion
    }
	sort countrycode year
end


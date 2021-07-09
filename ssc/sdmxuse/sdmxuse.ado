/*******************************************************************************	
	
	Author: Sebastien Fontenay (sebastien.fontenay@uclouvain.be)
	Version: 2.0
	Last update: June 2018
	
	This program uses the package "moss" by Robert Picard & Nicholas J. Cox
	
	Many thanks for suggestions of improvements to: Samuel Pinto Ribeiro & Jan Helmdag
	
*******************************************************************************/

program define sdmxuse
version 13.0
syntax namelist(min=2 max=2) [, clear dataset(string) dimensions(string) attributes start(string) end(string) timeseries panel(string) mergedsd]

quietly {

// Create local macros

tokenize `namelist'
local resource "`1'"
local provider "`2'"

if "`provider'"=="ECB" {
	local url "http://sdw-wsrest.ecb.europa.eu/service/"
	local prefix="generic:"
	local prefix_str="str:"
	local prefix_com="com:"
	local dataflow="<`prefix_str'Dataflow "
	local id="id"
	local name="com:Name"
	local value_id="<`prefix'Value id="
	if "`start'"!="" {
		local start "&startPeriod=`start'"
	}
	if "`end'"!="" {
		local end "&endPeriod=`end'"
	}
}
if "`provider'"=="ESTAT" {
	local url "http://ec.europa.eu/eurostat/SDMX/diss-web/rest/"
	local prefix="generic:"
	local prefix_str="str:"
	local prefix_com="com:"
	local dataflow="<`prefix_str'Dataflow "
	local id="id"
	local name="com:Name"
	local value_id="<`prefix'Value id="
	if "`start'"!="" {
		local start "&startPeriod=`start'"
	}
	if "`end'"!="" {
		local end "&endPeriod=`end'"
	}
}
if "`provider'"=="IMF" {
	local url "http://dataservices.imf.org/REST/SDMX_XML.svc/"
	local prefix=""
	local prefix_str=""
	local prefix_com=""
	local dataflow="<`prefix_str'Dataflow "
	local id="value"
	local name="`prefix_str'Description"
	local value_id="<`prefix'Value concept="
	if "`start'"!="" {
		local start "&startPeriod=`start'"
	}
	if "`end'"!="" {
		local end "&endPeriod=`end'"
	}
}
if "`provider'"=="OECD" {
	local url "https://stats.oecd.org/restsdmx/sdmx.ashx/"
	local prefix=""
	local prefix_str=""
	local prefix_com=""
	local dataflow="<KeyFamily "
	local id="value"
	local name="`prefix_str'Description"
	local value_id="<`prefix'Value concept="
	if "`start'"!="" {
		local start "&startTime=`start'"
	}
	if "`end'"!="" {
		local end "&endTime=`end'"
	}
}
if "`provider'"=="UNSD" {
	local url "http://data.un.org/WS/rest/"
	local prefix="generic:"
	local prefix_str=""
	local prefix_com=""
	local dataflow="<`prefix_str'Dataflow "
	local id="id"
	local name="Name"
	local value_id="<`prefix'Value id="
	if "`start'"!="" {
		local start "&startPeriod=`start'"
	}
	if "`end'"!="" {
		local end "&endPeriod=`end'"
	}
}
if "`provider'"=="WB" {
	local url "http://api.worldbank.org/"
	local prefix="generic:"
	local prefix_str="structure:"
	local prefix_com=""
	local dataflow=""
	local id="value"
	local name="`prefix_str'Description"
	local value_id="<`prefix'Value concept="
	if "`start'"!="" {
		local start "&startPeriod=`start'"
	}
	if "`end'"!="" {
		local end "&endPeriod=`end'"
	}
}

// Rename macro (differs according to OS)

if c(os)=="Windows" {
	local renamecmd "!rename"
}

else {
	local renamecmd "!mv"
}

// Error message

if ("`resource'"=="datastructure" & "`dataset'"=="") | ("`resource'"=="data" & "`dataset'"=="") {
	noisily display in red "You must specify the dataset identifier with the following option [, dataset()]"
	exit
}

if ("`timeseries'"!="" & "`mergedsd'"!="") | ("`panel'"!="" & "`mergedsd'"!="") {
	noisily display in red "You cannot specify both timeseries/panel and mergedsd options"
	exit
}

// Clear data

if `"`clear'"' == "clear" {
	clear
} 
if (c(changed) == 1) & (`"`clear'"' == "" ) {
	error 4
}

/***********************************************************************
Dataflow
************************************************************************/

if "`resource'"=="dataflow" {

	// Build and send query
	
	if "`provider'"=="ECB" | "`provider'"=="ESTAT" | "`provider'"=="UNSD" {
		copy "`url'dataflow/`provider'/" tmp_sdmxdataflow.txt, replace
	}
	if "`provider'"=="IMF" {
		copy "`url'Dataflow" tmp_sdmxdataflow.txt, replace
	}
	if "`provider'"=="OECD" {
		copy "`url'GetDataStructure/ALL/" tmp_sdmxdataflow.txt, replace
	}
	if "`provider'"=="WB" {
		noisily di in red "Only WDI (World Development Indicators) are available from the World Bank"
		exit
	}

	// Import data into Stata

	filefilter tmp_sdmxdataflow.txt tmp_sdmxdataflow2.txt, from("\n") to ("") replace
	erase tmp_sdmxdataflow.txt
	`renamecmd' tmp_sdmxdataflow2.txt tmp_sdmxdataflow.txt
	filefilter tmp_sdmxdataflow.txt tmp_sdmxdataflow2.txt, from("\r") to ("") replace
	erase tmp_sdmxdataflow.txt
	`renamecmd' tmp_sdmxdataflow2.txt tmp_sdmxdataflow.txt
	filefilter tmp_sdmxdataflow.txt tmp_sdmxdataflow2.txt, from("`dataflow'") to ("\r\n`dataflow'") replace
	erase tmp_sdmxdataflow.txt
	`renamecmd' tmp_sdmxdataflow2.txt tmp_sdmxdataflow.txt

	import delimited tmp_sdmxdataflow.txt, clear delimiters("|||", asstring) rowrange(2) varnames(nonames)

	// Format dataset
	
	local strsize=strlen("</`prefix_com'Name>")-1
	replace v1=substr(v1, 1, strpos(v1, "</`prefix_com'Name>")+`strsize')
	_moss v1, match(`"id="([a-zA-Z0-9_-]+)"') regex
	rename _match1 dataflow_id
	drop _*
	if "`provider'"=="UNSD" {
		replace v1=subinstr(v1, `" xmlns="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/common""', "", .)
	}
	_moss v1, match(`"<`prefix_com'Name xml:lang="en">(.*)</`prefix_com'Name>"') regex
	rename _match1 dataflow_description
	drop _* v1
	if "`provider'"=="IMF" {
		replace dataflow_id=subinstr(dataflow_id, "DS-", "", .)
	}
	
	// Erase text file with raw data

	cap erase tmp_sdmxdataflow.txt
}

/***********************************************************************
Datastructure
************************************************************************/

if "`resource'"=="datastructure" | "`mergedsd'"!="" {

	// Find datastructure_id
	
	if "`provider'"=="ECB" | "`provider'"=="ESTAT" | "`provider'"=="UNSD" {
		copy "`url'dataflow/`provider'/`dataset'/" tmp_sdmxdataflow.txt, replace
		filefilter tmp_sdmxdataflow.txt tmp_sdmxdataflow2.txt, from("\n") to ("") replace
		erase tmp_sdmxdataflow.txt
		`renamecmd' tmp_sdmxdataflow2.txt tmp_sdmxdataflow.txt
		filefilter tmp_sdmxdataflow.txt tmp_sdmxdataflow2.txt, from("\r") to ("") replace
		erase tmp_sdmxdataflow.txt
		`renamecmd' tmp_sdmxdataflow2.txt tmp_sdmxdataflow.txt
		import delimited tmp_sdmxdataflow.txt, clear delimiters("|||", asstring) varnames(nonames)
		replace v1=substr(v1, strpos(v1, "<`prefix_str'Structure>"), .)
		_moss v1, match(`"id="([a-zA-Z0-9_-]+)"') regex
		rename _match1 datastructure_id
		drop _* v1
		local datasetDSD=datastructure_id[1]
		cap erase tmp_sdmxdataflow.txt
	}
	else{
		local datasetDSD="`dataset'"
	}
	
	// Build and send query

	if "`provider'"=="ECB" | "`provider'"=="ESTAT" | "`provider'"=="UNSD" {
		copy "`url'datastructure/`provider'/`datasetDSD'/?references=children" tmp_sdmxdatastructure.txt, replace
	}
	if "`provider'"=="IMF" {
		copy "`url'DataStructure/`datasetDSD'" tmp_sdmxdatastructure.txt, replace
	}
	if "`provider'"=="OECD" {
		copy "`url'GetDataStructure/`datasetDSD'" tmp_sdmxdatastructure.txt, replace
	}
	if "`provider'"=="WB" {
		copy "`url'KeyFamily?id=ALL" tmp_sdmxdatastructure.txt, replace
	}

	// Import data into Stata

	if "`provider'"=="IMF" | "`provider'"=="OECD" | "`provider'"=="WB" {
		filefilter tmp_sdmxdatastructure.txt tmp_sdmxdatastructure2.txt, from("<`prefix_str'CodeList id=") to ("<`prefix_str'Codelist id=") replace
		erase tmp_sdmxdatastructure.txt
		`renamecmd' tmp_sdmxdatastructure2.txt tmp_sdmxdatastructure.txt
	}
	filefilter tmp_sdmxdatastructure.txt tmp_sdmxdatastructure2.txt, from("\n") to ("") replace
	erase tmp_sdmxdatastructure.txt
	`renamecmd' tmp_sdmxdatastructure2.txt tmp_sdmxdatastructure.txt
	filefilter tmp_sdmxdatastructure.txt tmp_sdmxdatastructure2.txt, from("\r") to ("") replace
	erase tmp_sdmxdatastructure.txt
	`renamecmd' tmp_sdmxdatastructure2.txt tmp_sdmxdatastructure.txt
	copy tmp_sdmxdatastructure.txt codelists.txt, replace

	// Data structure

	filefilter tmp_sdmxdatastructure.txt tmp_sdmxdatastructure2.txt, from("<`prefix_str'Dimension ") to ("\r\n<`prefix_str'Dimension ") replace
	erase tmp_sdmxdatastructure.txt
	`renamecmd' tmp_sdmxdatastructure2.txt tmp_sdmxdatastructure.txt
	import delimited tmp_sdmxdatastructure.txt, clear delimiters("|||", asstring) rowrange(2) varnames(nonames)

	tempfile dimensionsDSD
	if "`provider'"=="ECB" | "`provider'"=="ESTAT" | "`provider'"=="UNSD" {
		local strsize=strlen("</`prefix_str'Dimension>")-1
		replace v1=substr(v1, 1, strpos(v1, "</`prefix_str'Dimension>")+`strsize')
	}
	if "`provider'"=="IMF" | "`provider'"=="OECD" | "`provider'"=="WB" {
		replace v1=substr(v1, 1, strpos(v1, "/>")+1)
	}
	if "`provider'"=="ECB" | "`provider'"=="ESTAT" | "`provider'"=="UNSD" {
		_moss v1, match(`"id="([a-zA-Z0-9_-]+)"') regex
		rename _match1 concept
		rename _match3 codelist
		replace codelist=subinstr(codelist, "CL_", "", .)
		drop _*
		_moss v1, match(`"position="([0-9]+)"') regex
		rename _match1 position
		destring position, replace
		drop _*
		sort position
	}
	if "`provider'"=="IMF" | "`provider'"=="OECD" | "`provider'"=="WB" {
		_moss v1, match(`"conceptRef="([a-zA-Z0-9_-]+)"') regex
		rename _match1 concept
		drop _*
		_moss v1, match(`"codelist="CL_([a-zA-Z0-9_-]+)"') regex
		rename _match1 codelist
		drop _*
	}
	if "`provider'"=="IMF" | "`provider'"=="OECD" {
		gen position=_n
	}
	if "`provider'"=="WB" {
		gen position=1 if concept=="REF_AREA"
		replace position=2 if concept=="SERIES"
		drop if concept=="FREQ"
		sort position
	}
	drop v1
	local _concept ""
	qui count
	forvalues i=1/`r(N)' {
		if `i'!=`r(N)'{
			local _concept="`_concept'"+concept[`i']+"."
		}
		if `i'==`r(N)' {
			local _concept="`_concept'"+concept[`i']
		}
	}
	if "`mergedsd'"=="" {
		noisily di "Order of dimensions: (`_concept')"
	}
	sum position
	local position_nb=r(N)
	save `dimensionsDSD', replace

	// Codelists

	filefilter codelists.txt codelists2.txt, from("<`prefix_str'Codelist ") to ("\r\n<`prefix_str'Codelist ") replace
	erase codelists.txt
	`renamecmd' codelists2.txt codelists.txt
	filefilter codelists.txt codelists2.txt, from("<`prefix_str'Code ") to ("\r\n<`prefix_str'Code ") replace
	erase codelists.txt
	`renamecmd' codelists2.txt codelists.txt
	import delimited codelists.txt, clear delimiters("|||", asstring) rowrange(2) varnames(nonames)

	// Format dataset

	local strsize=strlen("</`prefix_str'Code>")-1
	replace v1=substr(v1, 1, strpos(v1, "</`prefix_str'Code>")+`strsize') if regexm(v1, "</`prefix_str'Code>")
	gen series=regexm(v1, "<`prefix_str'Codelist ")
	replace series=sum(series)
	
	preserve
	tempfile concept
	keep if regexm(v1, "<`prefix_str'Codelist ")
	_moss v1, match(`"id="CL_([a-zA-Z0-9_-]+)"') regex
	rename _match1 concept
	drop _* v1
	save `concept', replace

	restore
	tempfile codes
	keep if regexm(v1, "<`prefix_str'Code ")
	_moss v1, match(`"`id'="([a-zA-Z0-9_-]+)"') regex max(1)
	rename _match1 code
	drop _*
	if "`provider'"=="WB" {
		replace v1=subinstr(v1, "<![CDATA[", "", .)
		replace v1=subinstr(v1, "]]>", "", .)
	}
	if "`provider'"=="OECD" {
		replace v1=regexr(v1, `"<Description xml:lang="fr">(.*)</Description>"', "")
	}
	if "`provider'"=="UNSD" {
		replace v1=subinstr(v1, `" xmlns="http://www.sdmx.org/resources/sdmxml/schemas/v2_1/common""', "", .)
	}
	_moss v1, match(`"<`name' xml:lang="en">(.*)</`name'>"') regex
	rename _match1 code_lbl
	drop _* v1
	save `codes', replace

	use `concept', clear
	merge 1:m series using `codes', nogenerate
	drop series
	rename concept codelist
	save `concept', replace

	forvalues i=1/`position_nb' {
		use `dimensionsDSD' if position==`i', clear
		merge 1:m codelist using `concept', nogenerate keep(3)
		tempfile dim`i'
		save `dim`i'', replace
	}
	use `dim1', clear
	forvalues i=2/`position_nb' {
		append using `dim`i''
	}
	replace codelist=concept if codelist!=concept & concept!=""
	drop concept
	rename codelist concept
	if "`provider'"=="IMF" | "`provider'"=="OECD" {
		replace concept=subinstr(concept, "`datasetDSD'_", "", 1)	
	}
	if "`provider'"=="WB" {
		replace concept=subinstr(concept, "_`datasetDSD'", "", 1)	
	}
	order position, after(concept)
	sort position concept code

	// Erase text file with raw data

	cap erase tmp_sdmxdatastructure.txt
	cap erase codelists.txt
	
	// Save DSD to merge with data
	
	if "`mergedsd'"!="" {
		levelsof concept, clean
		local concepts_list="`r(levels)'"
		foreach concept of local concepts_list {
			preserve
			keep if concept=="`concept'"
			keep code code_lbl
			local concept2=strlower("`concept'")
			rename code* `concept2'*
			compress
			tempfile dsd_`concept2'
			save `dsd_`concept2'', replace
			restore
		}
	}
}

/***********************************************************************
Data
************************************************************************/

if "`resource'"=="data" {

	// Build and send query

	local detail "dataonly"
	if "`attributes'"!="" {
		local detail "full"
	}
	if "`dimensions'"!="" {
		local dimensions "/`dimensions'"
	}
	if "`provider'"=="ECB" | "`provider'"=="ESTAT" | "`provider'"=="UNSD" {
		copy "`url'data/`dataset'`dimensions'/all/?detail=`detail'`start'`end'" tmp_sdmxfile.txt, replace
	}
	if "`provider'"=="IMF" {
		copy "`url'CompactData/`dataset'`dimensions'/?&detail=`detail'`start'`end'" tmp_sdmxfile.txt, replace
	}
	if "`provider'"=="OECD" {
		copy "`url'GetData/`dataset'`dimensions'/all?&detail=`detail'`start'`end'" tmp_sdmxfile.txt, replace
	}
	if "`provider'"=="WB" {
		copy "`url'v2/data/`dataset'`dimensions'/?&detail=`detail'`start'`end'" tmp_sdmxfile.txt, replace
	}

if "`provider'"!="IMF" {
	
	// Import data (generic format) into Stata

	filefilter tmp_sdmxfile.txt tmp_sdmxfile2.txt, from("\n") to ("") replace
	erase tmp_sdmxfile.txt
	`renamecmd' tmp_sdmxfile2.txt tmp_sdmxfile.txt
	filefilter tmp_sdmxfile.txt tmp_sdmxfile2.txt, from("\r") to ("") replace
	erase tmp_sdmxfile.txt
	`renamecmd' tmp_sdmxfile2.txt tmp_sdmxfile.txt
	filefilter tmp_sdmxfile.txt tmp_sdmxfile2.txt, from("<`prefix'Obs>") to ("\r\n<`prefix'Obs>") replace
	erase tmp_sdmxfile.txt
	`renamecmd' tmp_sdmxfile2.txt tmp_sdmxfile.txt
	filefilter tmp_sdmxfile.txt tmp_sdmxfile2.txt, from("<`prefix'Series>") to ("\r\n<`prefix'Series>") replace
	erase tmp_sdmxfile.txt
	`renamecmd' tmp_sdmxfile2.txt tmp_sdmxfile.txt
	import delimited tmp_sdmxfile.txt, clear delimiters("|||", asstring) rowrange(2) varnames(nonames)
	if "`provider'"!="ESTAT"  {
		count
		if r(N)==0  {
			noisily display in red "The query did not match any time series - check again the dimensions' values or download the full dataset"
			cap erase tmp_sdmxfile.txt
			exit
		}
	}
	* ESTAT's query limitation
	if "`provider'"=="ESTAT"  {
		count
		if r(N)==0 {
			import delimited tmp_sdmxfile.txt, clear delimiters("|||", asstring) varnames(nonames)
			if regexm(v1, "Query size exceeds maximum") {
				noisily di in red "Query size exceeds maximum limit set by Eurostat: 1,000,000 entries - Try to refine the query by using the option [, dimensions()]"
				cap erase tmp_sdmxfile.txt
				exit
			}
			if regexm(v1, "Due to the large query the response") {
				_moss v1, match(`"<common:Text xml:lang="en">http://ec.europa.eu/eurostat/SDMX/diss-web/file/(.*)</common:Text><common:Text xml:lang="en">"') regex
				rename _match1 estat_url
				local estat_url=estat_url[1]
				noisily di in green "Due to the large query (above 30,000 cells), Eurostat will post the file to a different repository - the processing of the file may take up to 5 minutes"
				sleep 100000
				cap copy  "http://ec.europa.eu/eurostat/SDMX/diss-web/file/`estat_url'" estat_bigdataflow.zip, replace
				cap confirm file "estat_bigdataflow.zip"
				if _rc {
					sleep 100000
					copy  "http://ec.europa.eu/eurostat/SDMX/diss-web/file/`estat_url'" estat_bigdataflow.zip, replace
					cap confirm file "estat_bigdataflow.zip"
						if _rc {
							sleep 100000
							copy  "http://ec.europa.eu/eurostat/SDMX/diss-web/file/`estat_url'" estat_bigdataflow.zip, replace
							cap confirm file "estat_bigdataflow.zip"
						}
							if _rc {
								sleep 100000
								copy  "http://ec.europa.eu/eurostat/SDMX/diss-web/file/`estat_url'" estat_bigdataflow.zip, replace
								cap confirm file "estat_bigdataflow.zip"
							}
								if _rc {
									sleep 100000
									copy  "http://ec.europa.eu/eurostat/SDMX/diss-web/file/`estat_url'" estat_bigdataflow.zip, replace
									cap confirm file "estat_bigdataflow.zip"
								}
				}
				unzipfile estat_bigdataflow.zip, replace
				erase estat_bigdataflow.zip
				cap erase tmp_sdmxfile.txt
				`renamecmd' "DataResponse-`estat_url'.xml" "tmp_sdmxfile.txt"
				filefilter tmp_sdmxfile.txt tmp_sdmxfile2.txt, from("\n") to ("") replace
				erase tmp_sdmxfile.txt
				`renamecmd' tmp_sdmxfile2.txt tmp_sdmxfile.txt
				filefilter tmp_sdmxfile.txt tmp_sdmxfile2.txt, from("\r") to ("") replace
				erase tmp_sdmxfile.txt
				`renamecmd' tmp_sdmxfile2.txt tmp_sdmxfile.txt
				filefilter tmp_sdmxfile.txt tmp_sdmxfile2.txt, from("<`prefix'Obs>") to ("\r\n<`prefix'Obs>") replace
				erase tmp_sdmxfile.txt
				`renamecmd' tmp_sdmxfile2.txt tmp_sdmxfile.txt
				filefilter tmp_sdmxfile.txt tmp_sdmxfile2.txt, from("<`prefix'Series>") to ("\r\n<`prefix'Series>") replace
				erase tmp_sdmxfile.txt
				`renamecmd' tmp_sdmxfile2.txt tmp_sdmxfile.txt
				import delimited tmp_sdmxfile.txt, clear delimiters("|||", asstring) rowrange(2) varnames(nonames)
			}
			else {
				noisily display in red "The query did not match any time series - check again the dimensions' values or download the full dataset"
				cap erase tmp_sdmxfile.txt
				exit
			}
		}
	}
	
	// Format dataset
	
	tempfile data
	gen series=regexm(v1, "SeriesKey")
	replace series=sum(series)
	sum series
	noisily display in green "`r(max)' serie(s) imported"
	preserve
	drop if !regexm(v1, "Obs")

	* Time
	if "`provider'"=="OECD" | "`provider'"=="WB" {
		local strsize=strlen("<`prefix'Time>")
		gen time=substr(v1, strpos(v1, "<`prefix'Time>")+`strsize', strpos(v1, "</`prefix'Time>")-strpos(v1, "<`prefix'Time>")-`strsize')
	}
	if "`provider'"=="ECB" | "`provider'"=="ESTAT"  {
		local strsize=strlen("<`prefix'ObsDimension value=")+1
		gen time=substr(substr(v1, strpos(v1, "<`prefix'ObsDimension value=")+`strsize', .), 1, strpos(substr(v1, strpos(v1, "<`prefix'ObsDimension value=")+`strsize', .), `"""')-1)
	}
	if "`provider'"=="UNSD"  {
		local strsize=strlen("<`prefix'ObsDimension id=")+1
		gen time=substr(substr(substr(v1, strpos(v1, "<`prefix'ObsDimension id=")+`strsize', .), 1, strpos(substr(v1, strpos(v1, "<`prefix'ObsDimension id=")+`strsize', .), `"/>"')-3), strpos(substr(substr(v1, strpos(v1, "<`prefix'ObsDimension id=")+`strsize', .), 1, strpos(substr(v1, strpos(v1, "<`prefix'ObsDimension id=")+`strsize', .), `"/>"')-3), "value=")+7, .)
	}

	* Values
	local strsize=strlen("<`prefix'ObsValue value=")+1
	gen value=substr(substr(v1, strpos(v1, "<`prefix'ObsValue value=")+`strsize', .), 1, strpos(substr(v1, strpos(v1, "<`prefix'ObsValue value=")+`strsize', .), `"""')-1)
	replace value="" if value=="NaN"
	destring value, replace
	char value[destring]
	char value[destring_cmd]

	* Attributes
	if "`attributes'"!="" {
		tempvar Attributes
		local strsize=strlen("<`prefix'Attributes>")
		gen `Attributes'=substr(substr(v1, strpos(v1, "<`prefix'Attributes>")+`strsize',.), 1, strpos(substr(v1, strpos(v1, "<`prefix'Attributes>")+`strsize',.), "</`prefix'Attributes>")-1)
		capture assert missing(`Attributes')
		if _rc {
			_moss `Attributes', match(`"`value_id'"([a-zA-Z0-9_]+)""') regex
			sum _count
			local macroconcept ""
			forvalues i=1/`r(max)' {
				levelsof _match`i', clean
				local macroconcept="`macroconcept' `r(levels)'"
			}
			local macroconceptuniq : list uniq macroconcept
			foreach var of local macroconceptuniq {
				gen `var'=substr(substr(`Attributes', strpos(`Attributes', `""`var'""'), .), strpos(substr(`Attributes', strpos(`Attributes', `""`var'""'), .), "value=")+7, strpos(substr(substr(`Attributes', strpos(`Attributes', `""`var'""'), .), strpos(substr(`Attributes', strpos(`Attributes', `""`var'""'), .), "value=")+7, .), `"""')-1)
			}
			drop _*
		}
	}
	drop v1
	save `data', replace

	// Separate dimensions

	restore
	drop if regexm(v1, "Obs")

	* Values
	tempvar SeriesKey
	local strsize=strlen("<`prefix'SeriesKey>")
	gen `SeriesKey'=substr(substr(v1, strpos(v1, "<`prefix'SeriesKey>")+`strsize',.), 1, strpos(substr(v1, strpos(v1, "<`prefix'SeriesKey>")+`strsize',.), "</`prefix'SeriesKey>")-1)
	_moss `SeriesKey', match(`"`value_id'"([a-zA-Z0-9_]+)""') regex
	sum _count
	local macroconcept ""
	forvalues i=1/`r(max)' {
		levelsof _match`i', clean
		local macroconcept="`macroconcept' `r(levels)'"
	}
	local macroconceptuniq : list uniq macroconcept
	foreach var of local macroconceptuniq {
		gen `var'=substr(substr(`SeriesKey', strpos(`SeriesKey', `""`var'""'), .), strpos(substr(`SeriesKey', strpos(`SeriesKey', `""`var'""'), .), "value=")+7, strpos(substr(substr(`SeriesKey', strpos(`SeriesKey', `""`var'""'), .), strpos(substr(`SeriesKey', strpos(`SeriesKey', `""`var'""'), .), "value=")+7, .), `"""')-1)
	}
	drop _*
}
	

if "`provider'"=="IMF" {

	// Import data (only compact format available) into Stata

	filefilter tmp_sdmxfile.txt tmp_sdmxfile2.txt, from("\n") to ("") replace
	erase tmp_sdmxfile.txt
	`renamecmd' tmp_sdmxfile2.txt tmp_sdmxfile.txt
	filefilter tmp_sdmxfile.txt tmp_sdmxfile2.txt, from("\r") to ("") replace
	erase tmp_sdmxfile.txt
	`renamecmd' tmp_sdmxfile2.txt tmp_sdmxfile.txt
	filefilter tmp_sdmxfile.txt tmp_sdmxfile2.txt, from("<`prefix'Obs") to ("\r\n<`prefix'Obs") replace
	erase tmp_sdmxfile.txt
	`renamecmd' tmp_sdmxfile2.txt tmp_sdmxfile.txt
	filefilter tmp_sdmxfile.txt tmp_sdmxfile2.txt, from("<`prefix'Series") to ("\r\n<`prefix'Series") replace
	erase tmp_sdmxfile.txt
	`renamecmd' tmp_sdmxfile2.txt tmp_sdmxfile.txt
	import delimited tmp_sdmxfile.txt, clear delimiters("|||", asstring) rowrange(2) varnames(nonames)
	
	// Format dataset
	
	tempfile data
	gen series=regexm(v1, "<Series")
	replace series=sum(series)
	sum series
	noisily display in green "`r(max)' serie(s) imported"
	preserve
	drop if !regexm(v1, "<Obs")

	* Time
	_moss v1, match(`"TIME_PERIOD="([a-zA-Z0-9_-]+)""') regex max(1)
	rename _match1 time
	drop _*

	* Values
	_moss v1, match(`"OBS_VALUE="([a-zA-Z0-9.]+)""') regex max(1)
	rename _match1 value
	drop _*	
	destring value, replace
	char value[destring]
	char value[destring_cmd]

	drop v1
	save `data', replace

	// Separate dimensions

	restore
	drop if regexm(v1, "<Obs")

	* Values
	
	_moss v1, match(`" ([a-zA-Z0-9_]+)="') regex
	rename _* *
	drop count pos*
	_moss v1, match(`"="([a-zA-Z0-9_]+)""') regex
	
	sum _count
	local nb_dim=r(max)
	local macroconcept ""
	forvalues i=1/`nb_dim' {
		levelsof match`i', clean
		local macroconcept="`macroconcept' `r(levels)'"
	}
	local macroconceptuniq : list uniq macroconcept
	foreach var of local macroconceptuniq {
		gen `var'=""
		forvalues i=1/`nb_dim' {
			replace `var'=_match`i' if match`i'=="`var'"
		}
	}
	drop _* match*	
}

	* Create variable serieskey if dataset needs to be reshaped
	
	if "`timeseries'"!="" {
		foreach var of varlist `macroconceptuniq' {
			bysort `var': gen nvals = _n == 1 
			replace nvals = sum(nvals)
			if nvals[_N]==1 {
				local macroconceptuniq : subinstr local macroconceptuniq "`var'" ""
			}
			drop nvals
		}
		local blank : subinstr local macroconceptuniq " " "", all
		if "`blank'"!="" {
			egen serieskey=concat(`macroconceptuniq'), punct("_")
			replace serieskey=lower(serieskey)
			replace serieskey=subinstr(serieskey, "-", "_", .)
			order serieskey
			gen length=strlen(serieskey)
			sum length
			local maxlength=r(max)
			if `maxlength'>32 {
				drop serieskey length
				gen serieskey=series
				tostring serieskey, replace
			}
		}
	}
	if "`panel'"!="" {
		capture confirm variable `panel'
		if _rc {
			local panel=strupper("`panel'")
			capture confirm variable `panel'
			if _rc {
				noisily di in red "Variable `panel' not found"
				cap erase tmp_sdmxfile.txt
				exit				
			}
		}
		local nogeo : subinstr local macroconceptuniq "`panel'" ""
		foreach var of varlist `nogeo' {
			bysort `var': gen nvals = _n == 1 
			replace nvals = sum(nvals)
			if nvals[_N]==1 {
				local nogeo : subinstr local nogeo "`var'" ""
			}
			drop nvals
		}
		local blank : subinstr local nogeo " " "", all
		if "`blank'"!="" {
			egen serieskey=concat(`nogeo'),  maxlength(32) punct("_")
			replace serieskey=lower(serieskey)
			replace serieskey=subinstr(serieskey, "-", "_", .)
			order serieskey
			gen length=strlen(serieskey)
			sum length
			local maxlength=r(max)
			if `maxlength'>32 {
				drop serieskey length
				gen serieskey=series
				tostring serieskey, replace
			}
		}
		local panel=strlower("`panel'")
	}

	if "`attributes'"=="" {
		drop v1
	}

	* Attributes
	if "`attributes'"!="" {
		tempvar Attributes2
		local strsize=strlen("<`prefix'Attributes>")
		gen `Attributes2'=substr(substr(v1, strpos(v1, "<`prefix'Attributes>")+`strsize',.), 1, strpos(substr(v1, strpos(v1, "<`prefix'Attributes>")+`strsize',.), "</`prefix'Attributes>")-1)
		capture assert missing(`Attributes2')
		if _rc {
			_moss `Attributes2', match(`"`value_id'"([a-zA-Z0-9_]+)""') regex
			sum _count
			local macroconcept ""
			forvalues i=1/`r(max)' {
				levelsof _match`i', clean
				local macroconcept="`macroconcept' `r(levels)'"
			}
			local macroconceptuniq : list uniq macroconcept
			foreach var of local macroconceptuniq {
				gen `var'=substr(substr(`Attributes2', strpos(`Attributes2', `""`var'""'), .), strpos(substr(`Attributes2', strpos(`Attributes2', `""`var'""'), .), "value=")+7, strpos(substr(substr(`Attributes2', strpos(`Attributes2', `""`var'""'), .), strpos(substr(`Attributes2', strpos(`Attributes2', `""`var'""'), .), "value=")+7, .), `"""')-1)
			}
			drop _*
		}
		drop v1
	}

	// Merge data and dimensions' identifiers

	merge 1:m series using `data', nogenerate
	drop series
	rename _all, lower
	
	// Merge with DSD
	
	if "`mergedsd'"!="" {
		ds time value, not
		local varlist="`r(varlist)'"
		if "`provider'"=="WB" {
			ds freq time value, not
			local varlist="`r(varlist)'"
		}
		foreach var of local varlist {
			merge m:1 `var' using `dsd_`var'', nogenerate keep(1 3)
			order `var'_lbl, after(`var')
		}
		compress
	}

	// Reshape dataset
	
	if "`timeseries'"!="" {
		if "`blank'"!="" {
			keep serieskey time value
			reshape wide value, i(time) j(serieskey, string)
			if `maxlength'>32 {
				order time value*, sequential
			}
			cap rename value* *
		}
		sort time
	}
	
	if "`panel'"!="" {
		if "`blank'"!="" {
			keep serieskey time value `panel'
			reshape wide value, i(time `panel') j(serieskey, string)
			if `maxlength'>32 {
				order `panel' time value*, sequential
			}
			cap rename value* *
		}
		sort `panel' time
	}
		
	// Erase text file with raw data

	cap erase tmp_sdmxfile.txt

	}
}

end

/*******************************************************************************	

	SDMXUSE requires the package "moss" by Robert Picard & Nicholas J. Cox to 
	deal with multiple occurrences of substrings
	
	The authors kindly allowed me to reproduce their code below so that
	users don't have to install both packages

*******************************************************************************/

program _moss

	version 9
	
	syntax varname(string) [if] [in] , ///
	Match(string) ///
	[ ///
	Regex ///
	Prefix(string) ///
	Suffix(string) ///
	MAXimum(string) ///
	Compact ///
	Unicode ///
	]
	
	
	if "`unicode'" != "" {
		if c(stata_version) < 14 {
			dis as err "Unicode support requires Stata version 14 or higher"
			exit 198
		}
		local u u
		local ustr ustr
		local matchlen : ustrlen local match
	}
	else local matchlen : length local match 
	
	if `matchlen' == 0 {
		dis as err "empty string found in match option: " ///
			"nothing to match"
		exit 198
	}
	
	
	if "`prefix'" != "" & "`suffix'" != "" {
		dis as err "prefix and suffix options cannot be combined"
		exit 198
	}
	if "`prefix'`suffix'" == "" local prefix _
	if "`prefix'" != "" {
		capture confirm name `prefix'
		if _rc {
			dis as err "prefix(`prefix') option will yield invalid variable names"
			exit _rc
		}
	}
	
	
	if "`maximum'" != "" {
		capture confirm integer number `maximum'
		if _rc {
			dis as err "integer expected for maximum option"
			exit _rc
		}
		capture assert `maximum' > 0
		if _rc {
			dis as err "maximum must be > 0"
			exit 198
		}
	}
	else local maximum .
	
	
	if "`regex'" != "" {
		// prior to version 13, regexs() trims leading spaces!
		// add a ? character while we parse the pattern
		local match0 `"`match'"'
		local match `"?`match0'"'
		
		// remove escaped parentheses to check the subexpression
		local checkit : subinstr local match "\)" "", all
		local checkit : subinstr local checkit "\(" "", all
		
		if !regexm(`"`checkit'"',"\(.*\)") {
			dis as err "regex option: " ///
				`"no subexpression in match(`match0')"'
			exit 198
		}
		if regexm(`"`checkit'"',"\((.*)\)") local subex = regexs(1)
		if regexm(`"`subex'"',"[()]") {
			dis as err "regex option: " ///
				`"match(`match0') can only contain one subexpression"'
			exit 198
		}
		
		// split match at the end of the subexpression
		if regexm(`"`match'"', "(.*[^\\]\))") local match1 = regexs(1)
		local match2 = regexr(`"`match'"', ".*[^\\]\)", "")
		
		// recombine the pattern with a second subexpression that will capture
		// what comes just after the matched subexpression
		local match `"`match1'(`match2'.*)"'
		
		// remove the leading ? character added because of bug in regexs()
		local match : subinstr local match "?" ""
	}
	

	quietly { 
	
		marksample touse, strok
		count if `touse'
		if r(N) == 0 error 2000 

		tempvar copy count varlen
		clonevar `copy' = `varlist' 
		gen long `count' = 0 if `touse'
		gen long `varlen' = `u'strlen(`copy')
		
		local j = 0 
		local more 1
		
		
		while `more' {
		
			local ++j
			tempvar pos`j'
			
			if "`regex'" != "" {
				tempvar match`j'
				gen `match`j'' = `ustr'regexs(1) if `touse' & ///
					`ustr'regexm(`copy',`"`match'"')
				replace `touse' = 0 if `match`j'' == ""
				replace `copy' = `ustr'regexs(2) if `touse' & ///
					`ustr'regexm(`copy',`"`match'"')
				gen long `pos`j'' = `varlen' - ///
					`u'strlen(`copy') - `u'strlen(`match`j'') + 1 if `touse'
			}
			else {
				capture gen long `pos`j'' = `u'strpos(`copy',`"`match'"') if `touse'
				if _rc { 
					gen long `pos`j'' = `u'strpos(`copy',"`match'") if `touse'
				}
				replace `touse' = 0 if `pos`j'' == 0
				replace `pos`j'' = . if `pos`j'' == 0
				replace `copy' = `u'substr(`copy', ///
					`pos`j''+`matchlen',.) if `touse'
				replace `pos`j'' = ///
					`varlen' - `u'strlen(`copy') - `matchlen' + 1 if `touse'
			}

			replace `count' = `count' + 1 if `touse'				
			compress `pos`j''
				
			count if `touse'
			if r(N) == 0 {
				local --j
				local more 0
			}
			else if `j' == `maximum' local more 0
			
		}

		
		compress `count'
		if "`prefix'" != "" {
			cap confirm new var `prefix'count
			if _rc {
				dis as err "variable `prefix'count already defined: " ///
					"change prefix(`prefix') option"
				error _rc
			}
			rename `count' `prefix'count
			forvalues i = 1/`j' {
				cap confirm new var `prefix'pos`i'
				if _rc {
					dis as err "variable `prefix'pos`i' already defined: " ///
						"change prefix(`prefix') option"
					error _rc
				}
				rename `pos`i'' `prefix'pos`i'
				if "`regex'" != "" rename `match`i'' `prefix'match`i'
			}
		}
		else {
			cap confirm new var count`suffix'
			if _rc {
				dis as err "variable count`suffix' already defined: " ///
					"change suffix(`suffix') option"
				error _rc
			}
			rename `count' count`suffix'
			forvalues i = 1/`j' {
				cap confirm new var pos`i'`suffix'
				if _rc {
					dis as err "variable pos`i'`suffix' already defined: " ///
						"change suffix(`suffix') option"
					error _rc
				}
				rename `pos`i'' pos`i'`suffix'
				if "`regex'" != "" rename `match`i'' match`i'`suffix'
			}
		}
	}
end

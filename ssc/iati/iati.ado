*! v1.0 09Feb2016 - Liam Swiss, Memorial University: @liamswiss lswiss@mun.ca*

program iati
	version 14
	syntax anything [, fy(real 4)]

		set more off
		clear all

		di as text "{hline 59}"
		di "Importing Activity Data from IATI Datastore"


quietly{
		tempfile temp
		capture: copy "http://datastore.iatistandard.org/api/1/access/activity.csv?reporting-org.ref=`anything'&stream=True" `temp'
		cap : insheet using `temp', name
}
		di as text "{hline 59}"
		di "Converting IATI Data to Stata Format"
		di as text "{hline 59}"
	
quietly{
		ds, not(type string)
		foreach varname of varlist `r(varlist)' {
			quietly sum `varname'
			if `r(N)'==0 {
				drop `varname'
			}
		}
		
		capture gen defaultaidtypecode=""
		capture gen reportingorgref=""

		foreach var of varlist defaultaidtypecode{
			rename `var' tempvar
			encode tempvar, gen(newvar)
			drop tempvar
			rename newvar `var'
		}

		
		capture confirm variable activitystatuscode 
		if _rc == 0 {
						capture destring activitystatuscode, replace force
						label define status 1 "Pipeline/identification" 2 "Implementation" 3 "Completion" 4 "Post-Completion" 5 "Cancelled" 6 "Suspended"
						label val activitystatuscode status
		}

		capture confirm variable startactual 
		if _rc == 0 {
						gen start = date(startactual, "YMD")
						format start %td
						drop startactual
						rename start startactual
						gen startmonth=month(startactual)
						gen startyear=year(startactual)		
						gen fystart=startyear
						replace fystart=fystart-1 if startmonth<`fy'
						gen fysplus=fystart+1
						gen fysstr=string(fystart)
						gen fysstr1=string(fysplus)
				
		}


		capture confirm variable endactual 
		if _rc == 0 {
						gen end = date(endactual, "YMD")
						format end %td
						drop endactual
						rename end endactual
						gen endmonth=month(endactual)
						gen endyear=year(endactual)
						gen fyend=endyear
						replace fyend=fyend-1 if endmonth<`fy'
						gen fyeplus=fyend+1
						gen fyestr=string(fyend)
						gen fyestr1=string(fyeplus)

		}
				
		

		capture{
		gen fystart_cat=fysstr+"-"+fysstr1
		encode fystart_cat, gen(fysc)
		drop fystart_cat
		rename fysc fystart_cat
		gen fyend_cat=fyestr+"-"+fyestr1
		encode fyend_cat, gen(fyec)
		drop fyend_cat
		rename fyec fyend_cat
		}

		capture drop fysplus fyeplus fysstr fyestr fysstr1 fyestr1

				capture label var iatiidentifier 	"IATI Identifier"
				capture label var hierarchy 	"Hierarchy"
				capture label var lastupdateddatetime 	"Last Updated Datetime"
				capture label var defaultlanguage 	"Default Language"
				capture label var reportingorg 	"Reporting Org"
				capture label var reportingorgref 	"Reporting Org IATI ID"
				capture label var reportingorgtype 	"Reporting Org Type"
				capture label var reportingorgtypecode 	"Reporting Org Type Code"
				capture label var title    	"Title"
				capture label var description 	"Description"
				capture label var activitystatuscode 	"Activity Status Code"
				capture label var startplanned 	"Start Planned"
				capture label var endplanned 	"End Planned"
				capture label var startactual 	"Start Actual"
				capture label var endactual 	"End Actual"
				capture label var participatingorgaccountable 	"Participating Org (Accountable)"
				capture label var participatingorgrefaccountable 	"Participating Org Ref (Accountable)"
				capture label var participatingorgtypeaccountable 	"Participating Org Type (Accountable)"
				capture label var participatingorgtypecodeaccounta 	"Participating Org Type Code (Accountable)"
				capture label var participatingorgfunding 	"Participating Org (Funding)"
				capture label var participatingorgreffunding 	"Participating Org Ref (Funding)"
				capture label var participatingorgtypefunding 	"Participating Org Type (Funding)"
				capture label var participatingorgtypecodefunding 	"Participating Org Type Code (Funding)"
				capture label var participatingorgextending 	"Participating Org (Extending)"
				capture label var participatingorgrefextending 	"Participating Org Ref (Extending)"
				capture label var participatingorgtypeextending 	"Participating Org Type (Extending)"
				capture label var participatingorgtypecodeextendin 	"Participating Org Type Code (Extending)"
				capture label var participatingorgimplementing 	"Participating Org (Implementing)"
				capture label var participatingorgrefimplementing 	"Participating Org Ref (Implementing)"
				capture label var participatingorgtypeimplementing 	"Participating Org Type (Implementing)"
				capture label var participatingorgtypecodeimplemen 	"Participating Org Type Code (Implementing)"
				capture label var recipientcountrycode 	"Recipient Country Code"
				capture label var recipientcountry 	"Recipient Country"
				capture label var recipientcountrypercentage 	"Recipient Country Percentage"
				capture label var recipientregioncode 	"Recipient Region Code"
				capture label var recipientregion 	"Recipient Region"
				capture label var recipientregionpercentage 	"Recipient Region Percentage"
				capture label var sectorcode 	"Sector Code"
				capture label var sector   	"Sector"
				capture label var sectorpercentage 	"Sector Percentage"
				capture label var sectorvocabulary 	"Sector Vocabulary"
				capture label var sectorvocabularycode 	"Sector Vocabulary Code"
				capture label var collaborationtypecode 	"Collaboration Type Code"
				capture label var defaultfinancetypecode 	"Default Finance Type Code"
				capture label var defaultflowtypecode 	"Default Flow Type Code"
				capture label var defaultaidtypecode 	"Default Aid Type Code"
				capture label var defaulttiedstatuscode 	"Default Tied Status Code"
				capture label var defaultcurrency 	"Default Currency"
				capture label var currency 	"Currency"
				capture label var totalcommitment 	"Total Commitment (CAD)"
				capture label var totaldisbursement 	"Total Disbursement (CAD)"
				capture label var totalexpenditure 	"Total Expenditure (CAD)"
				capture label var totalincomingfunds 	"Total Incoming Funds (CAD)"
				capture label var totalinterestrepayment 	"Total Interest Repayment (CAD)"
				capture label var totalloanrepayment 	"Total Loan Repayment (CAD)"
				capture label var totalreimbursement 	"Total Reimbursement (CAD)"
				capture label var startmonth "Start Month"
				capture label var startyear "Start Year"
				capture label var endmonth "End Month"
				capture label var endyear "End Year"
				capture label var fystart "Starting Fiscal Year"
				capture label var fyend "Ending Fiscal Year"
				capture label var fystart_cat "FY Start - Categorical"
				capture label var fyend_cat "FY End - Categorical"

	}


local c_date = c(current_date)
local c_date = subinstr("`c_date'", " ", "_", .)

di "Saving Stata Dataset: IATI_`anything'`c_date'.dta "

save IATI_`anything'`c_date'.dta, replace
di as text "{hline 59}"

end

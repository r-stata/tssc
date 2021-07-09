*! Ado file for using Google Places API with a verified API key
*! Taylor Crockett, Research Assistant
*! Stephen Barnes, Director
*! Chris Schmidt, Assistant Director 
*! LSU Economics & Policy Research Group
*! Date 7/27/16
*! Requires Stata Version 13 or later
program googleplaces
	version 13.0
	syntax [varlist] [in/], [apikey(string asis) textsearch nearbysearch radius(string asis) type(string asis) keyword(string asis) results(integer 1) advanced cleanup]
	
	quietly {
		* Check for insheetjson and libsjson
			cap which insheetjson
			if _rc == 111 noisily dis as text "Insheetjson.ado not found, please ssc install insheetjson"
			cap which libjson.mlib
			if _rc == 111 noisily dis as text "Libjson.mlib not found, please ssc install libjson"
			if _rc == 111 assert 1==2	
	
	* This is where textsearch starts
		if "`textsearch'" != "" {
			*create variable to keep observations in order
			local totl = _N 	
			cap gen originalid = ""
			forval i = 1/`totl' {
			replace originalid = "`i'" in `i'
			}
			destring originalid, replace
		
	* If [in] condition is not specified, initialize macro
		if "`in'" == "" local in "1/`totl'"

		*Save the original variables before we create a bunch of new ones so we can use them later on.
			ds
			local originalvars `r(varlist)'
				
		*Create all temp files/variables and needed variables
			tempfile apiresult
			tempfile apiresult2
			capture confirm variable g_queryID
				if _rc {
					cap gen str10 g_queryID = ""
						}
						else  {
							tostring g_queryID, replace
							}
			capture confirm variable g_status
				if _rc {
					cap gen str24 g_status = ""
						}
			capture confirm variable g_placeid
				if _rc {
					cap gen str64 g_placeid = ""
						}
		*Depending on which options the user chooses, generate the other required temp variables
			capture confirm variable g_name
				if _rc {
					cap gen str60 g_name = ""
						}
			capture confirm variable g_lat
				if _rc {
					cap gen str30 g_lat = ""
						}
						else  {
							tostring g_lat, replace force
							}
			capture confirm variable g_lng
				if _rc {
					cap gen str30 g_lng = ""
						}
						else  {
							tostring g_lng, replace force
							}
			capture confirm variable g_address
				if _rc {
					cap gen str90 g_address = ""			
						}
			if "`advanced'" == "advanced" {
			capture confirm variable g_phonenum
				if _rc {
					cap gen str40 g_phonenum ="" 
						}
			capture confirm variable g_price
				if _rc {
					cap gen str10 g_price =""
						}
			capture confirm variable g_rating
				if _rc {
					cap gen str10 g_rating =""
						}
			capture confirm variable g_website
				if _rc {
					cap gen str100 g_website =""
						}
			
			}	// end 'if' advanced		
		
		*Count the number of variables in the varlist, then run loop to combine the variables while leaving a blank space between each variable
			local varcountt = wordcount("`varlist'")
			tokenize `varlist'
			cap gen g_search1=`1'
			forvalues i = 2(1)`varcountt' {
		
				local p = `i'-1
				cap gen g_search`i'=g_search`p'+" "+``i''
				cap drop g_search`p'
				
				}  // close forvalues
									
			local csearch="g_search`varcountt'"
				
			
		*Make sure that there are no spaces or special characters in the addresses	
			cap assert strpos(`csearch'," ") == 0
			if _rc == 9 {
			replace `csearch' = subinstr(`csearch', " ", "+",.)
			}
				
			cap assert strpos(`csearch',"%") == 0
			if _rc == 9 {
			replace `csearch' = subinstr(`csearch', "%", "+",.)
			}
			
			cap assert strpos(`csearch',"#") == 0
			if _rc == 9 {
			replace `csearch' = subinstr(`csearch', "#", "+",.)
			}
			
			cap assert strpos(`csearch',"@") == 0
			if _rc == 9 {
			replace `csearch' = subinstr(`csearch', "@", "+",.)
			}
			
		*Here is the main search method, and modifications to what information is pulled need to happen wihtin the forval command	
	
			forval i = `in' { 
				local srch = `csearch'[`i']
				local offset = _N
				local status = `offset'+1				
				
			
				// queryID stuff
					replace g_queryID = "`i'" in `i'
					
				// Indicator to track the progress of the search
					local pos = strpos("`in'","/")+1
					local totlcount = substr("`in'",`pos',.)
					noisily di as text "Searching google for `i' of `totlcount' requested searches" 
					
				*Queries google for the given observation and returns the results into the tempfile
					capture copy "https://maps.googleapis.com/maps/api/place/textsearch/json?query=`srch'&key=`apikey'" `apiresult'.json , replace
										
						
				/*use insheetjson to extract data from temp file.  Depending on which options the user choosed, different data is extracted. */
					
					capture: insheetjson g_status using `apiresult'.json , table("status") col("status") limit(`results') offset(`offset') replace
					replace g_status = g_status[`status'] in `i'
					capture: insheetjson g_placeid using `apiresult'.json , table("results") col("place_id") limit(`results') offset(`offset') replace	
							
						capture: insheetjson g_name using `apiresult'.json , table("results") col("name") limit(`results') offset(`offset') replace
						replace g_name = g_name[`status'] in `i'
						
						capture: insheetjson g_address using `apiresult'.json , table("results") col("formatted_address") limit(`results') offset(`offset') replace
						replace g_address = g_address[`status'] in `i'
						
						capture: insheetjson g_lat g_lng using `apiresult'.json , table("results") col("geometry:location:lat" "geometry:location:lng") limit(`results') offset(`offset') replace
						replace g_lat = g_lat[`status'] in `i'
						replace g_lng = g_lng[`status'] in `i'
							
							
					*  Create some needed variables to fill in the g_queryID variable and to do the instant debug notifier
						local finaln = _N
					
					*  Fill in the queryID number for all results pulled by the search
						replace g_queryID = "`i'" in `status'/`finaln'
						
					*  Fill in the g_status variable for all the results
						replace g_status = g_status[`i'] in `status'/`finaln'
						
					*  Fill in the original data in all the blank space
						foreach t of local originalvars {
							replace `t' = `t'[`i'] in `status'/`finaln'
							}
				
					*An insta-debug notifier that will notify the user if the search for that particular obeservation failed
					*Please refer to the g_status variable for the actual error code related to said observation
						cap assert g_status == "OK" in `status'
						if _rc == 9 noisily di as text "Return code was not OK"		
			
				
				if "`advanced'" == "advanced" {
				*Now we run the Detail search loop.  Information will then be pulled from the detail search if the options were detected
					forval p = `status'/`finaln'{
					local offset2 = `p'-1
					local searchid = g_placeid[`p']
					
					*capture the detail search results using the google place ID
					capture copy "https://maps.googleapis.com/maps/api/place/details/json?placeid=`searchid'&key=`apikey'" `apiresult2'.json , replace
			
					/*Use insheetjson to grab the phonenumber.  Please notice that the g_status variable is not overwritten by this search, so
					if there is	an error with this search, the specific error code will not be recorded.	*/
					
						capture: insheetjson g_phonenum using `apiresult2'.json , table("result") col("formatted_phone_number") limit(1) offset(`offset2') replace
						replace g_phonenum = g_phonenum[`status'] in `i'
						
						capture: insheetjson g_price using `apiresult2'.json , table("result") col("price_level") limit(1) offset(`offset2') replace
						replace g_price = g_price[`status'] in `i'
						
						capture: insheetjson g_rating using `apiresult2'.json , table("result") col("rating") limit(1) offset(`offset2') replace
						replace g_rating = g_rating[`status'] in `i'
						
						capture: insheetjson g_website using `apiresult2'.json , table("result") col("website") limit(1) offset(`offset2') replace
						replace g_website = g_website[`status'] in `i'
						
					
							} // close detail search forval
						} // close if advanced
				
					*get rid of the duplicate variable
					drop in `status'/`status'
				
				* delay loop
				//sleep 100
				
				} // Close forval
				
				* Sort the g_queryID variable in order to place all of the results directly under their search observation
				destring g_queryID, replace
				sort g_queryID, stable
				
				* destring g_lat and g_lng if they were used
				destring g_lat, replace
				destring g_lng, replace
				
				* put all the observations back in order
				sort originalid, stable
				drop originalid
				
				* drop the tempvariables
				cap drop g_search`varcount'
				cap drop g_placeid
				
			} // Close textsearch
			
				
		
	*This is where nearby search starts
		if "`nearbysearch'" != "" {
				
		*create variable to keep observations in order
			local totl = _N 	
			cap gen originalid = ""
			forval i = 1/`totl' {
			replace originalid = "`i'" in `i'
			}
			destring originalid, replace
		
		* If [in] condition is not specified, initialize macro
			if "`in'" == "" local in "1/`totl'"

		*Save the original variables in a list
			ds
			local originalvars `r(varlist)'
				
		*Create all temp files/variables and needed variables
			tempfile apiresult
			tempfile apiresult2
			capture confirm variable g_queryID
				if _rc {
					cap gen str10 g_queryID = ""
						}
						else  {
							tostring g_queryID, replace
							}
			capture confirm variable g_status
				if _rc {
					cap gen str24 g_status = ""
						}
			capture confirm variable g_placeid
				if _rc {
					cap gen str64 g_placeid = ""
						}
		*Depending on which options the user chooses, generate the other required temp variables
			capture confirm variable g_name
				if _rc {
					cap gen str60 g_name = ""
						}
			capture confirm variable g_lat
				if _rc {
					cap gen str30 g_lat = ""
						}
						else  {
							tostring g_lat, replace force
							}
			capture confirm variable g_lng
				if _rc {
					cap gen str30 g_lng = ""
						}
						else  {
							tostring g_lng, replace force
							}
			capture confirm variable g_address
				if _rc {
					cap gen str90 g_address = ""			
						}
			if "`advanced'" == "advanced" {
			capture confirm variable g_phonenum
				if _rc {
					cap gen str40 g_phonenum ="" 
						}
			capture confirm variable g_price
				if _rc {
					cap gen str10 g_price =""
						}
			capture confirm variable g_rating
				if _rc {
					cap gen str10 g_rating =""
						}
			capture confirm variable g_website
				if _rc {
					cap gen str100 g_website =""
						}
			
			} // close 'if' advanced
									
		*Here is the main search method, and modifications to what information is pulled need to happen wihtin the forval command	
			forval i = `in' { 
				local nbsrch = `varlist'[`i']
				local offset = _N
				local status = `offset'+1				

			
				// queryID stuff
					replace g_queryID = "`i'" in `i'
						
				// Indicator to track the progress of the search
					local pos = strpos("`in'","/")+1
					local totlcount = substr("`in'",`pos',.)
					noisily di as text "Searching google for `i' of `totlcount' requested searches” 
					
				*Queries google for the given observation and returns the results into the tempfile
					capture copy "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=`nbsrch'&radius=`radius'&types=`type'&name=`keyword'&key=`apikey'" `apiresult'.json , replace
										
						
				/*use insheetjson to extract data from temp file.  */
					
					capture: insheetjson g_status using `apiresult'.json , table("status") col("status") limit(`results') offset(`offset') replace
					replace g_status = g_status[`status'] in `i'
					capture: insheetjson g_placeid using `apiresult'.json , table("results") col("place_id") limit(`results') offset(`offset') replace	
							
						capture: insheetjson g_name using `apiresult'.json , table("results") col("name") limit(`results') offset(`offset') replace
						replace g_name = g_name[`status'] in `i'
										
						capture: insheetjson g_address using `apiresult'.json , table("results") col("vicinity") limit(`results') offset(`offset') replace
						replace g_address = g_address[`status'] in `i'
						
						capture: insheetjson g_lat g_lng using `apiresult'.json , table("results") col("geometry:location:lat" "geometry:location:lng") limit(`results') offset(`offset') replace
						replace g_lat = g_lat[`status'] in `i'
						replace g_lng = g_lng[`status'] in `i'
							
							
					*  Create some needed variables to fill in the g_queryID variable and to do the instant debug notifier
						local finaln = _N
					
					*  Fill in the queryID number for all results pulled by the search
						replace g_queryID = "`i'" in `status'/`finaln'
						
					*  Fill in the g_status variable for all the results
						replace g_status = g_status[`i'] in `status'/`finaln'
						
					*  Fill in the original data in all the blank space
						foreach t of local originalvars {
							replace `t' = `t'[`i'] in `status'/`finaln'
							}
				
					*An insta-debug notifier that will notify the user if the search for that particular obeservation failed
					*Please refer to the g_status variable for the actual error code related to said observation
						cap assert g_status == "OK" in `status'
						if _rc == 9 noisily di as text "Return code was not OK"		
			
			
				if "`advanced'" == "advanced" {
				*Now we run the Detail search loop.  Information will then be pulled from the detail search if the options were detected
					forval p = `status'/`finaln'{
					local offset2 = `p'-1
					local searchid = g_placeid[`p']
					
					*capture the detail search results using the google place ID
					capture copy "https://maps.googleapis.com/maps/api/place/details/json?placeid=`searchid'&key=`apikey'" `apiresult2'.json , replace
			
					/*Use insheetjson to grab the phonenumber.  Please notice that the g_status variable is not overwritten by this search, so
					if there is	an error with this search, the specific error code will not be recorded.	*/
						capture: insheetjson g_phonenum using `apiresult2'.json , table("result") col("formatted_phone_number") limit(1) offset(`offset2') replace
						replace g_phonenum = g_phonenum[`status'] in `i'
					
						capture: insheetjson g_address using `apiresult2'.json , table("result") col("formatted_address") limit(1) offset(`offset2') replace
						replace g_address = g_address[`status'] in `i'		
					
						capture: insheetjson g_price using `apiresult2'.json , table("result") col("price_level") limit(1) offset(`offset2') replace
						replace g_price = g_price[`status'] in `i'
						
						capture: insheetjson g_rating using `apiresult2'.json , table("result") col("rating") limit(1) offset(`offset2') replace
						replace g_rating = g_rating[`status'] in `i'
						
						capture: insheetjson g_website using `apiresult2'.json , table("result") col("website") limit(1) offset(`offset2') replace
						replace g_website = g_website[`status'] in `i'
					
							} // close detail search forval
						} // close if advanced
					
					*get rid of the duplicate variable
					drop in `status'/`status'
			
				* delay loop
				//sleep 100
			
				} // Close forval
				
				* Sort the g_queryID variable in order to place all of the results directly under their search observation
				destring g_queryID, replace
				sort g_queryID, stable
				
				* destring g_lat and g_lng if they were used
				destring g_lat, replace
				destring g_lng, replace
				
				* put all the observations back in order
				sort originalid, stable
				drop originalid
				
				* drop the tempvariables
				cap drop g_search`varcount'
				cap drop g_placeid
				
			} // Close Nearby search
			
			*if googleplaces terminates due to server timeout, run this command to clean up data
			
				if "`cleanup'" == "cleanup" {
		
				* Sort the g_queryID variable in order to place all of the results directly under their search observation
				destring g_queryID, replace
				sort g_queryID, stable
				
				* destring g_lat and g_lng if they were used
				destring g_lat, replace
				destring g_lng, replace
				
				* put all the observations back in order
				sort originalid, stable
				drop originalid
				
				* drop the tempvariables
				cap drop g_search`varcount'
				cap drop g_placeid
						
				} // close cleanup
				
		} // Close quietly
			
	end

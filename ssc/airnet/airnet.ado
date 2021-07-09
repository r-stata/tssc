program airnet, rclass
version 11
//Revised 11january2013
//Author: Zachary Neal (zpneal@msu.edu)
syntax , [stub(str) alpha(real .05) MAXfare(real 5000) MINfare(real 21) LEGtype metro(str) matrix DESCriptives intl(int 0)]
quietly {
preserve
clear
noisily: display " "
tempfile temp route origdest sdrt bus_leis distance
if "`descriptives'" ~= "" {
	timer clear 1
	timer on 1
	}

//Check for valid metro option
if "`metro'" ~= "" & "`metro'" ~= "old" & "`metro'" ~= "new" {
	noisily: display "The -metro- option must specify either the "old" or "new" aggregation schemes."
	error ("`metro'" ~= "")
	}

//Check for valid intl option
if `intl' ~= 0 {
	if "`metro'" ~= "" {
		noisily: display "The -metro- option cannot be combined with the -intl- option."
		error("`metro'" ~= "")
	}
	if `intl' < 0 | `intl' > 4 {
		noisily: display "The -intl- option must specify a calendar quarter 1, 2, 3, or 4."
		error(`intl' ~= 0)
	}
}

//Read in data, merge files
clear
infile str20 itin_id roundtrip passengers itin_fare x in 2/l using "ticket`stub'.csv"
keep itin_id roundtrip passengers itin_fare
sort itin_id
save `temp', replace
clear
infile str20 itin_id str20 mkt_id seq_num str3 origin str3 dest x in 2/l using "coupon`stub'.csv"
keep itin_id mkt_id seq_num origin dest
sort itin_id
merge itin_id using `temp'
drop _merge
sort itin_id seq_num
rename origin orig
save `temp', replace

//Compute number of movements & airports, if requested
if "`descriptives'" ~= "" {
	sum passengers, mean
	return scalar movements = r(sum)
	keep orig dest
	stack orig dest, into(dest) clear
	drop _stack
	duplicates drop
	return scalar airports = _N
	clear
	use `temp'
	}

//Generate route network
if "`legtype'" ~= "" {
	egen first_coupon = min(seq_num), by(mkt_id)
	egen last_coupon = max(seq_num), by(mkt_id)
	gen route = passengers
	gen first = 0
	gen last = 0
	gen middle = 0
	gen only = 0
	replace first = passengers if seq_num == first_coupon & seq_num ~= last_coupon 		//Passengers for whom first leg in market
	replace last = passengers if seq_num ~= first_coupon & seq_num == last_coupon 		//Passengers for whom last leg in market
	replace middle = passengers if seq_num ~= first_coupon & seq_num ~= last_coupon 	//Passengers for whom middle leg in market
	replace only = passengers if seq_num == first_coupon & seq_num == last_coupon 		//Passengers for whom only leg in market
	collapse (sum) route first last middle only, by(orig dest)
	}
else {
	rename passengers route
	collapse (sum) route, by(orig dest)
	}
save `route'

//Delete intermediate segments, generate origin-destination network
clear
use `temp'
sort mkt_id seq_num
by mkt_id: replace dest = dest[_N]		//Put market's last destination into first coupon
sort itin_id mkt_id seq_num
duplicates drop mkt_id, force			//Keep only first record per market
egen market_num = count(seq_num), by(itin_id)	//Number of markets per itinerary
drop seq_num mkt_id
save `temp', replace
rename passengers origdest
collapse (sum) origdest, by(orig dest)
save `origdest'

//Generate single-destination-round-trip networks
clear
use `temp'
duplicates drop itin_id, force				//Keep only one record per trip
if "`descriptives'" ~= "" {
	sum passengers, mean
	return scalar all_pass = r(sum)
	sum passengers if market_num == 2 & roundtrip == 1
	return scalar sdrt_pass = r(sum)
	}
keep if market_num == 2 & roundtrip == 1		//Keep single-destination round-trips
drop itin_id roundtrip market_num
save `temp', replace
gen sdrt = passengers
collapse (sum) sdrt, by(orig dest)
save `sdrt'

//Generate business and leisure networks
clear
use `temp'
if "`descriptives'" ~= "" {
	sum passengers if itin_fare < `minfare', mean
	return scalar lowfare = r(sum)
	sum passengers if itin_fare > `maxfare', mean
	return scalar highfare = r(sum)
	}
drop if itin_fare < `minfare'
drop if itin_fare > `maxfare'
egen fare_mean = mean(itin_fare), by(orig dest)
egen fare_sd = sd(itin_fare), by(orig dest)
gen business = passengers if itin_fare > fare_mean + (fare_sd * invnormal(1-`alpha')) & passengers == 1
gen leisure = passengers if itin_fare < fare_mean + (fare_sd * invnormal(1-`alpha')) & passengers > 1
collapse (sum) business leisure, by(orig dest)
save `bus_leis'

//Combine networks, insert any missing dyads
clear
use `route'
merge 1:1 orig dest using `origdest'
drop _merge
merge 1:1 orig dest using `sdrt'
drop _merge
merge 1:1 orig dest using `bus_leis'
drop _merge
save `temp', replace
keep orig dest
stack orig dest, into(dest) clear
drop _stack
duplicates drop
save `route', replace
rename dest orig
cross using `route'
merge orig dest using `temp', unique sort
drop _merge
mvencode _all, mv(0) override

//=== BEGIN METROPOLITAN AREA AGGREGATION SYNTAX ===
//Insert lat & long of primary hub airports
if "`metro'" ~= "" {
gen lat_orig = .
gen long_orig = .
gen lat_dest = .
gen long_dest = .
replace lat_orig = 33.6367 if orig == "ATL"
replace lat_orig = 41.9808 if orig == "ORD"
replace lat_orig = 33.9425 if orig == "LAX"
replace lat_orig = 32.8969 if orig == "DFW"
replace lat_orig = 39.8617 if orig == "DEN"
replace lat_orig = 40.6397 if orig == "JFK"
replace lat_orig = 29.9844 if orig == "IAH"
replace lat_orig = 37.6189 if orig == "SFO"
replace lat_orig = 36.08 if orig == "LAS"
replace lat_orig = 33.4342 if orig == "PHX"
replace lat_orig = 35.2139 if orig == "CLT"
replace lat_orig = 25.7932 if orig == "MIA"
replace lat_orig = 28.4294 if orig == "MCO"
replace lat_orig = 40.6925 if orig == "EWR"
replace lat_orig = 42.2125 if orig == "DTW"
replace lat_orig = 44.8819 if orig == "MSP"
replace lat_orig = 47.45 if orig == "SEA"
replace lat_orig = 39.8722 if orig == "PHL"
replace lat_orig = 42.3631 if orig == "BOS"
replace lat_orig = 40.7772 if orig == "LGA"
replace lat_orig = 38.9475 if orig == "IAD"
replace lat_orig = 39.1753 if orig == "BWI"
replace lat_orig = 26.0726 if orig == "FLL"
replace lat_orig = 40.7883 if orig == "SLC"
replace lat_orig = 21.3187 if orig == "HNL"
replace lat_orig = 38.8522 if orig == "DCA"
replace lat_orig = 41.7861 if orig == "MDW"
replace lat_orig = 32.7336 if orig == "SAN"
replace lat_orig = 27.9756 if orig == "TPA"
replace lat_orig = 45.5883 if orig == "PDX"
replace lat_orig = 38.7486 if orig == "STL"
replace lat_orig = 39.2975 if orig == "MCI"
replace lat_orig = 35.0425 if orig == "MEM"
replace lat_orig = 42.9472 if orig == "MKE"
replace lat_orig = 37.7214 if orig == "OAK"
replace lat_orig = 41.4094 if orig == "CLE"
replace lat_orig = 35.8778 if orig == "RDU"
replace lat_orig = 36.1244 if orig == "BNA"
replace lat_orig = 38.6956 if orig == "SMF"
replace lat_orig = 29.6456 if orig == "HOU"
replace lat_orig = 33.6756 if orig == "SNA"
replace lat_orig = 18.4394 if orig == "SJU"
replace lat_orig = 30.1944 if orig == "AUS"
replace lat_orig = 29.9933 if orig == "MSY"
replace lat_orig = 37.3628 if orig == "SJC"
replace lat_orig = 40.4914 if orig == "PIT"
replace lat_orig = 29.5336 if orig == "SAT"
replace lat_orig = 39.0489 if orig == "CVG"
replace lat_orig = 32.8472 if orig == "DAL"
replace lat_orig = 39.7172 if orig == "IND"
replace lat_orig = 26.5362 if orig == "RSW"
replace lat_orig = 39.9981 if orig == "CMH"
replace lat_orig = 26.6832 if orig == "PBI"
replace lat_orig = 35.0403 if orig == "ABQ"
replace lat_orig = 30.4942 if orig == "JAX"
replace lat_orig = 41.9389 if orig == "BDL"
replace lat_orig = 42.9406 if orig == "BUF"
replace lat_orig = 20.8986 if orig == "OGG"
replace lat_orig = 34.0561 if orig == "ONT"
replace lat_orig = 61.1744 if orig == "ANC"
replace lat_orig = 34.2006 if orig == "BUR"
replace lat_orig = 41.3031 if orig == "OMA"
replace lat_orig = 41.7239 if orig == "PVD"
replace lat_orig = 39.4992 if orig == "RNO"
replace lat_orig = 32.1161 if orig == "TUS"
replace lat_orig = 35.3931 if orig == "OKC"
replace lat_orig = 36.8947 if orig == "ORF"
replace lat_orig = 37.5053 if orig == "RIC"
replace lat_orig = 38.1742 if orig == "SDF"
replace lat_orig = 47.62 if orig == "GEG"
replace lat_orig = 31.8072 if orig == "ELP"
replace lat_orig = 33.8178 if orig == "LGB"
replace lat_orig = 33.5639 if orig == "BHM"
replace lat_orig = 43.5644 if orig == "BOI"
replace lat_orig = 42.9328 if orig == "MHT"
replace lat_orig = 36.1983 if orig == "TUL"
replace lat_orig = 43.1189 if orig == "ROC"
replace lat_orig = 42.7492 if orig == "ALB"
replace lat_orig = 39.9025 if orig == "DAY"
replace lat_orig = 34.7294 if orig == "LIT"
replace lat_orig = 42.8808 if orig == "GRR"
replace lat_orig = 43.1111 if orig == "SYR"
replace lat_orig = 32.8986 if orig == "CHS"
replace lat_orig = 41.0669 if orig == "HPN"
replace lat_orig = 41.5339 if orig == "DSM"
replace lat_orig = 38.8058 if orig == "COS"
replace lat_orig = 40.7953 if orig == "ISP"
replace lat_orig = 36.0978 if orig == "GSO"
replace lat_orig = 43.6461 if orig == "PWM"
replace lat_orig = 35.8111 if orig == "TYS"
replace lat_orig = 32.1275 if orig == "SAV"
replace lat_orig = 33.6797 if orig == "MYR"
replace lat_orig = 40.9161 if orig == "CAK"
replace lat_orig = 43.1397 if orig == "MSN"
replace lat_orig = 37.65 if orig == "ICT"
replace lat_orig = 33.8297 if orig == "PSP"
replace lat_orig = 30.4733 if orig == "PNS"
replace lat_orig = 27.3954 if orig == "SRQ"
replace lat_orig = 39.4575 if orig == "ACY"
replace lat_orig = 40.1936 if orig == "MDT"
replace lat_orig = 34.8956 if orig == "GSP"
replace lat_orig = 44.4719 if orig == "BTV"
replace lat_orig = 32.3111 if orig == "JAN"
replace lat_orig = 19.7202 if orig == "ITO"
replace lat_orig = 34.6372 if orig == "HSV"
replace lat_orig = 36.7761 if orig == "FAT"
replace lat_orig = 28.7767 if orig == "SFB"
replace lat_orig = 36.2819 if orig == "XNA"
replace lat_orig = 38.0364 if orig == "LEX"
replace lat_orig = 37.1319 if orig == "PHF"
replace lat_orig = 33.6636 if orig == "LBB"
replace lat_orig = 42.9656 if orig == "FNT"
replace lat_orig = 33.9389 if orig == "CAE"
replace lat_orig = 41.4486 if orig == "MLI"
replace lat_orig = 41.8847 if orig == "CID"
replace lat_orig = 30.4072 if orig == "GPT"
replace lat_orig = 31.9425 if orig == "MAF"
replace lat_orig = 64.8156 if orig == "FAI"
replace lat_orig = 33.3078 if orig == "IWA"
replace lat_orig = 44.8075 if orig == "BGR"
replace lat_orig = 40.6522 if orig == "ABE"
replace lat_orig = 34.2706 if orig == "ILM"
replace lat_orig = 48.7928 if orig == "BLI"
replace lat_orig = 35.2194 if orig == "AMA"
replace lat_orig = 45.8078 if orig == "BIL"
replace lat_orig = 27.91 if orig == "PIE"
replace lat_orig = 34.4261 if orig == "SBA"
replace lat_orig = 30.5328 if orig == "BTR"
replace lat_orig = 37.2456 if orig == "SGF"
replace lat_orig = 26.2285 if orig == "HRL"
replace lat_orig = 35.4361 if orig == "AVL"
replace lat_orig = 44.1244 if orig == "EUG"
replace lat_orig = 46.9206 if orig == "FAR"
replace lat_orig = 45.7775 if orig == "BZN"
replace long_orig = 84.4281 if orig == "ATL"
replace long_orig = 87.9067 if orig == "ORD"
replace long_orig = 118.4072 if orig == "LAX"
replace long_orig = 97.0381 if orig == "DFW"
replace long_orig = 104.6731 if orig == "DEN"
replace long_orig = 73.7789 if orig == "JFK"
replace long_orig = 95.3414 if orig == "IAH"
replace long_orig = 122.375 if orig == "SFO"
replace long_orig = 115.1522 if orig == "LAS"
replace long_orig = 112.0117 if orig == "PHX"
replace long_orig = 80.9431 if orig == "CLT"
replace long_orig = 80.2906 if orig == "MIA"
replace long_orig = 81.3089 if orig == "MCO"
replace long_orig = 74.1686 if orig == "EWR"
replace long_orig = 83.3533 if orig == "DTW"
replace long_orig = 93.2217 if orig == "MSP"
replace long_orig = 122.3117 if orig == "SEA"
replace long_orig = 75.2408 if orig == "PHL"
replace long_orig = 71.0064 if orig == "BOS"
replace long_orig = 73.8725 if orig == "LGA"
replace long_orig = 77.46 if orig == "IAD"
replace long_orig = 76.6683 if orig == "BWI"
replace long_orig = 80.1528 if orig == "FLL"
replace long_orig = 111.9778 if orig == "SLC"
replace long_orig = 157.9225 if orig == "HNL"
replace long_orig = 77.0378 if orig == "DCA"
replace long_orig = 87.7525 if orig == "MDW"
replace long_orig = 117.1897 if orig == "SAN"
replace long_orig = 82.5333 if orig == "TPA"
replace long_orig = 122.5975 if orig == "PDX"
replace long_orig = 90.37 if orig == "STL"
replace long_orig = 94.7139 if orig == "MCI"
replace long_orig = 89.9767 if orig == "MEM"
replace long_orig = 87.8967 if orig == "MKE"
replace long_orig = 122.2208 if orig == "OAK"
replace long_orig = 81.855 if orig == "CLE"
replace long_orig = 78.7875 if orig == "RDU"
replace long_orig = 86.6783 if orig == "BNA"
replace long_orig = 121.5908 if orig == "SMF"
replace long_orig = 95.2789 if orig == "HOU"
replace long_orig = 117.8683 if orig == "SNA"
replace long_orig = 66.0019 if orig == "SJU"
replace long_orig = 97.67 if orig == "AUS"
replace long_orig = 90.2581 if orig == "MSY"
replace long_orig = 121.9292 if orig == "SJC"
replace long_orig = 80.2328 if orig == "PIT"
replace long_orig = 98.4697 if orig == "SAT"
replace long_orig = 84.6678 if orig == "CVG"
replace long_orig = 96.8517 if orig == "DAL"
replace long_orig = 86.2947 if orig == "IND"
replace long_orig = 81.7553 if orig == "RSW"
replace long_orig = 82.8919 if orig == "CMH"
replace long_orig = 80.0956 if orig == "PBI"
replace long_orig = 106.6092 if orig == "ABQ"
replace long_orig = 81.6878 if orig == "JAX"
replace long_orig = 72.6833 if orig == "BDL"
replace long_orig = 78.7322 if orig == "BUF"
replace long_orig = 156.4306 if orig == "OGG"
replace long_orig = 117.6011 if orig == "ONT"
replace long_orig = 149.9964 if orig == "ANC"
replace long_orig = 118.3586 if orig == "BUR"
replace long_orig = 95.8942 if orig == "OMA"
replace long_orig = 71.4283 if orig == "PVD"
replace long_orig = 119.7681 if orig == "RNO"
replace long_orig = 110.9411 if orig == "TUS"
replace long_orig = 97.6008 if orig == "OKC"
replace long_orig = 76.2011 if orig == "ORF"
replace long_orig = 77.3197 if orig == "RIC"
replace long_orig = 85.7364 if orig == "SDF"
replace long_orig = 117.5339 if orig == "GEG"
replace long_orig = 106.3775 if orig == "ELP"
replace long_orig = 118.1517 if orig == "LGB"
replace long_orig = 86.7522 if orig == "BHM"
replace long_orig = 116.2228 if orig == "BOI"
replace long_orig = 71.4358 if orig == "MHT"
replace long_orig = 95.8881 if orig == "TUL"
replace long_orig = 77.6725 if orig == "ROC"
replace long_orig = 73.8019 if orig == "ALB"
replace long_orig = 84.2194 if orig == "DAY"
replace long_orig = 92.2244 if orig == "LIT"
replace long_orig = 85.5228 if orig == "GRR"
replace long_orig = 76.1064 if orig == "SYR"
replace long_orig = 80.0406 if orig == "CHS"
replace long_orig = 73.7075 if orig == "HPN"
replace long_orig = 93.6631 if orig == "DSM"
replace long_orig = 104.7008 if orig == "COS"
replace long_orig = 73.1003 if orig == "ISP"
replace long_orig = 79.9372 if orig == "GSO"
replace long_orig = 70.3092 if orig == "PWM"
replace long_orig = 83.9939 if orig == "TYS"
replace long_orig = 81.2022 if orig == "SAV"
replace long_orig = 78.9283 if orig == "MYR"
replace long_orig = 81.4422 if orig == "CAK"
replace long_orig = 89.3375 if orig == "MSN"
replace long_orig = 97.4331 if orig == "ICT"
replace long_orig = 116.5067 if orig == "PSP"
replace long_orig = 87.1867 if orig == "PNS"
replace long_orig = 82.5544 if orig == "SRQ"
replace long_orig = 74.5772 if orig == "ACY"
replace long_orig = 76.7633 if orig == "MDT"
replace long_orig = 82.2189 if orig == "GSP"
replace long_orig = 73.1533 if orig == "BTV"
replace long_orig = 90.0758 if orig == "JAN"
replace long_orig = 155.0483 if orig == "ITO"
replace long_orig = 86.775 if orig == "HSV"
replace long_orig = 119.7181 if orig == "FAT"
replace long_orig = 81.2356 if orig == "SFB"
replace long_orig = 94.3069 if orig == "XNA"
replace long_orig = 84.6058 if orig == "LEX"
replace long_orig = 76.4931 if orig == "PHF"
replace long_orig = 101.8228 if orig == "LBB"
replace long_orig = 83.7436 if orig == "FNT"
replace long_orig = 81.1194 if orig == "CAE"
replace long_orig = 90.5072 if orig == "MLI"
replace long_orig = 91.7108 if orig == "CID"
replace long_orig = 89.07 if orig == "GPT"
replace long_orig = 102.2019 if orig == "MAF"
replace long_orig = 147.8586 if orig == "FAI"
replace long_orig = 111.6556 if orig == "IWA"
replace long_orig = 68.8281 if orig == "BGR"
replace long_orig = 75.4403 if orig == "ABE"
replace long_orig = 77.9025 if orig == "ILM"
replace long_orig = 122.5375 if orig == "BLI"
replace long_orig = 101.7058 if orig == "AMA"
replace long_orig = 108.5428 if orig == "BIL"
replace long_orig = 82.6875 if orig == "PIE"
replace long_orig = 119.8414 if orig == "SBA"
replace long_orig = 91.15 if orig == "BTR"
replace long_orig = 93.3886 if orig == "SGF"
replace long_orig = 97.6544 if orig == "HRL"
replace long_orig = 82.5417 if orig == "AVL"
replace long_orig = 123.2119 if orig == "EUG"
replace long_orig = 96.8158 if orig == "FAR"
replace long_orig = 111.1519 if orig == "BZN"
replace lat_dest = 33.6367 if dest == "ATL"
replace lat_dest = 41.9808 if dest == "ORD"
replace lat_dest = 33.9425 if dest == "LAX"
replace lat_dest = 32.8969 if dest == "DFW"
replace lat_dest = 39.8617 if dest == "DEN"
replace lat_dest = 40.6397 if dest == "JFK"
replace lat_dest = 29.9844 if dest == "IAH"
replace lat_dest = 37.6189 if dest == "SFO"
replace lat_dest = 36.08 if dest == "LAS"
replace lat_dest = 33.4342 if dest == "PHX"
replace lat_dest = 35.2139 if dest == "CLT"
replace lat_dest = 25.7932 if dest == "MIA"
replace lat_dest = 28.4294 if dest == "MCO"
replace lat_dest = 40.6925 if dest == "EWR"
replace lat_dest = 42.2125 if dest == "DTW"
replace lat_dest = 44.8819 if dest == "MSP"
replace lat_dest = 47.45 if dest == "SEA"
replace lat_dest = 39.8722 if dest == "PHL"
replace lat_dest = 42.3631 if dest == "BOS"
replace lat_dest = 40.7772 if dest == "LGA"
replace lat_dest = 38.9475 if dest == "IAD"
replace lat_dest = 39.1753 if dest == "BWI"
replace lat_dest = 26.0726 if dest == "FLL"
replace lat_dest = 40.7883 if dest == "SLC"
replace lat_dest = 21.3187 if dest == "HNL"
replace lat_dest = 38.8522 if dest == "DCA"
replace lat_dest = 41.7861 if dest == "MDW"
replace lat_dest = 32.7336 if dest == "SAN"
replace lat_dest = 27.9756 if dest == "TPA"
replace lat_dest = 45.5883 if dest == "PDX"
replace lat_dest = 38.7486 if dest == "STL"
replace lat_dest = 39.2975 if dest == "MCI"
replace lat_dest = 35.0425 if dest == "MEM"
replace lat_dest = 42.9472 if dest == "MKE"
replace lat_dest = 37.7214 if dest == "OAK"
replace lat_dest = 41.4094 if dest == "CLE"
replace lat_dest = 35.8778 if dest == "RDU"
replace lat_dest = 36.1244 if dest == "BNA"
replace lat_dest = 38.6956 if dest == "SMF"
replace lat_dest = 29.6456 if dest == "HOU"
replace lat_dest = 33.6756 if dest == "SNA"
replace lat_dest = 18.4394 if dest == "SJU"
replace lat_dest = 30.1944 if dest == "AUS"
replace lat_dest = 29.9933 if dest == "MSY"
replace lat_dest = 37.3628 if dest == "SJC"
replace lat_dest = 40.4914 if dest == "PIT"
replace lat_dest = 29.5336 if dest == "SAT"
replace lat_dest = 39.0489 if dest == "CVG"
replace lat_dest = 32.8472 if dest == "DAL"
replace lat_dest = 39.7172 if dest == "IND"
replace lat_dest = 26.5362 if dest == "RSW"
replace lat_dest = 39.9981 if dest == "CMH"
replace lat_dest = 26.6832 if dest == "PBI"
replace lat_dest = 35.0403 if dest == "ABQ"
replace lat_dest = 30.4942 if dest == "JAX"
replace lat_dest = 41.9389 if dest == "BDL"
replace lat_dest = 42.9406 if dest == "BUF"
replace lat_dest = 20.8986 if dest == "OGG"
replace lat_dest = 34.0561 if dest == "ONT"
replace lat_dest = 61.1744 if dest == "ANC"
replace lat_dest = 34.2006 if dest == "BUR"
replace lat_dest = 41.3031 if dest == "OMA"
replace lat_dest = 41.7239 if dest == "PVD"
replace lat_dest = 39.4992 if dest == "RNO"
replace lat_dest = 32.1161 if dest == "TUS"
replace lat_dest = 35.3931 if dest == "OKC"
replace lat_dest = 36.8947 if dest == "ORF"
replace lat_dest = 37.5053 if dest == "RIC"
replace lat_dest = 38.1742 if dest == "SDF"
replace lat_dest = 47.62 if dest == "GEG"
replace lat_dest = 31.8072 if dest == "ELP"
replace lat_dest = 33.8178 if dest == "LGB"
replace lat_dest = 33.5639 if dest == "BHM"
replace lat_dest = 43.5644 if dest == "BOI"
replace lat_dest = 42.9328 if dest == "MHT"
replace lat_dest = 36.1983 if dest == "TUL"
replace lat_dest = 43.1189 if dest == "ROC"
replace lat_dest = 42.7492 if dest == "ALB"
replace lat_dest = 39.9025 if dest == "DAY"
replace lat_dest = 34.7294 if dest == "LIT"
replace lat_dest = 42.8808 if dest == "GRR"
replace lat_dest = 43.1111 if dest == "SYR"
replace lat_dest = 32.8986 if dest == "CHS"
replace lat_dest = 41.0669 if dest == "HPN"
replace lat_dest = 41.5339 if dest == "DSM"
replace lat_dest = 38.8058 if dest == "COS"
replace lat_dest = 40.7953 if dest == "ISP"
replace lat_dest = 36.0978 if dest == "GSO"
replace lat_dest = 43.6461 if dest == "PWM"
replace lat_dest = 35.8111 if dest == "TYS"
replace lat_dest = 32.1275 if dest == "SAV"
replace lat_dest = 33.6797 if dest == "MYR"
replace lat_dest = 40.9161 if dest == "CAK"
replace lat_dest = 43.1397 if dest == "MSN"
replace lat_dest = 37.65 if dest == "ICT"
replace lat_dest = 33.8297 if dest == "PSP"
replace lat_dest = 30.4733 if dest == "PNS"
replace lat_dest = 27.3954 if dest == "SRQ"
replace lat_dest = 39.4575 if dest == "ACY"
replace lat_dest = 40.1936 if dest == "MDT"
replace lat_dest = 34.8956 if dest == "GSP"
replace lat_dest = 44.4719 if dest == "BTV"
replace lat_dest = 32.3111 if dest == "JAN"
replace lat_dest = 19.7202 if dest == "ITO"
replace lat_dest = 34.6372 if dest == "HSV"
replace lat_dest = 36.7761 if dest == "FAT"
replace lat_dest = 28.7767 if dest == "SFB"
replace lat_dest = 36.2819 if dest == "XNA"
replace lat_dest = 38.0364 if dest == "LEX"
replace lat_dest = 37.1319 if dest == "PHF"
replace lat_dest = 33.6636 if dest == "LBB"
replace lat_dest = 42.9656 if dest == "FNT"
replace lat_dest = 33.9389 if dest == "CAE"
replace lat_dest = 41.4486 if dest == "MLI"
replace lat_dest = 41.8847 if dest == "CID"
replace lat_dest = 30.4072 if dest == "GPT"
replace lat_dest = 31.9425 if dest == "MAF"
replace lat_dest = 64.8156 if dest == "FAI"
replace lat_dest = 33.3078 if dest == "IWA"
replace lat_dest = 44.8075 if dest == "BGR"
replace lat_dest = 40.6522 if dest == "ABE"
replace lat_dest = 34.2706 if dest == "ILM"
replace lat_dest = 48.7928 if dest == "BLI"
replace lat_dest = 35.2194 if dest == "AMA"
replace lat_dest = 45.8078 if dest == "BIL"
replace lat_dest = 27.91 if dest == "PIE"
replace lat_dest = 34.4261 if dest == "SBA"
replace lat_dest = 30.5328 if dest == "BTR"
replace lat_dest = 37.2456 if dest == "SGF"
replace lat_dest = 26.2285 if dest == "HRL"
replace lat_dest = 35.4361 if dest == "AVL"
replace lat_dest = 44.1244 if dest == "EUG"
replace lat_dest = 46.9206 if dest == "FAR"
replace lat_dest = 45.7775 if dest == "BZN"
replace long_dest = 84.4281 if dest == "ATL"
replace long_dest = 87.9067 if dest == "ORD"
replace long_dest = 118.4072 if dest == "LAX"
replace long_dest = 97.0381 if dest == "DFW"
replace long_dest = 104.6731 if dest == "DEN"
replace long_dest = 73.7789 if dest == "JFK"
replace long_dest = 95.3414 if dest == "IAH"
replace long_dest = 122.375 if dest == "SFO"
replace long_dest = 115.1522 if dest == "LAS"
replace long_dest = 112.0117 if dest == "PHX"
replace long_dest = 80.9431 if dest == "CLT"
replace long_dest = 80.2906 if dest == "MIA"
replace long_dest = 81.3089 if dest == "MCO"
replace long_dest = 74.1686 if dest == "EWR"
replace long_dest = 83.3533 if dest == "DTW"
replace long_dest = 93.2217 if dest == "MSP"
replace long_dest = 122.3117 if dest == "SEA"
replace long_dest = 75.2408 if dest == "PHL"
replace long_dest = 71.0064 if dest == "BOS"
replace long_dest = 73.8725 if dest == "LGA"
replace long_dest = 77.46 if dest == "IAD"
replace long_dest = 76.6683 if dest == "BWI"
replace long_dest = 80.1528 if dest == "FLL"
replace long_dest = 111.9778 if dest == "SLC"
replace long_dest = 157.9225 if dest == "HNL"
replace long_dest = 77.0378 if dest == "DCA"
replace long_dest = 87.7525 if dest == "MDW"
replace long_dest = 117.1897 if dest == "SAN"
replace long_dest = 82.5333 if dest == "TPA"
replace long_dest = 122.5975 if dest == "PDX"
replace long_dest = 90.37 if dest == "STL"
replace long_dest = 94.7139 if dest == "MCI"
replace long_dest = 89.9767 if dest == "MEM"
replace long_dest = 87.8967 if dest == "MKE"
replace long_dest = 122.2208 if dest == "OAK"
replace long_dest = 81.855 if dest == "CLE"
replace long_dest = 78.7875 if dest == "RDU"
replace long_dest = 86.6783 if dest == "BNA"
replace long_dest = 121.5908 if dest == "SMF"
replace long_dest = 95.2789 if dest == "HOU"
replace long_dest = 117.8683 if dest == "SNA"
replace long_dest = 66.0019 if dest == "SJU"
replace long_dest = 97.67 if dest == "AUS"
replace long_dest = 90.2581 if dest == "MSY"
replace long_dest = 121.9292 if dest == "SJC"
replace long_dest = 80.2328 if dest == "PIT"
replace long_dest = 98.4697 if dest == "SAT"
replace long_dest = 84.6678 if dest == "CVG"
replace long_dest = 96.8517 if dest == "DAL"
replace long_dest = 86.2947 if dest == "IND"
replace long_dest = 81.7553 if dest == "RSW"
replace long_dest = 82.8919 if dest == "CMH"
replace long_dest = 80.0956 if dest == "PBI"
replace long_dest = 106.6092 if dest == "ABQ"
replace long_dest = 81.6878 if dest == "JAX"
replace long_dest = 72.6833 if dest == "BDL"
replace long_dest = 78.7322 if dest == "BUF"
replace long_dest = 156.4306 if dest == "OGG"
replace long_dest = 117.6011 if dest == "ONT"
replace long_dest = 149.9964 if dest == "ANC"
replace long_dest = 118.3586 if dest == "BUR"
replace long_dest = 95.8942 if dest == "OMA"
replace long_dest = 71.4283 if dest == "PVD"
replace long_dest = 119.7681 if dest == "RNO"
replace long_dest = 110.9411 if dest == "TUS"
replace long_dest = 97.6008 if dest == "OKC"
replace long_dest = 76.2011 if dest == "ORF"
replace long_dest = 77.3197 if dest == "RIC"
replace long_dest = 85.7364 if dest == "SDF"
replace long_dest = 117.5339 if dest == "GEG"
replace long_dest = 106.3775 if dest == "ELP"
replace long_dest = 118.1517 if dest == "LGB"
replace long_dest = 86.7522 if dest == "BHM"
replace long_dest = 116.2228 if dest == "BOI"
replace long_dest = 71.4358 if dest == "MHT"
replace long_dest = 95.8881 if dest == "TUL"
replace long_dest = 77.6725 if dest == "ROC"
replace long_dest = 73.8019 if dest == "ALB"
replace long_dest = 84.2194 if dest == "DAY"
replace long_dest = 92.2244 if dest == "LIT"
replace long_dest = 85.5228 if dest == "GRR"
replace long_dest = 76.1064 if dest == "SYR"
replace long_dest = 80.0406 if dest == "CHS"
replace long_dest = 73.7075 if dest == "HPN"
replace long_dest = 93.6631 if dest == "DSM"
replace long_dest = 104.7008 if dest == "COS"
replace long_dest = 73.1003 if dest == "ISP"
replace long_dest = 79.9372 if dest == "GSO"
replace long_dest = 70.3092 if dest == "PWM"
replace long_dest = 83.9939 if dest == "TYS"
replace long_dest = 81.2022 if dest == "SAV"
replace long_dest = 78.9283 if dest == "MYR"
replace long_dest = 81.4422 if dest == "CAK"
replace long_dest = 89.3375 if dest == "MSN"
replace long_dest = 97.4331 if dest == "ICT"
replace long_dest = 116.5067 if dest == "PSP"
replace long_dest = 87.1867 if dest == "PNS"
replace long_dest = 82.5544 if dest == "SRQ"
replace long_dest = 74.5772 if dest == "ACY"
replace long_dest = 76.7633 if dest == "MDT"
replace long_dest = 82.2189 if dest == "GSP"
replace long_dest = 73.1533 if dest == "BTV"
replace long_dest = 90.0758 if dest == "JAN"
replace long_dest = 155.0483 if dest == "ITO"
replace long_dest = 86.775 if dest == "HSV"
replace long_dest = 119.7181 if dest == "FAT"
replace long_dest = 81.2356 if dest == "SFB"
replace long_dest = 94.3069 if dest == "XNA"
replace long_dest = 84.6058 if dest == "LEX"
replace long_dest = 76.4931 if dest == "PHF"
replace long_dest = 101.8228 if dest == "LBB"
replace long_dest = 83.7436 if dest == "FNT"
replace long_dest = 81.1194 if dest == "CAE"
replace long_dest = 90.5072 if dest == "MLI"
replace long_dest = 91.7108 if dest == "CID"
replace long_dest = 89.07 if dest == "GPT"
replace long_dest = 102.2019 if dest == "MAF"
replace long_dest = 147.8586 if dest == "FAI"
replace long_dest = 111.6556 if dest == "IWA"
replace long_dest = 68.8281 if dest == "BGR"
replace long_dest = 75.4403 if dest == "ABE"
replace long_dest = 77.9025 if dest == "ILM"
replace long_dest = 122.5375 if dest == "BLI"
replace long_dest = 101.7058 if dest == "AMA"
replace long_dest = 108.5428 if dest == "BIL"
replace long_dest = 82.6875 if dest == "PIE"
replace long_dest = 119.8414 if dest == "SBA"
replace long_dest = 91.15 if dest == "BTR"
replace long_dest = 93.3886 if dest == "SGF"
replace long_dest = 97.6544 if dest == "HRL"
replace long_dest = 82.5417 if dest == "AVL"
replace long_dest = 123.2119 if dest == "EUG"
replace long_dest = 96.8158 if dest == "FAR"
replace long_dest = 111.1519 if dest == "BZN"

//Metro Recode: OLD
if "`metro'" == "old" {
replace orig = "520" if orig == "ATL"
replace orig = "1602" if orig == "ORD"
replace orig = "4472" if orig == "LAX"
replace orig = "1922" if orig == "DFW"
replace orig = "2082" if orig == "DEN"
replace orig = "5602" if orig == "JFK"
replace orig = "3362" if orig == "IAH"
replace orig = "7362" if orig == "SFO"
replace orig = "4120" if orig == "LAS"
replace orig = "6200" if orig == "PHX"
replace orig = "1520" if orig == "CLT"
replace orig = "4992" if orig == "MIA"
replace orig = "5960" if orig == "MCO"
replace orig = "5602" if orig == "EWR"
replace orig = "2162" if orig == "DTW"
replace orig = "5120" if orig == "MSP"
replace orig = "7602" if orig == "SEA"
replace orig = "6162" if orig == "PHL"
replace orig = "1122" if orig == "BOS"
replace orig = "5602" if orig == "LGA"
replace orig = "8872" if orig == "IAD"
replace orig = "8872" if orig == "BWI"
replace orig = "4992" if orig == "FLL"
replace orig = "7160" if orig == "SLC"
replace orig = "3320" if orig == "HNL"
replace orig = "8872" if orig == "DCA"
replace orig = "1602" if orig == "MDW"
replace orig = "7320" if orig == "SAN"
replace orig = "8280" if orig == "TPA"
replace orig = "6442" if orig == "PDX"
replace orig = "7040" if orig == "STL"
replace orig = "3760" if orig == "MCI"
replace orig = "4920" if orig == "MEM"
replace orig = "5082" if orig == "MKE"
replace orig = "7362" if orig == "OAK"
replace orig = "1692" if orig == "CLE"
replace orig = "6640" if orig == "RDU"
replace orig = "5360" if orig == "BNA"
replace orig = "6922" if orig == "SMF"
replace orig = "3362" if orig == "HOU"
replace orig = "4472" if orig == "SNA"
replace orig = "7442" if orig == "SJU"
replace orig = "640" if orig == "AUS"
replace orig = "5560" if orig == "MSY"
replace orig = "7362" if orig == "SJC"
replace orig = "6280" if orig == "PIT"
replace orig = "7240" if orig == "SAT"
replace orig = "1642" if orig == "CVG"
replace orig = "1922" if orig == "DAL"
replace orig = "3840" if orig == "IND"
replace orig = "2700" if orig == "RSW"
replace orig = "1840" if orig == "CMH"
replace orig = "8960" if orig == "PBI"
replace orig = "200" if orig == "ABQ"
replace orig = "3600" if orig == "JAX"
replace orig = "3280" if orig == "BDL"
replace orig = "1280" if orig == "BUF"
replace orig = "4472" if orig == "ONT"
replace orig = "380" if orig == "ANC"
replace orig = "4472" if orig == "BUR"
replace orig = "5920" if orig == "OMA"
replace orig = "6480" if orig == "PVD"
replace orig = "6720" if orig == "RNO"
replace orig = "8520" if orig == "TUS"
replace orig = "5880" if orig == "OKC"
replace orig = "5720" if orig == "ORF"
replace orig = "6760" if orig == "RIC"
replace orig = "4520" if orig == "SDF"
replace orig = "7840" if orig == "GEG"
replace orig = "2320" if orig == "ELP"
replace orig = "4472" if orig == "LGB"
replace orig = "1000" if orig == "BHM"
replace orig = "1080" if orig == "BOI"
replace orig = "1122" if orig == "MHT"
replace orig = "8560" if orig == "TUL"
replace orig = "6840" if orig == "ROC"
replace orig = "160" if orig == "ALB"
replace orig = "2000" if orig == "DAY"
replace orig = "4400" if orig == "LIT"
replace orig = "3000" if orig == "GRR"
replace orig = "8160" if orig == "SYR"
replace orig = "1440" if orig == "CHS"
replace orig = "5602" if orig == "HPN"
replace orig = "2120" if orig == "DSM"
replace orig = "1720" if orig == "COS"
replace orig = "5602" if orig == "ISP"
replace orig = "3120" if orig == "GSO"
replace orig = "6400" if orig == "PWM"
replace orig = "3840" if orig == "TYS"
replace orig = "7520" if orig == "SAV"
replace orig = "5330" if orig == "MYR"
replace orig = "1692" if orig == "CAK"
replace orig = "4720" if orig == "MSN"
replace orig = "9040" if orig == "ICT"
replace orig = "4472" if orig == "PSP"
replace orig = "6080" if orig == "PNS"
replace orig = "7510" if orig == "SRQ"
replace orig = "6162" if orig == "ACY"
replace orig = "3240" if orig == "MDT"
replace orig = "3160" if orig == "GSP"
replace orig = "1305" if orig == "BTV"
replace orig = "3560" if orig == "JAN"
replace orig = "3440" if orig == "HSV"
replace orig = "2840" if orig == "FAT"
replace orig = "5960" if orig == "SFB"
replace orig = "2580" if orig == "XNA"
replace orig = "2580" if orig == "FYV"
replace orig = "4280" if orig == "LEX"
replace orig = "5720" if orig == "PHF"
replace orig = "4600" if orig == "LBB"
replace orig = "2162" if orig == "FNT"
replace orig = "1760" if orig == "CAE"
replace orig = "1960" if orig == "MLI"
replace orig = "1360" if orig == "CID"
replace orig = "920" if orig == "GPT"
replace orig = "5800" if orig == "MAF"
replace orig = "6200" if orig == "IWA"
replace orig = "730" if orig == "BGR"
replace orig = "240" if orig == "ABE"
replace orig = "9200" if orig == "ILM"
replace orig = "860" if orig == "BLI"
replace orig = "320" if orig == "AMA"
replace orig = "880" if orig == "BIL"
replace orig = "8280" if orig == "PIE"
replace orig = "7480" if orig == "SBA"
replace orig = "760" if orig == "BTR"
replace orig = "7920" if orig == "SGF"
replace orig = "1240" if orig == "HRL"
replace orig = "480" if orig == "AVL"
replace orig = "2400" if orig == "EUG"
replace orig = "2520" if orig == "FAR"
replace dest = "520" if dest == "ATL"
replace dest = "1602" if dest == "ORD"
replace dest = "4472" if dest == "LAX"
replace dest = "1922" if dest == "DFW"
replace dest = "2082" if dest == "DEN"
replace dest = "5602" if dest == "JFK"
replace dest = "3362" if dest == "IAH"
replace dest = "7362" if dest == "SFO"
replace dest = "4120" if dest == "LAS"
replace dest = "6200" if dest == "PHX"
replace dest = "1520" if dest == "CLT"
replace dest = "4992" if dest == "MIA"
replace dest = "5960" if dest == "MCO"
replace dest = "5602" if dest == "EWR"
replace dest = "2162" if dest == "DTW"
replace dest = "5120" if dest == "MSP"
replace dest = "7602" if dest == "SEA"
replace dest = "6162" if dest == "PHL"
replace dest = "1122" if dest == "BOS"
replace dest = "5602" if dest == "LGA"
replace dest = "8872" if dest == "IAD"
replace dest = "8872" if dest == "BWI"
replace dest = "4992" if dest == "FLL"
replace dest = "7160" if dest == "SLC"
replace dest = "3320" if dest == "HNL"
replace dest = "8872" if dest == "DCA"
replace dest = "1602" if dest == "MDW"
replace dest = "7320" if dest == "SAN"
replace dest = "8280" if dest == "TPA"
replace dest = "6442" if dest == "PDX"
replace dest = "7040" if dest == "STL"
replace dest = "3760" if dest == "MCI"
replace dest = "4920" if dest == "MEM"
replace dest = "5082" if dest == "MKE"
replace dest = "7362" if dest == "OAK"
replace dest = "1692" if dest == "CLE"
replace dest = "6640" if dest == "RDU"
replace dest = "5360" if dest == "BNA"
replace dest = "6922" if dest == "SMF"
replace dest = "3362" if dest == "HOU"
replace dest = "4472" if dest == "SNA"
replace dest = "7442" if dest == "SJU"
replace dest = "640" if dest == "AUS"
replace dest = "5560" if dest == "MSY"
replace dest = "7362" if dest == "SJC"
replace dest = "6280" if dest == "PIT"
replace dest = "7240" if dest == "SAT"
replace dest = "1642" if dest == "CVG"
replace dest = "1922" if dest == "DAL"
replace dest = "3840" if dest == "IND"
replace dest = "2700" if dest == "RSW"
replace dest = "1840" if dest == "CMH"
replace dest = "8960" if dest == "PBI"
replace dest = "200" if dest == "ABQ"
replace dest = "3600" if dest == "JAX"
replace dest = "3280" if dest == "BDL"
replace dest = "1280" if dest == "BUF"
replace dest = "4472" if dest == "ONT"
replace dest = "380" if dest == "ANC"
replace dest = "4472" if dest == "BUR"
replace dest = "5920" if dest == "OMA"
replace dest = "6480" if dest == "PVD"
replace dest = "6720" if dest == "RNO"
replace dest = "8520" if dest == "TUS"
replace dest = "5880" if dest == "OKC"
replace dest = "5720" if dest == "ORF"
replace dest = "6760" if dest == "RIC"
replace dest = "4520" if dest == "SDF"
replace dest = "7840" if dest == "GEG"
replace dest = "2320" if dest == "ELP"
replace dest = "4472" if dest == "LGB"
replace dest = "1000" if dest == "BHM"
replace dest = "1080" if dest == "BOI"
replace dest = "1122" if dest == "MHT"
replace dest = "8560" if dest == "TUL"
replace dest = "6840" if dest == "ROC"
replace dest = "160" if dest == "ALB"
replace dest = "2000" if dest == "DAY"
replace dest = "4400" if dest == "LIT"
replace dest = "3000" if dest == "GRR"
replace dest = "8160" if dest == "SYR"
replace dest = "1440" if dest == "CHS"
replace dest = "5602" if dest == "HPN"
replace dest = "2120" if dest == "DSM"
replace dest = "1720" if dest == "COS"
replace dest = "5602" if dest == "ISP"
replace dest = "3120" if dest == "GSO"
replace dest = "6400" if dest == "PWM"
replace dest = "3840" if dest == "TYS"
replace dest = "7520" if dest == "SAV"
replace dest = "5330" if dest == "MYR"
replace dest = "1692" if dest == "CAK"
replace dest = "4720" if dest == "MSN"
replace dest = "9040" if dest == "ICT"
replace dest = "4472" if dest == "PSP"
replace dest = "6080" if dest == "PNS"
replace dest = "7510" if dest == "SRQ"
replace dest = "6162" if dest == "ACY"
replace dest = "3240" if dest == "MDT"
replace dest = "3160" if dest == "GSP"
replace dest = "1305" if dest == "BTV"
replace dest = "3560" if dest == "JAN"
replace dest = "3440" if dest == "HSV"
replace dest = "2840" if dest == "FAT"
replace dest = "5960" if dest == "SFB"
replace dest = "2580" if dest == "XNA"
replace dest = "2580" if dest == "FYV"
replace dest = "4280" if dest == "LEX"
replace dest = "5720" if dest == "PHF"
replace dest = "4600" if dest == "LBB"
replace dest = "2162" if dest == "FNT"
replace dest = "1760" if dest == "CAE"
replace dest = "1960" if dest == "MLI"
replace dest = "1360" if dest == "CID"
replace dest = "920" if dest == "GPT"
replace dest = "5800" if dest == "MAF"
replace dest = "6200" if dest == "IWA"
replace dest = "730" if dest == "BGR"
replace dest = "240" if dest == "ABE"
replace dest = "9200" if dest == "ILM"
replace dest = "860" if dest == "BLI"
replace dest = "320" if dest == "AMA"
replace dest = "880" if dest == "BIL"
replace dest = "8280" if dest == "PIE"
replace dest = "7480" if dest == "SBA"
replace dest = "760" if dest == "BTR"
replace dest = "7920" if dest == "SGF"
replace dest = "1240" if dest == "HRL"
replace dest = "480" if dest == "AVL"
replace dest = "2400" if dest == "EUG"
replace dest = "2520" if dest == "FAR"
}

//Metro Recode: NEW
if "`metro'" == "new" {
replace orig = "122" if orig == "ATL"
replace orig = "176" if orig == "ORD"
replace orig = "348" if orig == "LAX"
replace orig = "206" if orig == "DFW"
replace orig = "216" if orig == "DEN"
replace orig = "408" if orig == "JFK"
replace orig = "288" if orig == "IAH"
replace orig = "488" if orig == "SFO"
replace orig = "332" if orig == "LAS"
replace orig = "38060" if orig == "PHX"
replace orig = "172" if orig == "CLT"
replace orig = "33100" if orig == "MIA"
replace orig = "422" if orig == "MCO"
replace orig = "408" if orig == "EWR"
replace orig = "220" if orig == "DTW"
replace orig = "378" if orig == "MSP"
replace orig = "500" if orig == "SEA"
replace orig = "428" if orig == "PHL"
replace orig = "148" if orig == "BOS"
replace orig = "408" if orig == "LGA"
replace orig = "548" if orig == "IAD"
replace orig = "548" if orig == "BWI"
replace orig = "33100" if orig == "FLL"
replace orig = "482" if orig == "SLC"
replace orig = "26180" if orig == "HNL"
replace orig = "548" if orig == "DCA"
replace orig = "176" if orig == "MDW"
replace orig = "41740" if orig == "SAN"
replace orig = "45300" if orig == "TPA"
replace orig = "38900" if orig == "PDX"
replace orig = "476" if orig == "STL"
replace orig = "312" if orig == "MCI"
replace orig = "32820" if orig == "MEM"
replace orig = "376" if orig == "MKE"
replace orig = "488" if orig == "OAK"
replace orig = "184" if orig == "CLE"
replace orig = "450" if orig == "RDU"
replace orig = "400" if orig == "BNA"
replace orig = "472" if orig == "SMF"
replace orig = "288" if orig == "HOU"
replace orig = "348" if orig == "SNA"
replace orig = "490" if orig == "SJU"
replace orig = "126" if orig == "AUS"
replace orig = "406" if orig == "MSY"
replace orig = "488" if orig == "SJC"
replace orig = "430" if orig == "PIT"
replace orig = "41700" if orig == "SAT"
replace orig = "178" if orig == "CVG"
replace orig = "206" if orig == "DAL"
replace orig = "294" if orig == "IND"
replace orig = "15980" if orig == "RSW"
replace orig = "198" if orig == "CMH"
replace orig = "33100" if orig == "PBI"
replace orig = "10740" if orig == "ABQ"
replace orig = "27260" if orig == "JAX"
replace orig = "278" if orig == "BDL"
replace orig = "160" if orig == "BUF"
replace orig = "27980" if orig == "OGG"
replace orig = "348" if orig == "ONT"
replace orig = "11260" if orig == "ANC"
replace orig = "348" if orig == "BUR"
replace orig = "420" if orig == "OMA"
replace orig = "148" if orig == "PVD"
replace orig = "456" if orig == "RNO"
replace orig = "46060" if orig == "TUS"
replace orig = "416" if orig == "OKC"
replace orig = "47260" if orig == "ORF"
replace orig = "40060" if orig == "RIC"
replace orig = "350" if orig == "SDF"
replace orig = "44060" if orig == "GEG"
replace orig = "21340" if orig == "ELP"
replace orig = "348" if orig == "LGB"
replace orig = "142" if orig == "BHM"
replace orig = "14260" if orig == "BOI"
replace orig = "148" if orig == "MHT"
replace orig = "538" if orig == "TUL"
replace orig = "464" if orig == "ROC"
replace orig = "104" if orig == "ALB"
replace orig = "212" if orig == "DAY"
replace orig = "340" if orig == "LIT"
replace orig = "266" if orig == "GRR"
replace orig = "532" if orig == "SYR"
replace orig = "16700" if orig == "CHS"
replace orig = "408" if orig == "HPN"
replace orig = "218" if orig == "DSM"
replace orig = "17820" if orig == "COS"
replace orig = "408" if orig == "ISP"
replace orig = "268" if orig == "GSO"
replace orig = "438" if orig == "PWM"
replace orig = "314" if orig == "TYS"
replace orig = "496" if orig == "SAV"
replace orig = "396" if orig == "MYR"
replace orig = "184" if orig == "CAK"
replace orig = "358" if orig == "MSN"
replace orig = "556" if orig == "ICT"
replace orig = "348" if orig == "PSP"
replace orig = "37860" if orig == "PNS"
replace orig = "494" if orig == "SRQ"
replace orig = "12100" if orig == "ACY"
replace orig = "276" if orig == "MDT"
replace orig = "273" if orig == "GSP"
replace orig = "15540" if orig == "BTV"
replace orig = "298" if orig == "JAN"
replace orig = "25900" if orig == "ITO"
replace orig = "290" if orig == "HSV"
replace orig = "260" if orig == "FAT"
replace orig = "422" if orig == "SFB"
replace orig = "22220" if orig == "XNA"
replace orig = "22220" if orig == "FYV"
replace orig = "336" if orig == "LEX"
replace orig = "47260" if orig == "PHF"
replace orig = "352" if orig == "LBB"
replace orig = "220" if orig == "FNT"
replace orig = "192" if orig == "CAE"
replace orig = "19340" if orig == "MLI"
replace orig = "16300" if orig == "CID"
replace orig = "274" if orig == "GPT"
replace orig = "372" if orig == "MAF"
replace orig = "21820" if orig == "FAI"
replace orig = "38060" if orig == "IWA"
replace orig = "12620" if orig == "BGR"
replace orig = "10900" if orig == "ABE"
replace orig = "48900" if orig == "ILM"
replace orig = "13380" if orig == "BLI"
replace orig = "11100" if orig == "AMA"
replace orig = "13740" if orig == "BIL"
replace orig = "45300" if orig == "PIE"
replace orig = "42060" if orig == "SBA"
replace orig = "132" if orig == "BTR"
replace orig = "44180" if orig == "SGF"
replace orig = "154" if orig == "HRL"
replace orig = "120" if orig == "AVL"
replace orig = "21660" if orig == "EUG"
replace orig = "244" if orig == "FAR"
replace orig = "14580" if orig == "BZN"
replace dest = "122" if dest == "ATL"
replace dest = "176" if dest == "ORD"
replace dest = "348" if dest == "LAX"
replace dest = "206" if dest == "DFW"
replace dest = "216" if dest == "DEN"
replace dest = "408" if dest == "JFK"
replace dest = "288" if dest == "IAH"
replace dest = "488" if dest == "SFO"
replace dest = "332" if dest == "LAS"
replace dest = "38060" if dest == "PHX"
replace dest = "172" if dest == "CLT"
replace dest = "33100" if dest == "MIA"
replace dest = "422" if dest == "MCO"
replace dest = "408" if dest == "EWR"
replace dest = "220" if dest == "DTW"
replace dest = "378" if dest == "MSP"
replace dest = "500" if dest == "SEA"
replace dest = "428" if dest == "PHL"
replace dest = "148" if dest == "BOS"
replace dest = "408" if dest == "LGA"
replace dest = "548" if dest == "IAD"
replace dest = "548" if dest == "BWI"
replace dest = "33100" if dest == "FLL"
replace dest = "482" if dest == "SLC"
replace dest = "26180" if dest == "HNL"
replace dest = "548" if dest == "DCA"
replace dest = "176" if dest == "MDW"
replace dest = "41740" if dest == "SAN"
replace dest = "45300" if dest == "TPA"
replace dest = "38900" if dest == "PDX"
replace dest = "476" if dest == "STL"
replace dest = "312" if dest == "MCI"
replace dest = "32820" if dest == "MEM"
replace dest = "376" if dest == "MKE"
replace dest = "488" if dest == "OAK"
replace dest = "184" if dest == "CLE"
replace dest = "450" if dest == "RDU"
replace dest = "400" if dest == "BNA"
replace dest = "472" if dest == "SMF"
replace dest = "288" if dest == "HOU"
replace dest = "348" if dest == "SNA"
replace dest = "490" if dest == "SJU"
replace dest = "126" if dest == "AUS"
replace dest = "406" if dest == "MSY"
replace dest = "488" if dest == "SJC"
replace dest = "430" if dest == "PIT"
replace dest = "41700" if dest == "SAT"
replace dest = "178" if dest == "CVG"
replace dest = "206" if dest == "DAL"
replace dest = "294" if dest == "IND"
replace dest = "15980" if dest == "RSW"
replace dest = "198" if dest == "CMH"
replace dest = "33100" if dest == "PBI"
replace dest = "10740" if dest == "ABQ"
replace dest = "27260" if dest == "JAX"
replace dest = "278" if dest == "BDL"
replace dest = "160" if dest == "BUF"
replace dest = "27980" if dest == "OGG"
replace dest = "348" if dest == "ONT"
replace dest = "11260" if dest == "ANC"
replace dest = "348" if dest == "BUR"
replace dest = "420" if dest == "OMA"
replace dest = "148" if dest == "PVD"
replace dest = "456" if dest == "RNO"
replace dest = "46060" if dest == "TUS"
replace dest = "416" if dest == "OKC"
replace dest = "47260" if dest == "ORF"
replace dest = "40060" if dest == "RIC"
replace dest = "350" if dest == "SDF"
replace dest = "44060" if dest == "GEG"
replace dest = "21340" if dest == "ELP"
replace dest = "348" if dest == "LGB"
replace dest = "142" if dest == "BHM"
replace dest = "14260" if dest == "BOI"
replace dest = "148" if dest == "MHT"
replace dest = "538" if dest == "TUL"
replace dest = "464" if dest == "ROC"
replace dest = "104" if dest == "ALB"
replace dest = "212" if dest == "DAY"
replace dest = "340" if dest == "LIT"
replace dest = "266" if dest == "GRR"
replace dest = "532" if dest == "SYR"
replace dest = "16700" if dest == "CHS"
replace dest = "408" if dest == "HPN"
replace dest = "218" if dest == "DSM"
replace dest = "17820" if dest == "COS"
replace dest = "408" if dest == "ISP"
replace dest = "268" if dest == "GSO"
replace dest = "438" if dest == "PWM"
replace dest = "314" if dest == "TYS"
replace dest = "496" if dest == "SAV"
replace dest = "396" if dest == "MYR"
replace dest = "184" if dest == "CAK"
replace dest = "358" if dest == "MSN"
replace dest = "556" if dest == "ICT"
replace dest = "348" if dest == "PSP"
replace dest = "37860" if dest == "PNS"
replace dest = "494" if dest == "SRQ"
replace dest = "12100" if dest == "ACY"
replace dest = "276" if dest == "MDT"
replace dest = "273" if dest == "GSP"
replace dest = "15540" if dest == "BTV"
replace dest = "298" if dest == "JAN"
replace dest = "25900" if dest == "ITO"
replace dest = "290" if dest == "HSV"
replace dest = "260" if dest == "FAT"
replace dest = "422" if dest == "SFB"
replace dest = "22220" if dest == "XNA"
replace dest = "22220" if dest == "FYV"
replace dest = "336" if dest == "LEX"
replace dest = "47260" if dest == "PHF"
replace dest = "352" if dest == "LBB"
replace dest = "220" if dest == "FNT"
replace dest = "192" if dest == "CAE"
replace dest = "19340" if dest == "MLI"
replace dest = "16300" if dest == "CID"
replace dest = "274" if dest == "GPT"
replace dest = "372" if dest == "MAF"
replace dest = "21820" if dest == "FAI"
replace dest = "38060" if dest == "IWA"
replace dest = "12620" if dest == "BGR"
replace dest = "10900" if dest == "ABE"
replace dest = "48900" if dest == "ILM"
replace dest = "13380" if dest == "BLI"
replace dest = "11100" if dest == "AMA"
replace dest = "13740" if dest == "BIL"
replace dest = "45300" if dest == "PIE"
replace dest = "42060" if dest == "SBA"
replace dest = "132" if dest == "BTR"
replace dest = "44180" if dest == "SGF"
replace dest = "154" if dest == "HRL"
replace dest = "120" if dest == "AVL"
replace dest = "21660" if dest == "EUG"
replace dest = "244" if dest == "FAR"
replace dest = "14580" if dest == "BZN"
}

//Complete metro aggregations & distance computations, add labels
destring orig, replace force
destring dest, replace force
drop if orig==. | dest==.
save `temp', replace
collapse (mean) lat_orig long_orig lat_dest long_dest, by(orig dest)
replace lat_orig = lat_orig * (_pi/180)		//Convert degrees to radians
replace long_orig = long_orig * (_pi/180)
replace lat_dest = lat_dest * (_pi/180)
replace long_dest = long_dest * (_pi/180)
gen distance = acos((sin(lat_orig)*sin(lat_dest)) + (cos(lat_orig)*cos(lat_dest)*cos(long_dest-long_orig)))*6371	//Law of Cosines, distance in kilometers
drop lat_orig long_orig lat_dest long_dest
replace distance = 0 if orig==dest  //Correction to ensure distance of a city to itself is zero
save `distance'
clear
use `temp'
if "`legtype'" ~= "" collapse (sum) route first last middle only origdest sdrt business leisure, by(orig dest)
else collapse (sum) route origdest sdrt business leisure, by(orig dest)
merge 1:1 orig dest using `distance'
drop _merge
label define metro 104 "Albany-Schenectady-Amsterdam, NY CSA", add
label define metro 120 "Asheville-Brevard, NC CSA", add
label define metro 122 "Atlanta-Sandy Springs-Gainesville, GA-AL CSA", add
label define metro 126 "Austin-Round Rock-Marble Falls, TX CSA", add
label define metro 132 "Baton Rouge-Pierre Part, LA CSA", add
label define metro 142 "Birmingham-Hoover-Cullman, AL CSA", add
label define metro 148 "Boston-Worcester-Manchester, MA-RI-NH CSA", add
label define metro 154 "Brownsville-Harlingen-Raymondville, TX CSA", add
if "`metro'" == "old" label define metro 160 "Albany-Schenectady-Troy, NY MSA", add		//Code 160 used in both 1999 and 2009 definitions
if "`metro'" == "new" label define metro 160 "Buffalo-Niagara-Cattaraugus, NY CSA", add
label define metro 172 "Charlotte-Gastonia-Salisbury, NC-SC CSA", add
label define metro 176 "Chicago-Naperville-Michigan City, IL-IN-WI CSA", add
label define metro 178 "Cincinnati-Middletown-Wilmington, OH-KY-IN CSA", add
label define metro 184 "Cleveland-Akron-Elyria, OH CSA", add
label define metro 192 "Columbia-Newberry, SC CSA", add
label define metro 198 "Columbus-Marion-Chillicothe, OH CSA", add
label define metro 200 "Albuquerque, NM MSA", add
label define metro 206 "Dallas-Fort Worth, TX CSA", add
label define metro 212 "Dayton-Springfield-Greenville, OH CSA", add
label define metro 216 "Denver-Aurora-Boulder, CO CSA", add
label define metro 218 "Des Moines-Newton-Pella, IA CSA", add
label define metro 220 "Detroit-Warren-Flint, MI CSA", add
label define metro 240 "Allentown-Bethlehem-Easton, PA MSA", add
label define metro 244 "Fargo-Wahpeton, ND-MN CSA", add
label define metro 260 "Fresno-Madera, CA CSA", add
label define metro 266 "Grand Rapids-Muskegon-Holland, MI CSA", add
label define metro 268 "Greensboro--Winston-Salem--High Point, NC CSA", add
label define metro 273 "Greenville-Spartanburg-Anderson, SC CSA", add
label define metro 274 "Gulfport-Biloxi-Pascagoula, MS CSA", add
label define metro 276 "Harrisburg-Carlisle-Lebanon, PA CSA", add
label define metro 278 "Hartford-West Hartford-Willimantic, CT CSA", add
label define metro 288 "Houston-Baytown-Huntsville, TX CSA", add
label define metro 290 "Huntsville-Decatur, AL CSA", add
label define metro 294 "Indianapolis-Anderson-Columbus, IN CSA", add
label define metro 298 "Jackson-Yazoo City, MS CSA", add
label define metro 312 "Kansas City-Overland Park-Kansas City, MO-KS CSA", add
label define metro 314 "Knoxville-Sevierville-La Follette, TN CSA", add
label define metro 320 "Amarillo, TX MSA", add
label define metro 332 "Las Vegas-Paradise-Pahrump, NV CSA", add
label define metro 336 "Lexington-Fayette--Frankfort--Richmond, KY CSA", add
label define metro 340 "Little Rock-North Little Rock-Pine Bluff, AR CSA", add
label define metro 348 "Los Angeles-Long Beach-Riverside, CA CSA", add
label define metro 350 "Louisville/Jefferson County--Elizabethtown--Scottsburg, KY-IN CSA", add
label define metro 352 "Lubbock-Levelland, TX CSA", add
label define metro 358 "Madison-Baraboo, WI CSA", add
label define metro 372 "Midland-Odessa, TX CSA", add
label define metro 376 "Milwaukee-Racine-Waukesha, WI CSA", add
label define metro 378 "Minneapolis-St. Paul-St. Cloud, MN-WI CSA", add
label define metro 380 "Anchorage, AK MSA", add
label define metro 396 "Myrtle Beach-Conway-Georgetown, SC CSA", add
label define metro 400 "Nashville-Davidson--Murfreesboro--Columbia, TN CSA", add
label define metro 406 "New Orleans-Metairie-Bogalusa, LA CSA", add
label define metro 408 "New York-Newark-Bridgeport, NY-NJ-CT-PA CSA", add
label define metro 416 "Oklahoma City-Shawnee, OK CSA", add
label define metro 420 "Omaha-Council Bluffs-Fremont, NE-IA CSA", add
label define metro 422 "Orlando-Deltona-Daytona Beach, FL CSA", add
label define metro 428 "Philadelphia-Camden-Vineland, PA-NJ-DE-MD CSA", add
label define metro 430 "Pittsburgh-New Castle, PA CSA", add
label define metro 438 "Portland-Lewiston-South Portland, ME CSA", add
label define metro 450 "Raleigh-Durham-Cary, NC CSA", add
label define metro 456 "Reno-Sparks-Fernley, NV CSA", add
label define metro 464 "Rochester-Batavia-Seneca Falls, NY CSA", add
label define metro 472 "Sacramento--Arden-Arcade--Yuba City, CA-NV CSA", add
label define metro 476 "St. Louis-St. Charles-Farmington, MO-IL CSA", add
label define metro 480 "Asheville, NC MSA", add
label define metro 482 "Salt Lake City-Ogden-Clearfield, UT CSA", add
label define metro 488 "San Jose-San Francisco-Oakland, CA CSA", add
label define metro 490 "San Juan-Caguas-Fajardo, PR CSA", add
label define metro 494 "Sarasota-Bradenton-Punta Gorda, FL CSA", add
label define metro 496 "Savannah-Hinesville-Fort Stewart, GA CSA", add
label define metro 500 "Seattle-Tacoma-Olympia, WA CSA", add
label define metro 520 "Atlanta, GA MSA", add
label define metro 532 "Syracuse-Auburn, NY CSA", add
label define metro 538 "Tulsa-Bartlesville, OK CSA", add
label define metro 548 "Washington-Baltimore-Northern Virginia, DC-MD-VA-WV CSA", add
label define metro 556 "Wichita-Winfield, KS CSA", add
label define metro 640 "Austin-San Marcos, TX MSA", add
label define metro 730 "Bangor, ME MSA", add
label define metro 760 "Baton Rouge, LA MSA", add
label define metro 860 "Bellingham, WA MSA", add
label define metro 880 "Billings, MT MSA", add
label define metro 920 "Biloxi-Gulfport-Pascagoula, MS MSA", add
label define metro 1000 "Birmingham, AL MSA", add
label define metro 1080 "Boise City, ID MSA", add
label define metro 1122 "Boston-Worcester-Lawrence, MA-NH-ME-CT CMSA", add
label define metro 1240 "Brownsville-Harlingen-San Benito, TX MSA", add
label define metro 1280 "Buffalo-Niagara Falls, NY MSA", add
label define metro 1305 "Burlington, VT MSA", add
label define metro 1360 "Cedar Rapids, IA MSA", add
label define metro 1440 "Charleston-North Charleston, SC MSA", add
label define metro 1520 "Charlotte-Gastonia-Rock Hill, NC-SC MSA", add
label define metro 1602 "Chicago-Gary-Kenosha, IL-IN-WI CMSA", add
label define metro 1642 "Cincinnati-Hamilton, OH-KY-IN CMSA", add
label define metro 1692 "Cleveland-Akron, OH CMSA", add
label define metro 1720 "Colorado Springs, CO MSA", add
label define metro 1760 "Columbia, SC MSA", add
label define metro 1840 "Columbus, OH MSA", add
label define metro 1922 "Dallas-Fort Worth, TX CMSA", add
label define metro 1960 "Davenport-Moline-Rock Island, IA-IL MSA", add
label define metro 2000 "Dayton-Springfield, OH MSA", add
label define metro 2082 "Denver-Boulder-Greeley, CO CMSA", add
label define metro 2120 "Des Moines, IA MSA", add
label define metro 2162 "Detroit-Ann Arbor-Flint, MI CMSA", add
label define metro 2320 "El Paso, TX MSA", add
label define metro 2400 "Eugene-Springfield, OR MSA", add
label define metro 2520 "Fargo-Moorhead, ND-MN MSA", add
label define metro 2580 "Fayetteville-Springdale-Rogers, AR MSA", add
label define metro 2700 "Fort Myers-Cape Coral, FL MSA", add
label define metro 2840 "Fresno, CA MSA", add
label define metro 3000 "Grand Rapids-Muskegon-Holland, MI MSA", add
label define metro 3120 "Greensboro--Winston-Salem--High Point, NC MSA", add
label define metro 3160 "Greenville-Spartanburg-Anderson, SC MSA", add
label define metro 3240 "Harrisburg-Lebanon-Carlisle, PA MSA", add
label define metro 3280 "Hartford, CT MSA", add
label define metro 3320 "Honolulu, HI MSA", add
label define metro 3362 "Houston-Galveston-Brazoria, TX CMSA", add
label define metro 3440 "Huntsville, AL MSA", add
label define metro 3560 "Jackson, MS MSA", add
label define metro 3600 "Jacksonville, FL MSA", add
label define metro 3760 "Kansas City, MO-KS MSA", add
label define metro 3840 "Knoxville, TN MSA", add
label define metro 4120 "Las Vegas, NV-AZ MSA", add
label define metro 4280 "Lexington, KY MSA", add
label define metro 4400 "Little Rock-North Little Rock, AR MSA", add
label define metro 4472 "Los Angeles-Riverside-Orange County, CA CMSA", add
label define metro 4520 "Louisville, KY-IN MSA", add
label define metro 4600 "Lubbock, TX MSA", add
label define metro 4720 "Madison, WI MSA", add
label define metro 4920 "Memphis, TN-AR-MS MSA", add
label define metro 4992 "Miami-Fort Lauderdale, FL CMSA", add
label define metro 5082 "Milwaukee-Racine, WI CMSA", add
label define metro 5120 "Minneapolis-St. Paul, MN-WI MSA", add
label define metro 5330 "Myrtle Beach, SC MSA", add
label define metro 5360 "Nashville, TN MSA", add
label define metro 5560 "New Orleans, LA MSA", add
label define metro 5602 "New York-Northern New Jersey-Long Island, NY-NJ-CT-PA CMSA", add
label define metro 5720 "Norfolk-Virginia Beach-Newport News, VA-NC MSA", add
label define metro 5800 "Odessa-Midland, TX MSA", add
label define metro 5880 "Oklahoma City, OK MSA", add
label define metro 5920 "Omaha, NE-IA MSA", add
label define metro 5960 "Orlando, FL MSA", add
label define metro 6080 "Pensacola, FL MSA", add
label define metro 6162 "Philadelphia-Wilmington-Atlantic City, PA-NJ-DE-MD CMSA", add
label define metro 6200 "Phoenix-Mesa, AZ MSA", add
label define metro 6280 "Pittsburgh, PA MSA", add
label define metro 6400 "Portland, ME MSA", add
label define metro 6442 "Portland-Salem, OR-WA CMSA", add
label define metro 6480 "Providence-Fall River-Warwick, RI-MA MSA", add
label define metro 6640 "Raleigh-Durham-Chapel Hill, NC MSA", add
label define metro 6720 "Reno, NV MSA", add
label define metro 6760 "Richmond-Petersburg, VA MSA", add
label define metro 6840 "Rochester, NY MSA", add
label define metro 6922 "Sacramento-Yolo, CA CMSA", add
label define metro 7040 "St. Louis, MO-IL MSA", add
label define metro 7160 "Salt Lake City-Ogden, UT MSA", add
label define metro 7240 "San Antonio, TX MSA", add
label define metro 7320 "San Diego, CA MSA", add
label define metro 7362 "San Francisco-Oakland-San Jose, CA CMSA", add
label define metro 7442 "San Juan-Caguas-Arecibo, PR CMSA", add
label define metro 7480 "Santa Barbara-Santa Maria-Lompoc, CA MSA", add
label define metro 7510 "Sarasota-Bradenton, FL MSA", add
label define metro 7520 "Savannah, GA MSA", add
label define metro 7602 "Seattle-Tacoma-Bremerton, WA CMSA", add
label define metro 7840 "Spokane, WA MSA", add
label define metro 7920 "Springfield, MO MSA", add
label define metro 8160 "Syracuse, NY MSA", add
label define metro 8280 "Tampa-St. Petersburg-Clearwater, FL MSA", add
label define metro 8520 "Tucson, AZ MSA", add
label define metro 8560 "Tulsa, OK MSA", add
label define metro 8872 "Washington-Baltimore, DC-MD-VA-WV CMSA", add
label define metro 8960 "West Palm Beach-Boca Raton, FL MSA", add
label define metro 9040 "Wichita, KS MSA", add
label define metro 9200 "Wilmington, NC MSA", add
label define metro 10740 "Albuquerque, NM MSA", add
label define metro 10900 "Allentown-Bethlehem-Easton, PA-NJ MSA", add
label define metro 11100 "Amarillo, TX MSA", add
label define metro 11260 "Anchorage, AK MSA", add
label define metro 12100 "Atlantic City-Hammonton, NJ MSA", add
label define metro 12620 "Bangor, ME MSA", add
label define metro 13380 "Bellingham, WA MSA", add
label define metro 13740 "Billings, MT MSA", add
label define metro 14260 "Boise City-Nampa, ID MSA", add
label define metro 14580 "Bozeman, MT MiSA", add
label define metro 15540 "Burlington-South Burlington, VT MSA", add
label define metro 15980 "Cape Coral-Fort Myers, FL MSA", add
label define metro 16300 "Cedar Rapids, IA MSA", add
label define metro 16700 "Charleston-North Charleston-Summerville, SC MSA", add
label define metro 17820 "Colorado Springs, CO MSA", add
label define metro 19340 "Davenport-Moline-Rock Island, IA-IL MSA", add
label define metro 21340 "El Paso, TX MSA", add
label define metro 21660 "Eugene-Springfield, OR MSA", add
label define metro 21820 "Fairbanks, AK MSA", add
label define metro 22220 "Fayetteville-Springdale-Rogers, AR-MO MSA", add
label define metro 25900 "Hilo, HI MiSA", add
label define metro 26180 "Honolulu, HI MSA", add
label define metro 27260 "Jacksonville, FL MSA", add
label define metro 27980 "Kahului-Wailuku, HI MiSA", add
label define metro 32820 "Memphis, TN-MS-AR MSA", add
label define metro 33100 "Miami-Fort Lauderdale-Pompano Beach, FL MSA", add
label define metro 37860 "Pensacola-Ferry Pass-Brent, FL MSA", add
label define metro 38060 "Phoenix-Mesa-Glendale, AZ MSA", add
label define metro 38900 "Portland-Vancouver-Hillsboro, OR-WA MSA", add
label define metro 40060 "Richmond, VA MSA", add
label define metro 41700 "San Antonio-New Braunfels, TX MSA", add
label define metro 41740 "San Diego-Carlsbad-San Marcos, CA MSA", add
label define metro 42060 "Santa Barbara-Santa Maria-Goleta, CA MSA", add
label define metro 44060 "Spokane, WA MSA", add
label define metro 44180 "Springfield, MO MSA", add
label define metro 45300 "Tampa-St. Petersburg-Clearwater, FL MSA", add
label define metro 46060 "Tucson, AZ MSA", add
label define metro 47260 "Virginia Beach-Norfolk-Newport News, VA-NC MSA", add
label define metro 48900 "Wilmington, NC MSA", add
label values orig metro
label values dest metro
}
//=== END METROPOLITAN AREA AGGREGATION SYNTAX ===

//Remove variable labels, obtain estimated passenger counts, and save edgelist
label variable orig
label variable dest 
label variable route
label variable origdest
label variable sdrt
label variable business
label variable leisure
if "`legtype'" ~= "" {
	label variable first
	label variable last
	label variable middle
	label variable only
	}
foreach network of varlist route-leisure {
	replace `network' = `network' * 10
	}
compress
save airnet`stub'.dta, replace

//===BEGIN INTERNATIONAL DATA SYNTAX ===
if `intl' ~= 0 {
gen routeintl = route
save airnet`stub'.dta, replace
infile routeintl str3 (orig dest) quarter x in 2/l using intl`stub'.csv, clear
keep if quarter == `intl'
drop quarter x
collapse (sum) routeintl, by(orig dest)  //combine records for different carriers between same orig/dest pair
drop if routeintl == 0
append using airnet`stub'.dta
save airnet`stub'.dta, replace
keep orig dest				//insert missing dyads
stack orig dest, into(dest) clear
drop _stack
duplicates drop
save `temp', replace
rename dest orig
cross using `temp'
merge 1:m orig dest using airnet`stub'.dta
drop _merge
egen orig_sum = total(route), by(orig) missing  //in routeintl, code intl pairs (structural 0s) as missing
egen dest_sum = total(route), by(dest) missing
replace routeintl = 0 if routeintl == . & ~(orig_sum==. & dest_sum==.)
drop orig_sum dest_sum
compress
save airnet`stub'.dta, replace
if "`matrix'" ~= "" {
	foreach network of varlist route routeintl origdest business leisure {
	clear
	use airnet`stub'.dta
	keep orig dest `network'
	if "`network'" ~= "routeintl" drop if `network' == .
	reshape wide `network', i(orig) j(dest) string
	outsheet using `network'`stub'.csv, comma nonames
	}
	}
}
//===END INTERNATIONAL DATA SYNTAX ===

//Export matrices, if requested
if "`matrix'" ~= "" & `intl' == 0 {
	foreach network of varlist route origdest business leisure {
	clear
	use airnet`stub'.dta
	keep orig dest `network'
	if "`metro'" == "" reshape wide `network', i(orig) j(dest) string
	else reshape wide `network', i(orig) j(dest)
	outsheet using `network'`stub'.csv, comma nonames
	}
	if "`metro'" ~= "" {
	clear
	use airnet`stub'.dta
	keep orig dest distance
	if "`metro'" == "" reshape wide distance, i(orig) j(dest) string
	outsheet using distance`stub'.csv, comma nonames
	}

}

if "`descriptives'" ~= "" {
	timer off 1
	timer list
	return scalar time = r(t1)
	}

//restore
}
end


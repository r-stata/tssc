*! version on 0.1 29mar2011

* Thanks to Kit for suggesting a stata-ish array
* Wouldn't it be nice if stata had perl style hashes: $code{BRD} => "314922f1d7121efc4cd0e4c915113ad2"

/*
   The Board of Governors of the Federal Reserve Board website 
   http://www.federalreserve.gov is a good example of data provisioning.
   They support SDMX, automated systems etc. If you want to know more
   use the site. This program is for stata users who want to acquire 
   data online.
   http://www.federalreserve.gov/datadownload/Output.aspx? 	*no stata user exposure
   rel=H10 & 	   											*no stata user exposure
   series=bffd94e6e03cd78961a5074a37c634bf &  				*these are the comparison baskets
   											 				* defaults to EUR.
   lastObs=7 & 	   											* expose as last(), assume it per 
   				   											* default and set it equal to 7.
   from= & 		  											* expose as from()
   to= &           											* expose as to()
   filetype=csv &  											*no stata user exposure
   label=include & 											*no stata user exposure
   layout=seriescolumn 										*no stata user exposure
   
   usd anything(name=basket), [last(integer)] [from(string)] [to(string)]
   
*/

program def usd, rclass
version 9.0
syntax anything(name=basket)
 quietly {
	local out = 0
	set more off
	local url = "http://www.federalreserve.gov/datadownload/Output.aspx"
	local hidden = "filetype=csv&label=include&layout=seriescolumn&rel=H10"
	local bailout = 1

	 *Broad currency index (Mar 73 = 100)
	 local series1  "314922f1d7121efc4cd0e4c915113ad2"
     *Major currency index (Mar 73 = 100)
	 local series2  "a660e724c705cea4b7bd1d1b85789862"
     *OITP currency index (Jan 97 = 100)
 	 local series3  "fac88a7fcbe51b58144e39a6ab770cdb"
     *Australia / U.S. Dollars per Australian Dollar
	 local series4 "91c3fa18b51a37d6c8bb96f5263c9409"
 	 *Brazil / Real
	 local series5  "e9ee4ef1e0a912f189d364c8ae586f31"
	 *Canada / Canadian Dollar
	 local series6  "8dbf1cd36883b94bdd6d7ff96c9eed66"
	 *China / Yuan Renminbi
	 local series7  "356f2a973bbb516442c693dc19615b69"
	 *Denmark / Danish Krone
	 local series8  "a3220d269bb3c9c5e2fffa49160c8cdf"
	 *Euro Area / U.S. Dollars per Euro
	 local series9  "15ba55e8f5302d7efe51819c57682787"
	 *Hong Kong / Hong Kong Dollar
	 local series10 = "936452568eda89add10d8be1614fde14"
	 *India / Indian Rupee
	 local series11 "3604f6e0c01fd1a3275b2de1f6547cb6"
	 *Japan / Yen
 	 local series12  "1e182bb4a226cda2b7a8593472bac48f" 
	 *Maldives / Rufiyaa
 	 local series13  "04f721fc401aafb906314b10a4a4148e"
	 *Mexico / Mexican Peso
     local series14  "b23e56a43a4fe0a996e9e2418bdbc2a8"
	 *New Zealand / U.S. Dollars per New Zealand Dollar
 	 local series15 "9493da55f17cfd1c95661ed788dc57ea"
	 *Norway / Norwegian Krone
 	 local series16 "18213d9f27127cedf21ea205d9ecfbde"
	 *Singapore / Singapore Dollar
 	 local series17 "35a6a2ef41f1533f6b3ccf4ea1560478"
	 *South Africa / Rand (financial)
 	 local series18 "6462f3e1922d7c78bb07d6548e96c35d"
	 *South Korea / Republic of Korean Won
	 local series19 "fe4164996f92a3285ff9270a1e964d09"
	 *Sri Lanka / Sri Lankan Rupee
	 local series20 "3b13f2441d71604b1ccde2b75d8faf20"
	 *Sweden / Swedish Krona
	 local series21 "ef04041e538b0a622a77e9ba98cded0d"
	 *Switzerland / Swiss Franc
	 local series22  "f838388dca2fd4e8bdfb846f3d2c35df"
	 *Taiwan / Taiwan Dollar
	 local series23 "b0919b362d9db43d59ed03dea48a4c2f"
	 *Thailand / Baht
	 local series24 "3b80d38ac8a348cc4bb83da02413219f"
	 *United Kingdom / U.S Dollars per Pound Sterling
	 local series25 "3777001afbcc5b173e81a2055241b679"
	 *Venezuela / Bolivar
	 local series26 "43571458390b748e2c7a855985efcac7"


	loc codes BRD MJC OIT AUD BRL CAD CNY DKK EUR HKD INR JPY MVR MXN NZD NOK SGD ZAL KRW LKR SEK CHF TWD THB GBP VEB
	loc nc: word count `codes'
	forv i=1/`nc' {
		loc c: word `i' of `codes'
		if regexm(upper("`basket'"), "`c'") {
			loc series `series`i''
			loc bailout 0
		}
	}
 }
 
	if `bailout' {
	 di "Say something like {stata usd EUR: usd EUR}. Perhaps read {stata help usd: help usd}?" as smcl
	 error 198
	 exit
	}
quietly{
	*now we have the comparison currency. ready to get the data.
	tempfile raw
	copy "`url'?`hidden'&lastObs=`last'&from=`from'&to=`to'&series=`series'" `raw'
	insheet using `raw'
	local tmp = v2[1]
	label data `"`tmp'"'
	*we return the metadata
	forvalues i=1(1)6 {
	  local a = v1[`i'] 
	 local b = v2[`i'] 
	 local c = `"`a' `b'"'
	 return local md`i' = `"`c'"'
	}
	keep if _n >6
	rename v2 rate
	replace rate = regexr(rate,"ND",".")
	destring rate, replace
	split v1,parse(-)
	gen y=v11
	gen m=v12
	gen d=v13
	destring y, replace
	destring m, replace
	destring d, replace
	destring v11, replace
	destring v12, replace
	destring v13, replace
	gen date = mdy(v12,v13,v11)
	format date %td
	drop v*
	label var rate "`basket'"
}
end








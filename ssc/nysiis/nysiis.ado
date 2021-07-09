
********************************************************************************
* Adrian Sayers
* 7th November 2014
* adrian.sayers@Bristol.ac.uk
* NYSIIS.ado file
* Implements the nysiis phonetic name coding described in :
* Data Quality and Record Linkage Techniques, Herzog T.N. ,	Scheuren F.J. , Winkler W.E. 2007 pg 119-121
* Originally Describe by Robert L. Taft, "Name Search Techniques", New York State Identification and Intelligence System.  
* 
* I have never seen the original Taft book. 
*NB: This comes with no warranty intended or implied and user should check results against other codes i.e. soundex()
*N.B. Many different algorithms on the web, however many don't appear to function correctly.
*Even the example from this book suggests SCHMIDT should code to SNAT, however the dt will be recoded to d therefore this is incorrect.

* Edited by Matthew Curtis 
* 7/11/2018
* mjdcurtis@gmail.com
* Fixed step 5 j and k
* Fixed OCR artifacts in comments
********************************************************************************

version 13.1
	cap prog drop nysiis
		prog define nysiis , rclass
		
		syntax  varlist (max=1 string) [if] [in],	[GENerate(string) Noisily ]
		
		if "`noisily'"!="" {
			timer clear
			timer on 1
				}
		
	*** generate variable name 
    if `"`generate'"' == "" local generate "nysiis"
    confirm new variable `generate'
quietly {
***********************************
*  Lower all the strings
***********************************
tempvar phase0
	gen `phase0' =lower(`varlist')

********************************************************************************	
* Step 1: Change the initial letter(s) of the surname as indicated in the table 
*         below:
********************************************************************************	
	foreach pair in "mac mcc" "kn nn" "k c" "ph ff" "pf ff" "sch sss" {
	tokenize `pair'	
		replace `phase0' = subinstr(`phase0',"`1'","`2'",1) if strpos(`phase0',"`1'")==1	//  the order results in non-consecutive replacements
			}
*list name `phase0'
if "`noisily'"!="" {
	timer off 1
	timer list 1
	noisily di "Step 1/8 Complete, elapsed= `r(t1)'"
	timer on 1
		}
********************************************************************************
* Step 2: Change the last letter(s) of the surname as indicated in the table
* 		  below.
********************************************************************************
foreach pair in "ee y" "ie y" "dt d" "rt d" "rd d" "nt d" "nd d" {
	tokenize `pair'
		replace `phase0' = reverse(subinstr(reverse(`phase0'),reverse("`1'"),"`2'",1)) if  strpos(reverse(`phase0'),reverse("`1'"))==1  	// the order results in non-consecutive replacements
			}
			
if "`noisily'"!="" {
	timer off 1
	timer list 1
	noisily di "Step 2/8 Complete, elapsed=`r(t1)'"
	timer on 1
		}			
* list name `phase0'
			
********************************************************************************
* 3.  Step 3: The first character of the NYSIIS-coded surname is the first 
*	  letter of the	(possibly altered) surname.
********************************************************************************

tempvar nysiis_1
	gen str `nysiis_1' = substr(`phase0',1,1)
	
	if "`noisily'"!="" {
	timer off 1
	timer list 1
	noisily di "Step 3/8 Complete, elapsed=`r(t1)'"
	timer on 1
		}
* list name `phase0' `nysiis_1'	
********************************************************************************
*  Step 4 : Position the Pointer at the second letter of the 
*			(possibly altered) surname
********************************************************************************
tempvar strlength 
	gen `strlength'= length(`phase0')
		su `strlength'
			local maxlength = r(max)
				drop `strlength'
				
	tempvar exoneperm
		gen byte `exoneperm'=.
	
	tempvar phase0prev
		gen `phase0prev'=""

if "`noisily'"!="" {
	timer off 1
	timer list 1
	noisily di "Step 4/8 Complete, elapsed=`r(t1)'"
	timer on 1
		}		

*list name `phase0' `phase0prev' `exoneperm' 
*pause		
	forvalues i = 2 /`maxlength' { 												// Remember starting at position 2
	
	tempvar ex_one 
		gen byte `ex_one' =.
*list name `phase0' `phase0prev' `exoneperm' `ex_one'
*pause		
		
********************************************************************************
*  Step 5 (a to i) : (Change the current letter(s) of the surname i.e., the 
*			one at the present position of the Pointer) Execute exactly one  
*			of the following operations, proceeding from top to bottom
********************************************************************************

* a) if blank go to step 7
		replace `phase0' = `phase0' 	if substr(`phase0',`i',1)==" " | substr(`phase0',`i',1)==""
		replace `exoneperm'=1 			if (substr(`phase0',`i',1)==" " | substr(`phase0',`i',1)=="") & `exoneperm'==.
		
* b) If the current letter is E and the next letter is V then change EV to AF.
		replace `phase0prev' = `phase0'															// Store an unchanged string
		replace `phase0' = substr(`phase0',1,(`i'-1)) + "af" + substr(`phase0',(`i'+2),.) 		/// split string and recombine
							if (substr(`phase0',`i',1)=="e" & substr(`phase0',(`i'+1),1)=="v") 	/// if current ==e and current+1 ==v
								& `ex_one'==.  & `exoneperm'==.									//	Not been executed previously
								
		replace `ex_one'= 1 if (substr(`phase0prev',`i',1)=="e" & substr(`phase0prev',(`i'+1),1)=="v") 	/// if current ==e and current+1 ==v
								& `ex_one'==.  & `exoneperm'==.											//
* c) Change a vowel AEIOU to A							
		
	foreach vowel in a e i o u {
		replace `phase0prev' = `phase0'															// Store an unchanged string
		replace `phase0' =  substr(`phase0',1,(`i'-1)) + "a" + substr(`phase0',(`i'+1),.) 		/// split string and recombine
							if  substr(`phase0',`i',1)=="`vowel'"								/// if current equal to a vowel
							& `ex_one'==.  & `exoneperm'==.										//  Not been executed previously
							
		replace `ex_one'= 1 if  substr(`phase0prev',`i',1)=="`vowel'"							/// if current equal to a vowel
							& `ex_one'==.  & `exoneperm'==.										//  Not been executed previously					
								}
* d,e,f) Change Q to G, Z to S, M to N
	foreach pair in "q g" "z s" "m n" {
		tokenize `pair'
		replace `phase0prev' = `phase0'															// Store an unchanged string
		replace `phase0' =  substr(`phase0',1,(`i'-1)) + "`2'" + substr(`phase0',(`i'+1),.) 	/// split string and recombine
							if  substr(`phase0',`i',1)=="`1'"									/// if current equal to a vowel
							& `ex_one'==.  & `exoneperm'==.										//  Not been executed previously
							
		replace `ex_one'= 1 if  substr(`phase0prev',`i',1)=="`1'"								/// if current equal to a vowel
							& `ex_one'==.  & `exoneperm'==.										//  Not been executed previously					
								}

* g) If the current letter is the letter K then change K to C unless the next
* 	 letter is N. If K is followed by N then replace KN by N.
		*KN->N
		replace `phase0prev' = `phase0'															// Store an unchanged string
		replace `phase0' = substr(`phase0',1,(`i'-1)) + "n" + substr(`phase0',(`i'+2),.) 		/// split string and recombine
							if (substr(`phase0',`i',1)=="k" & substr(`phase0',(`i'+1),1)=="n") 	/// if current ==k and current+1 ==n
								& `ex_one'==.  & `exoneperm'==.									//	Not been executed previously
								
		replace `ex_one'= 1 if (substr(`phase0prev',`i',1)=="k" & substr(`phase0prev',(`i'+1),1)=="n") 	/// if current ==e and current+1 ==v
								& `ex_one'==.  & `exoneperm'==.									//
		*K->C						
		replace `phase0prev' = `phase0'															// Store an unchanged string
		replace `phase0' = substr(`phase0',1,(`i'-1)) + "c" + substr(`phase0',(`i'+1),.) 		/// split string and recombine
							if  substr(`phase0',`i',1)=="k" 									/// if current ==k and current+1 ==n
								& `ex_one'==.  & `exoneperm'==.									//	Not been executed previously
								
		replace `ex_one'= 1 if  substr(`phase0prev',`i',1)=="k" 								/// if current ==e and current+1 ==v
								& `ex_one'==.  & `exoneperm'==.									//
						
								
								
								
* h) Change SCH to SSS.
		replace `phase0prev' = `phase0'															// Store an unchanged string
		replace `phase0' = substr(`phase0',1,(`i'-1)) + "sss" + substr(`phase0',(`i'+3),.) 		/// split string and recombine
							if (substr(`phase0',`i',1)=="s" & substr(`phase0',(`i'+1),1)=="c" & substr(`phase0',(`i'+2),1)=="h")  	/// if current ==s, current+1 ==c, and current+2=h 
								& `ex_one'==.  & `exoneperm'==.									//	Not been executed previously
								
		replace `ex_one'= 1 if (substr(`phase0',`i',1)=="s" & substr(`phase0',(`i'+1),1)=="c" & substr(`phase0',(`i'+2),1)=="h") 	/// if current ==s, current+1 ==c, and current+2=h 
								& `ex_one'==.  & `exoneperm'==.									//

* i) Change PH FF.
		replace `phase0prev' = `phase0'															// Store an unchanged string
		replace `phase0' = substr(`phase0',1,(`i'-1)) + "ff" + substr(`phase0',(`i'+2),.) 		/// split string and recombine
							if (substr(`phase0',`i',1)=="p" & substr(`phase0',(`i'+1),1)=="h") 	/// if current ==k and current+1 ==n
								& `ex_one'==.  & `exoneperm'==.									//	Not been executed previously
								
		replace `ex_one'= 1 if (substr(`phase0prev',`i',1)=="p" & substr(`phase0prev',(`i'+1),1)=="h") 	/// if current ==e and current+1 ==v
								& `ex_one'==.  & `exoneperm'==.											
								
* j) if H is preceded by or followed by a letter that is not a vowel (AEIOU), 
*		then replace the current letter in the surname by the preceding letter.							
		replace `phase0prev' = `phase0'															// Store an unchanged string

		replace `phase0'  = (	substr(`phase0', 1,(`i'-1)) +  					///
								substr(`phase0',(`i'-1),1) + 					///
								substr(`phase0',(`i'+1) ,.)) 					/// split string before and after letter  and replace with previous
								   if (((substr(`phase0',(`i'-1),1)!="a") & 	///
										(substr(`phase0',(`i'-1),1)!="e") & 	///
										(substr(`phase0',(`i'-1),1)!="i") & 	///
										(substr(`phase0',(`i'-1),1)!="o") & 	///
										(substr(`phase0',(`i'-1),1)!="u") )		/// If previous not a vowel
									| 											/// OR
									    ((substr(`phase0',(`i'+1),1)!="a") & 	///
										 (substr(`phase0',(`i'+1),1)!="e") & 	///
										 (substr(`phase0',(`i'+1),1)!="i") & 	/// 
										 (substr(`phase0',(`i'+1),1)!="o") & 	///
										 (substr(`phase0',(`i'+1),1)!="u") &	///
										 (substr(`phase0',(`i'+1),1)!="") ) )	/// Next is not a vowel
									&    (substr(`phase0',`i',1)=="h")			///  and current position is an h
									& 	`ex_one'==.  & `exoneperm'==.			// and operation not previously executed
									
		replace `ex_one' = 1														/// Indicator to mark substitution
								   if (((substr(`phase0prev',(`i'-1),1)!="a") & 	///
										(substr(`phase0prev',(`i'-1),1)!="e") & 	///
										(substr(`phase0prev',(`i'-1),1)!="i") & 	///
										(substr(`phase0prev',(`i'-1),1)!="o") & 	///
										(substr(`phase0prev',(`i'-1),1)!="u") )		/// If previous not a vowel
									| 											/// OR
									    ((substr(`phase0prev',(`i'+1),1)!="a") & 	///
										 (substr(`phase0prev',(`i'+1),1)!="e") & 	///
										 (substr(`phase0prev',(`i'+1),1)!="i") & 	/// 
										 (substr(`phase0prev',(`i'+1),1)!="o") & 	///
										 (substr(`phase0',(`i'+1),1)!="u") &		///
										 (substr(`phase0',(`i'+1),1)!="") ) )		/// Next is not a vowel
									&    (substr(`phase0prev',`i',1)=="h")			///  and current position is an h
									& 	`ex_one'==.	 & `exoneperm'==.				// and operation not previously executed

* k) 	If W is preceded by a vowel, then replace the current letter 
* 		in the surname with the preceding letter.
		replace `phase0prev' = `phase0'												// Store an unchanged string
		replace `phase0'  = (	substr(`phase0', 1,(`i'-1)) +  					///
								substr(`phase0',(`i'-1),1) + 					/// 
								substr(`phase0',(`i'+1) ,.)) 					/// split string before and after letter  and replace with previous
								if  ((substr(`phase0',(`i'-1),1)=="a") | ///
									(substr(`phase0',(`i'-1),1)=="e") |  ///
									(substr(`phase0',(`i'-1),1)=="i") |  ///
									(substr(`phase0',(`i'-1),1)=="o") |  ///
									(substr(`phase0',(`i'-1),1)=="u") )  /// If previous IS a vowel
									&   (substr(`phase0',`i',1)=="w")			///  and current position is an w
									& 	`ex_one'==.  & `exoneperm'==.			// and operation not previously executed
									
		replace `ex_one' = 1														/// Indicator to mark substitution
								    if  ((substr(`phase0',(`i'-1),1)=="a") | ///
										(substr(`phase0',(`i'-1),1)=="e") |  ///
										(substr(`phase0',(`i'-1),1)=="i") |  ///
										(substr(`phase0',(`i'-1),1)=="o") |  ///
										(substr(`phase0',(`i'-1),1)=="u") )  /// If previous IS a vowel
									&   (substr(`phase0prev',`i',1)=="w")			///  and current position is an w
									& 	`ex_one'==.	 & `exoneperm'==.				// and operation not previously executed																	
********************************************************************************
* Step 6: The next character of the NYSIIS code is the current position letter in
* the surname after completing Step 5 (but omitting a letter that is equal to the
* last character already placed in the code)
* n.b. Remove the duplicates characters after rebuilding the code
********************************************************************************

tempvar nysiis_`i' 
	gen `nysiis_`i''= substr(`phase0',`i',1)
	
* After putting a character into the code, move the pointer forward to the next
* letter of the surname. Then return to Step 5.
* n.b. return to the begining of the loop.

if "`noisily'"!="" {
	timer off 1
	timer list 1
	noisily di "Step 5/8 ,`i' of `maxlength' characters complete elapsed = `r(t1)' "
	timer on 1
			}	
											} // End max string length
											
										
********************************************************************************											
* Step 6 continued: Rebuild the nysiis key and remove repeated characters
********************************************************************************
tempvar nysiis_key
	gen `nysiis_key'=""
		forvalues i = 1 / `maxlength' {
			replace `nysiis_key'= `nysiis_key' + `nysiis_`i''
									}
											
tempvar nysiis_length 
	gen `nysiis_length'= length(`nysiis_key')
		su `nysiis_length' , meanonly
			local nysiismaxlen = r(max)
				drop `nysiis_length'
 			 forvalues i =`nysiismaxlen' (-1) 1 {
					replace `nysiis_key' = substr(`nysiis_key',1,(`i'-1)) + substr(`nysiis_key',(`i'+1),.)  if substr(`nysiis_key',`i',1)==substr(`nysiis_key',(`i'-1),1)
											}											
	if "`noisily'"!="" {
	timer off 1
	timer list 1
	noisily di "Step 6/8 Complete, elapsed=`r(t1)'"
	timer on 1
		}											
********************************************************************************
* Step 7 : (Change the last character(s) of the NYSIIS-coded surname.) If the last
* two characters of the NYSIIS-coded surname are AY then replace AY by
* Y. If the last character of the NYSIIS-coded surname is either S or A
* then delete it
********************************************************************************
* a) Last AY -> A
replace `nysiis_key'= reverse(subinstr(reverse(`nysiis_key') ,reverse("ay"),"y",1)	) if strpos(reverse(`nysiis_key'),reverse("ay"))==1

* b) Last S -> Delete
 replace  `nysiis_key' = reverse(subinstr(reverse(`nysiis_key') ,"s","",1)	) if strpos(reverse(`nysiis_key'),"s")==1
* c) Last A -> Delete
  replace `nysiis_key' = reverse(subinstr(reverse(`nysiis_key') ,"a","",1)	)  if strpos(reverse(`nysiis_key'),"a")==1

  	if "`noisily'"!="" {
	timer off 1
	timer list 1
	noisily di "Step 7/8 Complete, elapsed = `r(t1)'"
	timer on 1
		}
********************************************************************************
* 10. Create A permanent variable
********************************************************************************
  
   gen `generate' = `nysiis_key'
   	if "`noisily'"!="" {
	timer off 1 
	timer list 1
	noisily di "NYSIIS Complete, Total elapsed = `r(t1)'"
	timer off 1
		}
		} // End quietly							
return local nysiis "`generate'"
end

* Test names
 /*
	clear 
	set obs 53 
	gen name =""
	local i = 1
	foreach name in  "Macintosh" "Knuth" "koehn" "phillipson" "pfeister" "schoenhoeft" "mckee" "mackie" "heitschmidt" "bart" "hurd" "hunt" "westerlund" ///
	"casstevens" "vasquez" "frasier" "frazer"  "bowman" "mcknight" "mcnight" "rickert" "deutsch" "westphal" "shriver" "kuhl" "rawson" "jiles" "carraway" "yamada" ///
	"edwards" "perez" "haddix" "essex" ///
	"john" "smith" "jon" "smyth" ///
	"Brian" "Brown" "Brun" "capp" "cope" "copp" "kipp" "dane" "dean" "dent" "dionne" "smith" "Schmidt" "schmit" "trueman" "truman" {
	replace name = "`name'" in `i'
	local i = `i'+1
		}

*/

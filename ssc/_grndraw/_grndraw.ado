*! version 1.0 Philippe VAN KERM, 2017-05-19
* random draws from various distributions
* Syntax: egen NEWVARNAME = rnddraw() [if <exp>] [in <range>] [, distrib_of_choice(params) ]
program define _grndraw
	version 12 , missing
    gettoken type 0 : 0
    gettoken h 0 : 0
    gettoken eqs 0 : 0
    gettoken lparen 0 : 0, parse("(")
    gettoken rparen 0 : 0, parse(")")
    syntax [if] [in] [ , ///
		GB2(numlist >0) ///
		DAGum(numlist >0) SM(numlist >0) ///
		FISK(numlist) LOGLOGistic(numlist) ///
		PAReto(numlist >0) ///
		]
	
	if (("`gb2'"!="")+("`dagum'"!="")+("`sm'"!="")+("`fisk'"!="")+("`loglogistic'"!="")+("`pareto'"!="") != 1) {
		di as error "Specify one distribution"
		exit 198
	}
	
    marksample touse
	quietly {
		if ("`gb2'" != "") {
			if (`: word count `gb2'' != 4) {
				di as error "Incorrect number of parameters"
				exit 198
			} 
			tokenize `gb2' 
			gen `type' `h' =  `2'*( (1/invibeta(`3',`4',runiform()))-1  )^(-1/`1')     if `touse' 
			lab var `h' "Simulated GB2(a=`1';b=`2';p=`3';q=`4')"
			exit
		}
		if ("`sm'" != "") {
			if (`: word count `sm'' != 3) {
				di as error "Incorrect number of parameters"
				exit 198
			} 
			tokenize `sm' 
			gen `type' `h' =   `2'*((1-runiform())^(-1/`3') - 1)^(1/`1')   if `touse' 
			lab var `h' "Simulated Singh-Maddala(a=`1';b=`2';q=`3')"
			exit
		}
		if ("`dagum'" != "") {
			if (`: word count `dagum'' != 3) {
				di as error "Incorrect number of parameters"
				exit 198
			} 
			tokenize `dagum' 
			gen `type' `h' =   `2'*( runiform()^(-1/`3') - 1)^(-1/`1')    if `touse' 
			lab var `h' "Simulated Dagum(a=`1';b=`2';p=`3')"
			exit
		}
		if ("`fisk'" != "") | ("`loglogistic'" != "") {
			if (`: word count `fisk'`loglogistic'' != 2) {
				di as error "Incorrect number of parameters"
				exit 198
			} 
			tokenize `fisk'`loglogistic'
			gen `type' `h' =   `2'*( 1/runiform() - 1)^(-1/`1')    if `touse' 
			lab var `h' "Simulated Fisk(a=`1';b=`2')"
			exit
		}
		if ("`pareto'" != "") {
			if (`: word count `pareto'' != 2) {
				di as error "Incorrect number of parameters"
				exit 198
			} 
			tokenize `pareto' 
			gen `type' `h' =  `1'*(1-runiform())^(-1/`2')   if `touse' 
			lab var `h' "Simulated Pareto(x0=`1';a=`2')"
			exit
		}
	}

end


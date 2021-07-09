/// NJC 13 January 2011

mata: 

string toroman(real matrix number) {  
	string matrix sout
	string colvector rom 
	real matrix work, add 
	real colvector num 
	real scalar i 

	work = number 
	sout = J(rows(number), cols(number), "")  
	rom = ("M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", 
		"IV", "I")' 
	num = (1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1)' 

	for (i = 1; i <= rows(rom); i++) {  
		add = floor(work / num[i])
		add = (add :< 0) :* 0 + (add :>= 0) :* add 
		sout = sout :+ add :* rom[i]  
		work = work :- add :* num[i]         
	}

	return(sout) 
}

real fromroman(string matrix roman) { 
	string matrix work, work2 
	string colvector rom 
	real matrix nout 
	real colvector num 
	real scalar i 

	work = strupper(subinstr(roman, " ", "", .)) 
	nout = J(rows(work), cols(work), 0)  
	rom = ("CM", "CD", "XC", "XL", "IX", "IV", "M", "D", "C", "L", 
		"X", "V", "I")' 
	num = (900, 400, 90, 40, 9, 4, 1000, 500, 100, 50, 10, 5, 1)' 

	for (i = 1; i <= rows(rom); i++) {  
		work2 = subinstr(work, rom[i], "", .) 
		nout = nout + num[i] :* (strlen(work) - strlen(work2)) /
			strlen(rom[i]) 
		work = work2 
	}

	if (sum(work :!= "")) { 
		"Problematic input: "
		select(roman, (work :!= "")) 
	}  

	_editvalue(nout, 0, .)
	return(nout) 
}	 
	
end 

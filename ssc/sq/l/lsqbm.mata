// lsqbm.mata 1.0 27 AUG 2007
// Mata libary for sq.pkg 
// Boyer-Moore Algorithm for -egen sqfirstpos()- and -sqallpos()-
// Magdalena Luniak, WZB
// Support: luniak@wzb.eu

version 9.1
    mata:
    mata clear
    mata set matastrict on


//compute the "jump"-table
real matrix computeJumpTable(real vector alphabet, real vector pattern){
	
	real matrix jumpTable	//result
	real scalar i			//loop variable over the alphabet
	real scalar j			//loop variable over the pattern
	real scalar element		//current element of the pattern
	real scalar jump			//length of the jump 
	real scalar lengthAlphabet 	

	
	lengthAlphabet = length(alphabet)
	//initialisation of jumptable
	jumpTable = J(lengthAlphabet, 2, .)

	//loop over the patternvector
	for(i=1; i<=lengthAlphabet; i++){
		element=alphabet[i]
		jump=0
		//search for the most right occurance of the element in the pattern
		for(j=length(pattern); j>=1 ; j--){
			if (pattern[j]==element){
			break
			}
			else{
			jump++
			}
		} //end loop over the patternvector
		
	//Jump distance will be saved in the second row of the jumpTable
		jumpTable[i,1]=element
		if(jump == 0){	//if jump == 0 the algorithm does not terminate
		jumpTable[i,2]=1
		}
		else{
		jumpTable[i,2]=jump
		}
	} //end loop over the alphabet
	
	return(jumpTable)
}



//return the length of the jump for the given element of alphabet

real scalar getJump(real matrix jumpTable, real scalar element){

	real scalar i		//loop over jumptable
	real jump			//length of the jump	

	for(i=1; i<=rows(jumpTable); i++){
		if(element == jumpTable[i,1]) {
			jump = jumpTable[i,2]
			break
		} //if
	} //end loop variable

	return(jump)
} // end function


//save the length of each sequence in a vector
//

real vector lengthOfEachSeq(real vector id){
	real scalar counter		//counts number of sequences
	real scalar i 			//loop over the id-vector
	real scalar maxLength		//Maximal length of vector
	real vector lengthsV		//Vector of lengths of each sequence
	real scalar index 		//index in lengths
	real scalar number		// number of sequences
	real vector result		// result
	

	maxLength = length(id)
	counter = 1
	number = 0
	lengthsV = J(maxLength,1, .)
	index = 1
	
	for(i=1; i<=maxLength-1; i++){
		if(id[i]==id[i+1]){
			counter ++
		}else{
			lengthsV[index,1]=counter
			number++
			counter = 1
			index++
		} //end else
	} //end for

	//the last and secondlast feld
	if(id[maxLength]==id[maxLength-1]){
		lengthsV[index,1]=counter
		number++
	}else{
		//the length of last sequence is 1
		lengthsV[index,1]=1
		number++
	}

	//compression of result
	result = J(number, 1, .)	
	for(i=1; i<=number; i++){
		result[i]= lengthsV[i]
	}
	
	return(result)
} //end lengthOfEachSeq


//returns the vector of indexes of the first occurances of the pattern for all observations
//assertion: inputdata are correct
//Parameter:
//real vector data - sequences
//real string idvar - variable of seuences' id
// 
real vector getFirst(real vector data, real vector idvar, real vector pattern, real vector alphabet){
	
	real vector first			//result
	real matrix jumpTable		//jump-table
	real scalar i			//loop over the observations
	real vector eachSeqLength	//vector of the length of each sequence
	real scalar thisSeqLength	//the length of the current sequence
	real scalar seq			//navigation through the sequence to the right
	real scalar seq2			//navigation through the sequence to the left
	real scalar	firstIndex		//index of first element of the current sequence in the data
	real scalar	lastIndex		//index of last element of the current sequence in the data
	real vector sequence		//current examined sequence from datamatrix
	real scalar pat			//navigation through the pattern
	real scalar position		//position of the pattern in "sequence"
	real scalar patLength		//length of the pattern
	real scalar element		//element of the sequence
	real scalar counter		//counter of matched elements
	real scalar jump			//distance to jump

	
	jumpTable = computeJumpTable(alphabet, pattern)
	eachSeqLength = lengthOfEachSeq(idvar)
	patLength = length(pattern)

	first = J(length(data), 1, .)	

	
	//loop over the length of each sequence
	
	firstIndex = 0
	lastIndex= 0
	for(i=1; i<=length(eachSeqLength); i++){
		
		thisSeqLength= eachSeqLength[i]
		firstIndex = lastIndex +1
		lastIndex = lastIndex + thisSeqLength
		sequence = data[|firstIndex\lastIndex|]
		seq= 1
		position = 0
	//search untill not found and sequence not empty

	while(position == 0 & seq <= length(sequence)){
		
		element = sequence[seq]

	
		// the last element matches
		if(element == pattern[patLength] && seq>=patLength) {

			counter = 1
			if(patLength == 1){
				position=seq
				break
			}else{
				seq2=seq-1

				for (pat=patLength-1; pat>=1; pat--) {
				
					if (sequence[seq2] == pattern[pat]) {
						counter++
	
						seq2--

						// if all elements match the pattern
						if(counter == patLength){
							position=seq2+1
	
							break
						} //if
					}	//if
					else
					{
						jump=getJump(jumpTable, sequence[seq])
						seq = seq +jump
						break
					} //else

				} //for
			} //else
		} //if
		//the last element does not match
		else
		{	
			jump=getJump(jumpTable, sequence[seq])
			seq = seq+jump		
		} //else

	} //while

	real scalar j
	for(j=firstIndex; j<=lastIndex; j++){
	first[j]=position
	}
	
	} //end loop over the id		

return(first)
} //end function

//returns the vector of of indexes of the first occurances of the pattern for all observations
//check the correctness of input data

void BMFirst( 
   string scalar seqvar,
   string scalar patvar, 
   string scalar alpvar,
	string scalar idvar) { 

	real vector data                //Dataset
	real vector patter             //The real vector for the patterstring including missings
	real vector alphabe            //The real vector for the alphabet including missings
	real vector pattern             //The real vector for the patterstring
	real vector alphabet            //The real vector for the alphabet
	real vector id	            //The real vector for the ids
 	real vector result		//result
	real scalar patLength		//length of pattern
	real scalar i 			//loop over the pattern
	real scalar j 			//loop over the alphabet
	real scalar included		//boolean: element of the pattern occures in the alphabet
	real scalar element		//element of the pattern
	real vector eachSeqLength	//vector of the length of each sequence

	
	// View the Data
      st_view(data=.,.,tokens(seqvar)) 
	st_view(patter=.,.,tokens(patvar))
	st_view(alphabe=.,.,tokens(alpvar))
	st_view(id=.,.,tokens(idvar))
	
	//trim
	pattern = vectortrim(patter)
	alphabet = vectortrim(alphabe)
	
	patLength = length(pattern)

	//The pattern is too long
	eachSeqLength = lengthOfEachSeq(id)
	if(max(eachSeqLength) < patLength){
	    errprintf("the length of the pattern (%f) is longer than the longest sequence in the data(%f)", patLength,max(eachSeqLength) )
		exit()
	}

	//The pattern consists of some symbols that are not included in the alphabet

	//loop over the pattern
	for(i=1; i<=patLength; i++){
		element = pattern[i]
		included = 0

		//loop over the alphabet
		for(j=1; j<= length(alphabet); j++){

			if (element == alphabet[j]) {
			included = 1
			} //if
		} //end loop over the alphabet


		if (included == 0) {
			errprintf("The sign %f does not belong to the alphabet of sequences", element )
			exit()
		} // if

	} //end loop over the pattern


	// Store back to Stata
	result = getFirst(data, id, pattern, alphabet)
	st_addvar("long","_SQBMFirst")
        st_store(.,"_SQBMFirst",result)
} //end function



//removes missing values from the tail of the vectror
//and reduces the length of vector
	real vector vectortrim(real vector vect){
		real scalar i
		real scalar counter
		real vector result
		
		counter=0		
	//Number of valid values at the beginning
		for(i=1; i<length(vect); i++){
			if(vect[i]!=.){
				counter++
			}else{
				break
			} //else
		} //for
		result= vect[|1\counter|]
	return(result)
	}

//**********************************************all*******************************************

//returns the vector of number of the all independent occurances of the pattern for all observations (pattern)
//assertion: inputdata are correct 
//Parameter:
//real vector data - sequences
//real string idvar - variable of sequences' ids
// 
real vector getAll( real vector data, real vector idvar, real vector pattern, real vector alphabet){
	
	real vector first			//result
	real matrix jumpTable		//jump-table
	real scalar i			//loop over the observations
	real vector eachSeqLength	//vector of the length of each sequence
	real scalar thisSeqLength	//the length of the current sequence
	real scalar seq			//navigation through the sequence to the right
	real scalar seq2			//navigation through the sequence to the left
	real scalar	firstIndex		//index of first element of the current sequence in the data
	real scalar	lastIndex		//index of last element of the current sequence in the data
	real vector sequence		//current examined sequence from datamatrix
	real scalar pat			//navigation through the pattern
	real scalar number		//number of the patternoccurance in "sequence"
	real scalar patLength		//length of the pattern
	real scalar element		//element of the sequence
	real scalar counter		//counter of matched elements
	real scalar jump			//distance to jump

	
	jumpTable = computeJumpTable(alphabet, pattern)
	eachSeqLength = lengthOfEachSeq(idvar)
	patLength = length(pattern)

	first = J(length(data), 1, .)	

	
	//loop over the length of each sequence
	
	firstIndex = 0
	lastIndex= 0
	for(i=1; i<=length(eachSeqLength); i++){
		
		thisSeqLength= eachSeqLength[i]
		firstIndex = lastIndex +1
		lastIndex = lastIndex + thisSeqLength
		sequence = data[|firstIndex\lastIndex|]
		seq= patLength
		number = 0
	//search untill sequence is not empty

	while(seq <= length(sequence)){
			element = sequence[seq]
	
		// the last element matches
		if(element == pattern[patLength] && seq>=patLength) {

			counter = 1
			if(patLength == 1){
				seq++
				number++
			}else{
			seq2=seq-1

			for (pat=patLength-1; pat>=1; pat--) {
				//checks, whether other elements match the pattern		
				if (sequence[seq2] == pattern[pat]) {
					counter++
					seq2--

					// if all elements match the pattern
					if(counter == patLength){
						number++
						seq = seq+patLength
					} //if
				}	//if
				else
				{
					jump=getJump(jumpTable, sequence[seq])
					seq = seq +jump 					
					break
				} //else

			} //for
		} //if
		}
		//the last element does not match
		else
		{	
			jump=getJump(jumpTable, sequence[seq])
			seq = seq+jump	
		} //else

	} //while

	real scalar j
	for(j=firstIndex; j<=lastIndex; j++){
	first[j]=number
	}
	
	} //end loop over the id		

return(first)
} //end function


void BMAll( 
   string scalar seqvar,
   string scalar patvar, 
   string scalar alpvar,
	string scalar idvar) { 

	real vector data                //Dataset
	real vector patter             //The real vector for the patterstring including missings
	real vector alphabe            //The real vector for the alphabet including missings
	real vector pattern             //The real vector for the patterstring
	real vector alphabet            //The real vector for the alphabet
	real vector id	            //The real vector for the ids
 	real vector result		//result
	real scalar patLength		//length of pattern
	real scalar i 			//loop over the pattern
	real scalar j 			//loop over the alphabet
	real scalar included		//boolean: element of the pattern occures in the alphabet
	real scalar element		//element of the pattern
	real vector eachSeqLength	//vector of the length of each sequence

	
	// View the Data
      st_view(data=.,.,tokens(seqvar)) 
	st_view(patter=.,.,tokens(patvar))
	st_view(alphabe=.,.,tokens(alpvar))
	st_view(id=.,.,tokens(idvar))
	
	//trim
	pattern = vectortrim(patter)
	alphabet = vectortrim(alphabe)
	
	patLength = length(pattern)

	//The pattern is too long
	eachSeqLength = lengthOfEachSeq(id)
	if(max(eachSeqLength) < patLength){
	    errprintf("the length of the pattern (%f) is longer than the longest sequence in the data(%f)", patLength,max(eachSeqLength) )
		exit()
	}

	//The pattern consists of some symbols that are not included in the alphabet

	//loop over the pattern
	for(i=1; i<=patLength; i++){
		element = pattern[i]
		included = 0

		//loop over the alphabet
		for(j=1; j<= length(alphabet); j++){

			if (element == alphabet[j]) {
			included = 1
			} //if
		} //end loop over the alphabet


		if (included == 0) {
			errprintf("The sign %f does not belong to the alphabet of sequences", element )
			exit()
		} // if

	} //end loop over the pattern


	// Store back to Stata
	result = getAll(data, id, pattern, alphabet)
	st_addvar("long","_SQBMAll")
      st_store(.,"_SQBMAll",result)
} //end function


// Compile into a libary
	mata mlib create lsqbm, replace
	mata mlib add ///
	  lsqbm computeJumpTable() getJump() getFirst() BMFirst() ///
	lengthOfEachSeq() vectortrim() getAll() BMAll()
	mata mlib index


	
end
exit


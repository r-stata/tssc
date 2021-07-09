cap program drop regsets
pr def regsets , rclass

        syntax anything [, local(name)]
        gettoken colon anything : anything, parse(":")
        gettoken first anything : anything
                
        loc n = 2^(`: word count `anything''+1)-1
        loc list `""`first'" """'

        foreach v of local anything {
                
                loc newvarlist
                foreach elem of local list {
                        loc newvarlist `"`newvarlist' "`v' `elem'""'
                }
        
        loc list `"`newvarlist' `list'"'
        }

        if ( "`local'"!="" ) c_local `local' `"`list'"'
        
        di ""
        di "You have `n' combinations of non-empty sets as follows:"
		di ""
		
		foreach y of local list{
        		di "`y'" 
        		}
        
        return local sets `"`list'"'
        return local n `"`n'"'
        
        di "Returned values:"
        di ""
        di "r(n) = Number of sets"
        di "r(sets) = List of sets"

end

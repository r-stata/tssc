*! version 1.0.1, Ben Jann, 10may2005
program define shuffle, rclass
	version 9.0
	syntax anything(name=list id="list") [, num NOIsily ]
	if "`num'"!="" {
		numlist `"`list'"'
		local list `r(numlist)'
	}
	mata: shuffle()
	local list `"`r(list)'"'
	if "`noisily'"!="" di as txt `"`list'"'
	ret local list `"`list'"'
end

version 9.0
mata:
function shuffle()
{
	list = st_local("list")
	list = tokens(list)
	list = list'
	list = jumble(list)
	list = list'
	list = invtokens(list)
	st_global("r(list)", list)
}
string scalar invtokens(string rowvector In)
{
	string scalar Out
	real scalar i
	Out = ""
	for (i=1; i<=cols(In); i++) {
		if ( strpos(In[1,i], `"""') ) In[1,i] = "`" + `"""' + In[1,i] + `"""' + "'"
		else if ( strpos(In[1,i], " ") ) In[1,i] = `"""' + In[1,i] + `"""'
		else if ( In[1,i]=="" ) In[1,i] = `"""' + `"""'
		if ( i>1 ) Out = Out + " "
		Out = Out + In[1,i]
	}
	return(Out)
}
end

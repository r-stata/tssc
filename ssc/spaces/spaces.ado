program define spaces, rclass
*! 1.0.0 6 June 2000 Jan Brogger
	syntax , s(string) [chr(string)]

	if `"`chr'"'==`""' {
		local chr `";"'
	}

	local len=length(`"`s'"')-1
	local i=1
	
	if (`len'<2) {
		return local s=`"`s'"'
		exit=0
	}

	*Do a dummy run first to get to the ifs
	local spacpos=1
	local pos2=1
	local pos3=2

	while (`spacpos'>0 & `len'>1) {

		local spacpos=0
		if (`spacpos'==0) {
				local spacpos=index(`"`s'"',`"  "')
				local pos2=`spacpos'-1
				local pos3=`spacpos'+2
		}
		if (`spacpos'==0) {
				local spacpos=index(`"`s'"',`"| "')
				local pos2=`spacpos'-1
				local pos3=`spacpos'+2
		}
		if (`spacpos'==0) {
				local spacpos=index(`"`s'"',`"["')
				local pos2=`spacpos'-1
				local pos3=`spacpos'+1
		}
		if (`spacpos'==0) {
				local spacpos=index(`"`s'"',`"]"')
				local pos2=`spacpos'-1
				local pos3=`spacpos'+1
		}
		if (`spacpos'==0) {
				local spacpos=index(`"`s'"',`","')
				local pos2=`spacpos'-1
				local pos3=`spacpos'+1
		}
		if (`spacpos'==0) {
				local spacpos=index(`"`s'"',`"="')
				local pos2=`spacpos'-1
				local pos3=`spacpos'+1
		}
		if (`spacpos'==0) {
				local spacpos=index(`"`s'"',`" ."')
				local pos2=`spacpos'-1
				local pos3=`spacpos'+1
		}
		if (`spacpos'==0) {
				local spacpos=index(`"`s'"',`": "')
				local pos2=`spacpos'-1
				local pos3=`spacpos'+1
		}


		if (`spacpos'==0) {
				local spacpos=index(`"`s'"',`";;"')
				local pos2=`spacpos'-1
				local pos3=`spacpos'+2
		}

		if (`spacpos'>0) {
			local s1=substr(`"`s'"',1,`pos2')
			local s2=substr(`"`s'"',`pos3',.)
			local s `"`s1'`chr'`s2'"'
		}
	}

	return local s=`"`s'"'
end

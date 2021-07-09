*! version 1.0.2 18aug2011 Daniel Klein

pr labvalcl
	vers 9.2
	
	syntax [namelist] [, Null Null_p(str asis) NUMeric noDEtach]
	
	* option null
	if (`"`null_p'"' != "") {
		if (`: word count `null_p'' > 1) | ("`null'" != "") err 198
		if ("`null'" == "") loc null `null_p'
	}
		
	* get lblnamelist
	if ("`namelist'" == "") | (`: list posof "_all" in namelist') {
		qui la di
		loc namelist `r(names)'
	}
	else {
		loc namelist : list uniq namelist
		qui la li `namelist'
	}
	
	* error out if no value labels
	if ("`namelist'" == "") & ("`detach'" != "") {
		di as err "no value labels found"
		e 111
	}
	
	* remove (null) strings
	foreach lnam of loc namelist {
		mata : rmvnlab("`lnam'", `"`null'"', "`numeric'")
		cap la li `lnam'
		if (_rc) | (r(k) == 0) loc tormv `tormv' `lnam'
	}

	* remove empty value labels
	if ("`detach'" == "") {
		foreach v of varlist * {
			loc lb : val l `v'
			if ("`lb'" == "") continue
			if !(`: list lb in tormv') {
				cap la li `lb'
				if !(_rc) continue
			}
			loc `lb' ``lb'' `v'
			loc rmvlbs `rmvlbs' `lb'
		}
		loc rmvlbs : list uniq rmvlbs
		foreach lb of loc rmvlbs {
			foreach v in ``lb''  {
				la val `v'
			}
			cap la drop `lb'
		}
	}
end

mata :
void rmvnlab(string scalar lnam, string scalar null, string scalar nbr)
{
	if (null != "") null = "" \ null
	if (nbr != "") null = null \ ""
	st_vlload(lnam, v = ., t= .)
	for (i = 1; i <= rows(v); i++) {
		if (nbr != "") null[rows(null), 1] = strofreal(v[i, 1])
		for (m = 1; m <= rows(null); m++) {
			if (null[m, 1] == "") l = strtrim(st_vlmap(lnam, v[i, 1]))
			else l = st_vlmap(lnam, v[i, 1])
			if (l == null[m, 1]) {
				st_vlmodify(lnam, v[i, 1], "")
			}
		}
	}
}
end
e

History

1.0.2	18aug2011	detach value labels already dropped from memory
					add option -nodetach-
1.0.1	04aug2011	add -numeric- option
					remove null strings with more than one blank
					part of -labutil2- package
1.0.0	25jul2011

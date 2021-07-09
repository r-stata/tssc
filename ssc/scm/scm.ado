program scm
version 11
//Revised 25apr2012
//Author: Zachary Neal (zpneal@msu.edu)
syntax anything , [REPorters(int 0) conom(str) minsim(real 0) SAVELog(str) SAVEMatrix(str) NOIsolates]
quietly {

//Check for installation of PWCORR2
capture: which pwcorr2
if _rc == 111 {
	noisily: display "This command requires that you install PWCORR2"
	noisily: display "Please type 'ssc install pwcorr2', then run the command again"
	noisily: display " "
	}
error (_rc == 111)

//Check that conom is correctly specified
if "`conom'" == "diag" local conom = "diagonal"
if "`conom'" == "norm" local conom = "normalize"
if "`conom'" ~= "" & "`conom'" ~= "diagonal" & "`conom'" ~= "normalize" {
	noisily: display "The -conom- option must specify the treatment of the co-nomination"
	noisily: display "matrix as -diagonal- or -normalize-."
	noisily: display " "
	}
error ("`conom'" ~= "" & "`conom'" ~= "diagonal" & "`conom'" ~= "normalize")

if "`savelog'" ~= "" {
	local savelog = "`savelog'.txt"
	log using "`savelog'", text
	}

//Read in data
preserve
set linesize 255
clear
insheet using "`anything'"
describe
local cols = r(k)

//Remove isolates, if requested
if "`noisolates'" ~= "" {
	egen total = rowtotal(v2-v`cols')
	count if total == 0
	noisily: display "****************"
	noisily: display "*** ISOLATES ***"
	noisily: display "****************"
	if r(N) == 0 {
		noisily: display "These data include no isolates; no individuals have been excluded."
		noisily: display " "
		}
	else {
		noisily: display "The following " r(N) " individual(s) have been excluded from analysis"
		noisily: display "because they are isolates (i.e. not nominated to any group):"
		noisily: list v1 if total == 0, noobs noheader clean
		noisily: display " "
		drop if total == 0
		}
	drop total
	}

//Create ID vector and data matrix
local sample = _N
tostring v1, replace
mata id = st_sdata(.,1)
drop v1
mata twomode = st_data(.,.)

//Interaction Groups
if `reporters' ~= 0 {
xpose, clear
duplicates tag, generate(consensus)
replace consensus = ((consensus + 1)/`reporters')*100
local consensus_ob = `sample'+1
duplicates drop
local groups = _N
gsort -consensus
xpose, clear
gen str50 id = ""
mata id2 = id\""
mata st_sstore(.,"id",id2)
noisily: display "**************************"
noisily: display "*** INTERACTION GROUPS ***"
noisily: display "**************************"
noisily: display "The " `reporters' " respondent(s) listed " `groups' " distinct interaction group(s)."
noisily: display "Listed in descending order by level of consensus, they are:"
noisily: display " "
forvalues i = 1/`groups' {
	local consensus = v`i' in `consensus_ob'
	noisily: display "Consensus: " `consensus' "%"
	noisily: list id if v`i'==1, noobs noheader clean
	noisily: display " "
	}
}

//Co-nomination Groups (raw & diagonal)
if "`conom'" == "" | "`conom'" == "diagonal" {
clear
mata conom = twomode*twomode'
if "`conom'" == "" mata _diag(conom,.)
mata st_matrix("c", conom)
svmat c
format _all %2.0f
gen str50 id = ""
mata st_sstore(.,"id",id)
order id
noisily: display "***************************"
noisily: display "*** CONOMINATION GROUPS ***"
noisily: display "***************************"
if "`conom'" == "" {
	noisily: display "This matrix displays the number of times each pair of individuals were"
	noisily: display "nominated as members of the same interaction group."
	noisily: display " "
	}
else {
	noisily: display "The off-diagonal cells of this matrix display the number of times a pair"
	noisily: display "of individuals were nominated as members of the same interaction group."
	noisily: display "The diagonal cells display the number of times an individual was nominated"
	noisily: display "any group."
	}
noisily: display " "
noisily: list, noobs noheader clean compress
noisily: display " "
if "`savematrix'" ~= "" {
	local save_conom = "`savematrix'_conom.csv"
	outsheet using "`save_conom'", comma
	}
}

//Co-nomination Groups (normalized)
if "`conom'" == "normalize" {
clear
tempfile conommat affil
mata conom = twomode*twomode'
mata st_matrix("conom", conom)
svmat conom
gen i = _n
reshape long conom, i(i) j(j)
save "`conommat'"
clear
mata affil = rowsum(twomode)
mata st_matrix("affil", affil)
svmat affil
rename affil1 affil_i
gen i = _n
save "`affil'"
rename i j
rename affil_i affil_j
cross using "`affil'"
sort i j
merge 1:1 i j using "`conommat'", nogen
gen a = conom
gen b = affil_i - conom
gen c = affil_j - conom
gen d = (`cols' - 1) - (a + b + c)
gen norm = ((a*d)-sqrt(a*d*b*c))/((a*d)-(b*c))
replace norm = .5 if norm == .
keep i j norm
rename norm c
if "`diagonal'" == "" replace c = . if i == j 
replace c = round(c, .01)
reshape wide c, i(i) j(j)
drop i
format _all %3.2f
gen str50 id = ""
mata st_sstore(.,"id",id)
order id
noisily: display "***************************"
noisily: display "*** CONOMINATION GROUPS ***"
noisily: display "***************************"
noisily: display "This matrix displays the normalized tendency for a pair of individuals "
noisily: display "to be nominated as members of the same interaction group."
noisily: display " "
noisily: list, noobs noheader clean compress
noisily: display " "
if "`savematrix'" ~= "" {
	local save_conom = "`savematrix'_conom.csv"
	outsheet using "`save_conom'", comma
	}
}

//Similarity Groups
drop id
pwcorr2 c1-c`sample'
matrix s = r(C)
clear
svmat s, names(s)
mata s = st_data(.,.)
mata _diag(s,.)
mata st_matrix("s", s)
clear
svmat s
format _all %3.2f
if `minsim' ~= 0 recode _all (. = .) (`minsim'/max = 1) (else = 0)
if `minsim' ~= 0 format _all %1.0f
gen str50 id = ""
mata st_sstore(.,"id",id)
order id
noisily: display "*************************"
noisily: display "*** SIMILARITY GROUPS ***"
noisily: display "*************************"
if "`conom'" == "" {
	if `minsim' == 0 {
		noisily: display "This matrix displays the Pearson correlation coefficient for"
		noisily: display "each pair of individuals' co-nomination profiles."
		}
	else {
		noisily: display "This matrix identifies pairs of individuals whose co-nomination"
		noisily: display "profiles have a Pearson correlation coefficient of at least " `minsim' "."
		}
	}

if "`conom'" == "normalize" {
	if `minsim' == 0 {
		noisily: display "This matrix displays the Pearson correlation coefficient for"
		noisily: display "each pair of individuals' normalized co-nomination profiles."
		}
	else {
		noisily: display "This matrix identifies pairs of individuals whose normalized co-nomination"
		noisily: display "profiles have a Pearson correlation coefficient of at least " `minsim' "."
		}
	}

if "`conom'" == "diagonal" {
	if `minsim' == 0 {
		noisily: display "This matrix displays the Pearson correlation coefficient for"
		noisily: display "each pair of individuals' columns in the co-nomination matrix."
		noisily: display "These values were calculated using the diagonal cells and thus"
		noisily: display "do not necessarily indicate similarity in co-nomination profiles."
		}
	else {
		noisily: display "This matrix identifies pairs of individuals whose co-nomination"
		noisily: display "matrix columns have a Pearson correlation coefficient of at least " `minsim' "."
		noisily: display "These values were calculated using the diagonal cells and thus"
		noisily: display "do not necessarily indicate similarity in co-nomination profiles."
		}
	}

noisily: display " "
noisily: list, noobs noheader clean compress
noisily: display " "
if "`savematrix'" ~= "" {
	local save_sim = "`savematrix'_sim.csv"
	outsheet using "`save_sim'", comma
	}

if "`savelog'" ~= "" log close
set linesize 80
restore
}
end
*/
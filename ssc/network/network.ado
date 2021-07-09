/*
*! version 1.5.0 # Ian White # 6apr2018 
	RELEASED TO UCL AND SSC
	new: network compare
	minor improvements to setup, meta, forest, import
version 1.4 # Ian White # 5jan2018 
	add network loopsplit
version 1.3.3 # Ian White # 20nov2017 
	network bayes doesn't require setup or unsetup
version 1.3.0 # Ian White # 17aug2017
	bug fixes in network table
	incorporated (test version of) network bayes
version 1.2.5 # Ian White # 13mar2017
    final changes to the connectedness routines in network setup
version 1.2.4 # Ian White # 23feb2017
    changes to the connectedness routines in network setup
version 1.2.3 # Ian White # 11jan2016
    minor change to network forest
version 1.2.2 # Ian White # 21dec2015
    improvements to checking for connectedness
        in network_components
        in network_meta
version 1.2.1 # Ian White # 22jul2015 # RELEASE
    requires version 13 (otherwise selectindex() fails in network_components)
version 1.2.0 # Ian White # 3jul2015
    changes to setup, meta and sidesplit to accommodate metamiss2
version 1.1.4 # Ian White # 1jul2015
    network meta requires mvmeta v3.1
version 1.1.3 # Ian White # 11jun2015
    on external website
    changes to network_setup (code and helpfile) only
version 1.1.2 # Ian White # 10jun2015
    on external website
    changes to network_meta only
version 1.1.1 # Ian White # 9jun2015
    on external website and to SJ
    changes to network_meta only
version 1.1 # Ian White # 8jun2015
    on external website
version 1.0 # Ian White # 9Sep2014 
version 0.9 # 1aug2014 
    min abbreviation is 3 letters
    allows user-written commands
version 0.8 # 31jul2014 
    new treatment naming scheme
version 0.7 # 11jul2014
version 0.6 # 6jun2014
version 0.5 # 27jan2014
version 0.4 # 18dec2013
*/
prog def network
version 13
syntax [anything] [if] [in], [which *]

// LOAD SAVED NETWORK PARAMETERS
foreach thing in `_dta[network_allthings]' {
    local `thing' : char _dta[network_`thing']
}

// Known network subcommands
* subcmds requiring data NOT network set
local subcmds0 setup import // start
* subcmds requiring data network set
local subcmds1 convert query unset table /// utilities
    meta sidesplit rank loopsplit /// analyses
    forest pattern map // graphs
* subcmds not minding whether data are network set
local subcmds2 bayes
* all known subcommands
local subcmds `subcmds0' `subcmds1' `subcmds'

// check a subcommand is given
if mi("`anything'") {
	di as error "Syntax: network <subcommand>"
	exit 198
}

// "which" option
if "`anything'"=="which" {
	which network
	foreach subcmd of local subcmds {
		which network_`subcmd'
	}
	exit
}

// Parse current subcommand
gettoken subcmd rest : anything

// Identify abbreviations of known subcommands
if length("`subcmd'")>=3 {
    foreach thing in `subcmds' {
    	if strpos("`thing'","`subcmd'")==1 {
    		local subcmd `thing'
            local knowncmd 1
    	}
    }
}

// Check it's a valid subcommand
cap which network_`subcmd'
if _rc {
    di as error "`subcmd' is not a valid network subcommand"
    if length("`subcmd'")<3 di as error "Minimum abbreviation length is 3"
    exit 198
}

// For known commands, check data correctly unset/set
local type0 : list subcmd in subcmds0
if `type0' & !mi("`allthings'") {
	di as error "Data are already in network format"
	exit 459
}
local type1 : list subcmd in subcmds1
if `type1' & mi("`allthings'") {
	di as error "Data are not in network format: use network setup|import"
	exit 459
}
if `type1' & "`format'"=="pairs" & !mi("`if'`in'") {
    * check `in' doesn't part-select multi-arm trials
    marksample touse
    tempvar min
    egen `min' = min(`touse'), by(`studyvar')
    qui count if `touse'>`min'
    if r(N) {
        di as error "The data are in pairs format - this command would use only part of a multi-arm study"
        exit 198
    }
}
    
if mi(`"`options'"') network_`subcmd' `rest' `if' `in'
else                 network_`subcmd' `rest' `if' `in', `options'
end

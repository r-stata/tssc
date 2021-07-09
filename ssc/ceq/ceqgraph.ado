** ADO FILE FOR GRAPHS IN CEQ MASTER WORKBOOK SECTION E

** VERSION AND NOTES (changes between versions described under CHANGES)
*!  v2.3 01jun2017 
**  v2.2 08mar2017 
**  v2.1 12jan2017 
**  v2.0 30oct2016 
**  v1.9 29sep2016 
**  v1.8 18sep2016 
**  v1.7 05sep2016 
**  v1.6 06jun2016 
**  v1.5 26nov2015 
**  v1.4 17nov2015 
**  v1.3 12oct2015 
**  v1.2 10oct2015 
**  v1.1 06oct2015 
**  v1.0 12sep2015 
** (beta version; please report any bugs), written by Sean Higgins sean.higgins@ceqinstitute.org

** CHANGES
**  06-01-2017 Add additional options to print meta-information
**  03-08-2017 Remove the net in-kind transfers as a broad category in accordance with the instruction that users
**				 supply net in-kind transfer variables to health/education/otherpublic options in ceqgraph_conc
** 	01-12-2017 Set the data type of all newly generated variables to be double
** 			   Add a check of the data type of income and fiscal variables and issue a warning if
**				they are not double
**			   Add qui before generate command in ceqgraph_fi
**			   Add baseyear option for ceqgraph_fi 
**  10-30-2016 Fix bug with alltransfersp omitted from the broad categories in ceqgraph_conc
**	 9-29-2016 Export graphs and print warning messages to MWB sheets for all subcommands 
**			   Fixed bug with `options' and `_scheme' in fi and cdf (reported by Sandra Martinez)
**			   Fixed bug with graph name option in progressivity (reported by Sandra Martinez)
**			   Fixed bug with the specification of local macro direct_transfers_col(s)
**			   Add a check for open parentheses in ceqgraph_conc; changed from strrpos() to strpos() 
**				 for compatibility with Stata 13.0
**			   Change from d1 command to `command' command in warning for all subcommands
**			   Add a check to see if fiscal interventions options are specified for conc
**			   Changed warning contents and add exit when ppp option is not specified (fi and cdf)
**			   Move up preserve and modify section to avoid issuing a wrong warning for negatives (fi and cdf)
**   9-05-2016 Added ceqgraph conc
**   6-06-2016 Keep needed variables only to increase speed
**	           Add ignoremissing option for missing values of income concepts 
**  11-26-2015 Remove parse(",") because then subcmd was picking up the weight,
**              if condition, etc. Instead, use if substr("`subcmd'",1,2)==...
**              for all possible sub-commands
**             (Issues reported by Nizar Jouini and Luciana De la Flor)
**  11-17-2015 Add parse(",") -- pointed out by Mashekwa Maboshe
**  10-12-2015 Fix graphname not changing the name of the file in ceqgraph progressivity
**              (reported by Sandra Martinez)
**  10-10-2015 Fixed the suboptions (headcount, total, percapita, normalized)
**  10-04-2015 Add additional options for poverty lines

** NOTES

** TO DO

*********************
** ceqgraph PROGRAM *
*********************
** For sheet ...
// BEGIN ceqgraph (Higgins 2015)
capture program drop ceqgraph
program define ceqgraph, rclass 
	** version 13.0

	***********
	** LOCALS *
	***********
	** parse subcommand 
	gettoken subcmd 0: 0
	
	** general programming locals
	local dit display as text in smcl
	local die display as error in smcl
	local command ceqgraph
	local version 2.3
	`dit' "Running version `version' of `command' `subcmd' on `c(current_date)' at `c(current_time)'" _n "   (please report this information if reporting a bug to sean.higgins@ceqinstitute.org)"
	
	****************
	** SUBCOMMANDS *
	****************
	if substr("`subcmd'",1,2)=="fi" { // fiscal impoverishment
		ceqgraph_fi `0'
	}
	else if substr("`subcmd'",1,2)=="po" { // poverty
		ceqgraph_poverty `0'
	}	
	else if substr("`subcmd'",1,2)=="lo" { // lorenz
		ceqgraph_lorenz `0'
	}
	else if substr("`subcmd'",1,2)=="co" { // concentration curves
		ceqgraph_conc `0'
	}
	else if substr("`subcmd'",1,3)=="cdf" { // cumulative distribution functions
		ceqgraph_cdf `0'
	}
	else if substr("`subcmd'",1,2)=="pr" { // progressivity
		ceqgraph_progressivity `0'
	}
	else error 199 // unrecognized command
	
end // END ceqgraph (wrapper program)

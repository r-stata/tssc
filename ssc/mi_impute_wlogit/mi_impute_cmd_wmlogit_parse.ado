* PARSE PROGRAMME [wmlogit, md(varname) marginal]
* Factor variables not allowed
* Return scalar for negative weights
*! version 1.1 TPham 21dec2016

program mi_impute_cmd_wmlogit_parse

	version 14.1
	syntax anything [, md(varname) marginal * ]
	gettoken ivar xvars : anything
	u_mi_impute_user_setup, ivars(`ivar') xvars(`xvars') `options'
	
	global MI_IMPUTE_userdef_md `md'
	global MI_IMPUTE_userdef_w `marginal'

end

	

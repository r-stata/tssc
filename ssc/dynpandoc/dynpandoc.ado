*! version 1.0.3  15jan2018
program dynpandoc
	version 15
	
	syntax anything(everything) [, 	///
			SAVing(string asis)  	/// 
			REPlace					///
			noREMove				///
            nomsg                   ///
            nostop                  ///
			from(string)			///
			to(string)				///
			path(string)			///
			pargs(string asis)		///
	]
			
	gettoken file opargs : anything
	local srcfile = strtrim("`file'")
	confirm file "`srcfile'"

	local destfile = strtrim(`"`saving'"')
	if (`"`destfile'"' == "") {
		if ("`to'" == "") {
			mata:(void)pathchangesuffix("`srcfile'", "html", "destfile", 0)	
		}
		else {
			mata:(void)pathchangesuffix("`srcfile'", "`to'", "destfile", 0)			
		}
	}

	mata: (void)pathresolve("`c(pwd)'", `"`destfile'"', "destfile") 	

	dyntext `"`srcfile'"' `opargs', ///
			saving(`"`destfile'"') 	/// 
			`replace' 				/// 
			`remove' 				/// 
			`stop' 

	tempfile mlogfile
	local tmpsuf = ""
	mata:get_file_suffix(`"`srcfile'"', "tmpsuf")
	mata:(void)pathchangesuffix("`mlogfile'", "`tmpsuf'", "mlogfile", 0)					
	
	qui copy "`destfile'" `"`mlogfile'"'
	cap noi stpandoc `mlogfile', /// 
			saving(`destfile') 	 ///
			path(`path') 		 ///
			from(`from') 		 ///
			to(`to')			 /// 
			pargs(`pargs') 		 ///
			`msg' 				 ///
			`replace'
	if(_rc) {
di in error "{bf:stpandoc} failed to convert file, make sure that {bf:pandoc} is installed"
		qui cap erase `"`mlogfile'"'			
		exit 602				
	}
	qui cap erase `"`mlogfile'"'			
end

mata:
void get_file_suffix(string scalar file, string scalar out)
{
	string scalar suf
	
	suf = pathsuffix(file)
	suf = subinstr(suf, ".", "", 1)
	st_local(out, suf)
}
end

exit


*! ----------------------------------------------------------------------------------------------------------------------------------
*! vs1.0 Lars Aengquist , 2020-04-18
*!
*! program desclong
*!
*!		syntax	[varlist]	,	name(string) [folder(string) dropvars(string) sortvars(string) clear preserve excel]			
*!
*! ----------------------------------------------------------------------------------------------------------------------------------


program desclong

		syntax	[varlist]	,	name(string) [folder(string) dropvars(string) sortvars(string) clear preserve excel]								

   version 15.1

   if "`folder'"=="" {
      local folder "."
   }

   if "`preserve'"=="preserve" {
      local restore "restore"									//	if preserve-option (store and restore original data)
   }

   `preserve'

   tempfile longlabel
   tempvar length length2

   local max=1

   foreach var of varlist `varlist' {
      local tmp=length("``var'[note1]'")+1							//	maximum length of notes (long varlabels)
      local max=cond(`tmp'>`max',`tmp',`max') 
   }

   quietly {
      postfile res str32 name str`max' varlab2 using "`longlabel'", replace			//	create dataset with long varlabels (from notes)

      foreach var of varlist `varlist' {
         local tmp="``var'[note1]'"								//	...use notes-as-characteristics
         post res ("`var'") ("`tmp'") 
      }
   
      postclose res										//	save dataset with long varlabels

      desc, replace `clear' 									//	create file with abbreviated labels

      merge 1:1 name using "`longlabel'"							//	merge with long varlabels
      tab _merge
      keep if _merge==3
      drop _merge

      replace varlab=ustrtrim(varlab)								//	trim label-strings
      replace varlab2=ustrtrim(varlab2)

      gen `length'=length(varlab)								//	length of label-strings
      gen `length2'=length(varlab2)
      assert `length2'>=`length' if `length2'>0		
      replace varlab=varlab2 if `length2'>0							//	replace original with long varlabels (when applicable)
   
      drop varlab2 `length' `length2'								//	clear temporary variables
      sort position										//	retain original variable order

      capture drop `dropvars'
      capture sort `sortvars'

      compress
   }

   save "`folder'\\`name'", replace								//	save final long variable descriptions/labels

   if "`excel'"!="" {
      export excel "`folder'\\`name'.xlsx", firstrow(var) replace				//	export to EXCEL-format
   }

   `restore'

end


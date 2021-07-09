*! pdslasso 1.0.03 04sept2018
*! pdslasso package 1.1 15jan2019
*! authors aa/cbh/ms
*  wrapper for ivlasso

program define pdslasso, eclass				//  no sortpreserve needed since ivlasso handles that
	syntax [anything] [if] [in] [aw pw],	/// note no "/" after pw
		[									///
		OLSOPTions(string)					/// options passed to IV or OLS estimation
		* ]

	version 13
	
	// passing empty weights expression [] causes problems so
	if "`weight'" ~= "" {
		local weightopt [`weight'`exp']
	}
	
	ivlasso `anything' `weightopt' `if' `in' , `options' cmdname(pdslasso) ivoptions(`olsoptions')
	
	ereturn local cmd 		pdslasso
	
end


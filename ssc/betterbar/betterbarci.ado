*! version 1.5 31DEC2019  Benjamin Daniels bbdaniels@gmail.com

// Betterbar - Stata module to produce bar graphs with standard error bars and cross-group comparisons.

// Confidence intervals alternative specification

	cap prog drop betterbarci
	prog def betterbarci

	syntax anything [using] [if] [in] [fw iw aw pw] , [*]

	betterbar `anything' `using' `if' `in' [`weight'`exp'] , `options' ci

	end

// That's all!

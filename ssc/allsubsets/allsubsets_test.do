clear

// read some fictitious data 
insheet using data.txt

// run all subsets meta-analysis; save in all_subsets_meta_results.dta
allsubsets es var , save(all_subsets_meta_results) replace

// these are the raw data you can then use in standard stata graphs
use all_subsets_meta_results, clear

// A graphing command interface will be add soon -- to generate graphs such as 
// the ones in the Olkin et al. 2012 RSM paper (see _help allsubsets_) for 
// citation. 
// Also check www.cebm.brown.edu/resources for updates 



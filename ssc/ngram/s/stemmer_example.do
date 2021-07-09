// This data is from the donated Reuters dataset at the UCI machine learning archive:
//  http://archive.ics.uci.edu/ml/datasets/Reuters-21578+Text+Categorization+Collection
// The first 2000 records have been reformated from the ancient SGML into a spreadsheet that Stata can load.
// This is in csv format because pre Stata 13 .dta files cannot handle more than 244-byte long strings.
import delimited using "reuters.csv", clear

// Set the locale.
// If you are reading this in English, your locale is probably also set to English, making this redundant.
// but it is good to be explicit. Read this as "the reuters dataset is an American English text dataset."
set locale_functions en_US

// Extract unigrams as normal
ngram title, thresh(3)

// Inspect the results
desc t_*

list title if t_acquire

//
// reset the state
// this is a fragile way to do this; in general you should be reloading the dataset fresh each time
drop t_*
drop n_token


// Now compare to the same with stemming enabled
ngram title, thresh(3) stem

desc t_*

// It is informative to compare the difference in the listed results:
//  the stemmed results capture lines that the unstemmed ones miss,
//  because instead of the single stemmed t_acquir they have
//  separate t_acquire, t_acquires, and t_acquired columns.
list title if t_acquir

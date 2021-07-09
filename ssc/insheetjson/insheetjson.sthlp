{smcl}
{* *! version 1.5 29Aug2014}{...}
{cmd:help insheetjson}
{hline}

{title:Title}

     {hi: insheetjson: Importing tablular data from JSON sources}

{title:Syntax}

{p 8 17 2}
{cmdab:insheetjson}
{cmd:{varlist} {help using},} {opt columns(string)} [{it:options}]{p_end}
{p 8 17 2}
{cmdab:insheetjson}
{cmd:{help using},} showresponse [flatten]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:{it:Required}...}

{space 6}{varlist}{space 13} are the string variables to store the retreived data into 

{synopt:{opt using} "URL or file path"} specifies the source of the JSON data

{synopt:{opt columns}(string)} specifies the column selectors associated with each specified variable

{synopt:{opt showresponse}} Make no changes to the Stata environment and instead just print the JSON reponse to the console

{syntab:{it:Optionals}...}

{synopt:{opt tableselector}(string)} specifies the selector to use in finding the table burried in the json object tree

{synopt:{opt replace}} Necessary if you need to replace existing data in varlist

{synopt:{opt printonly}} Make no changes to the Stata environment and instead just print the results to the console

{synopt:{opt flatten}} Output results as key(selector)-value pairs

{synopt:{opt savecontents}(filename)} Copies the contents of the raw response to the specified file 

{synopt:{opt limit}(#)} specifies the maximum number of observations to add to the stat environment

{synopt:{opt followurl}({help libjson##followurl:selector [#]})} specifies the selector to use to find the follow-on url, and the maximum number of times to follow it

{synopt:{opt offset}(#)} Observation to begin filling in the results at

{synopt:{opt topscalars}} Top level object scalars are placed into r().

{synopt:{opt aoa(#)}} Causes insheetjson to assume that the URL returns an an array-of-arrays, where the first row defines a list of column/key names, and the rest of the array rows are just bare values.

{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
There are many data sources out on the web that operate by a URL query, and which then respond with data formatted in JavaScript Object Notation (JSON).
This command is designed to support querying those sources, assuming that the user has some idea of what the JSON reponse will look like (or can puzzle it out. See examples below.)
Through the application of data selectors, the JSON response can be examined and the data extracted in the format of string data.
This data can then be stored in string variables in the Stata enviroment for later processing by the user.

{pstd}
To use this command, you will need to know at least the URL of the JSON data source.

{title:Required Library}
{pstd}
To use this command, you will need to have installed libjson, which is also available from SSC via the following link

{pstd}
{stata ssc install libjson}


{title:Latest Version}

{pstd}
The latest version is always kept on the SSC website. To install the latest version click
on the following link 

{pstd}
{stata ssc install insheetjson, replace}

{title:Options}

{dlgtab:Required}

{pstd}{opt varlist} is a list of string stata variables for the retureived data to be stored into. Note that if the string variable is not large enough to hold the string, it will be truncated.
{ul:If a non-string variable is specified}, then the data destined for that variable will quiety be discarded. 

{pstd}{opt using(URL or file path)} specifies where to get the JSON data from 
There are two types of sources: local (file) and web (URL).
Normally, you want to give a URL that includes any needed query options (the things which follow a question mark), and
a URL must have the leading "http:\\" to distiguish them from file paths.

{pstd}{opt columns(string)} specifies the column selectors associated with each specified variable (in order of appearance in varlist)

{pstd}{opt showresponse} makes no changes to the Stata environment and instead just print the JSON reponse to the console.
Useful for exploring the data source to figure out what your selectors should be.

{dlgtab:Optionals}

{pstd}{opt tableselector(string)} specifies the selector to use in finding the table burried in the json object tree.
The default is that the table starts immediately as an array of objects and contains no meta information.

{pstd}{opt replace} is necessary if you need to overrite existing data in varlist.

{pstd}{opt printonly} makes no changes to the Stata environment and instead just prints the results to the console.
Useful for making "dry runs" to see what you will get without commiting the results to Stata.

{pstd}{opt showresponse} makes no changes to the Stata environment and instead just (pretty) print the actual JSON reponse to the console.
Useful for exploring the data source to figure out what your selectors should be.

{pstd}{opt flatten} Cause the results to be converted into key(selector)-value pairs.
Useful for figuring out what the exact (flattented) selector is for a given piece of data in the JSON response. 
For complex JSON responses, this can result is a prodigeous amount of output.

{pstd}{opt savecontents(filename)} causes the raw contents (usually a JSON string) of the web response to the specified file. 
Useful when you want to cache the results locally for some reason, or if you are want to see the actual server response for debugging your scripts.

{pstd}{opt limit(#)} specifies the maximum number of observations to add to the Stata environment. 

{marker followurl}{pstd}{opt followurl(selector [#])} is for those servers which spread their results over more than one page, and give a url to follow for the next block. 
This option specifies the selector to use to find this url, as well the maximum number of times to follow the link.
If not specified, the default is 9 to to avoid hammering servers when the followurl() is used (for a total of 10 page loads).
A limit of zero (or less) signals that there is no limit to the number of pages to be loaded, but this can be very dangerous with some servers.

{pstd}{opt offset(#)} indicates the observation number to begin filling in the results at, and defaults to 1. 
Useful when a single dataset request must be broken up over multiple distinct queries and the server does not provide a follow-on URLs.

{pstd}{opt topscalars} causes the top level object scalars to be stored in the Stata environment as r() return values. 
In the case of arrays, only the first element is stored.
Note that attributes with spaces or other invalid stata names may be visible in the {stata return list} but will only be accessible from the mata environment. 
Useful when checking query responses for status/errors without having to repeat the query. 

{pstd}{opt aoa(#)} causes the parser to assume that the returned json objects are in fact a hybrid table, where the first # rows are treated as column/key headers and the rest of the rows are treated as matching values for the header template. 
This Array-of-Arrays format is order sensitive, since the row values are essentially bare and must be matched with the header keys in sequence.
While more than one row of headers can be skipped, only the last row of header keys will be matched by the selectors. 
Normally, only aoa(1) is needed for well-behaved hybrid tables.
Special interaction note: If aoa(-1) AND topscalars are specified together, then just the first two rows will be joined and treated as scalar values to be stored in r().


{title:Examples}

{pstd}{it:Load a single page of a twitter feed (about 15 observations) into three variables}:{p_end}
{space 10}{cmd: . gen str240 tw_fu=""}
{space 10}{cmd: . gen str240 tw_uid =""}
{space 10}{cmd: . gen str240 tw_geo =""}
{space 10}{cmd: . insheetjson tw_fu tw_uid tw_geo using "http://search.twitter.com/search.json?q=stata", table(results) col("from_user" "from_user_id_str" "geo:coordinates")}

{pstd}{it:Load a single page of a twitter feed (about 15 observations), but don't copy the obervations into Stata:}{p_end}
{space 10}{cmd: . gen str240 tw_fu=""}
{space 10}{cmd: . gen str240 tw_uid =""}
{space 10}{cmd: . gen str240 tw_geo =""}
{space 10}{cmd: . insheetjson tw_fu tw_uid tw_geo using "http://search.twitter.com/search.json?q=stata", table(results) col("from_user" "from_user_id_str" "geo:coordinates") print}

{pstd}{it:Load exactly 1000 entries from a twitter feed (possibly tossing some away):}{p_end}
{space 10}{cmd: . gen str240 tw_fu=""}
{space 10}{cmd: . gen str240 tw_uid =""}
{space 10}{cmd: . gen str240 tw_geo =""}
{space 10}{cmd: . insheetjson tw_fu tw_uid tw_geo using "http://search.twitter.com/search.json?q=stata", table(results) col("from_user" "from_user_id_str" "geo:coordinates") followurl(next_page) limit(1000)}

{pstd}{it:Load an entire twitter feed (this may take some time):}{p_end}
{space 10}{cmd: . gen str240 tw_fu=""}
{space 10}{cmd: . gen str240 tw_uid =""}
{space 10}{cmd: . gen str240 tw_geo =""}
{space 10}{cmd: . insheetjson tw_fu tw_uid tw_geo using "http://search.twitter.com/search.json?q=stata", table(results) col("from_user" "from_user_id_str" "geo:coordinates")  followurl(next_page 0)}

{pstd}{it:Examine the json source to figure out what columns are possible:}{p_end}
{space 10}{cmd: . insheetjson using "http://search.twitter.com/search.json?q=stata", showresponse }

{pstd}{it:Retrieve the top scalar values from a simple json return object:}{p_end}
{space 10}{cmd: . insheetjson using "http://search.twitter.com/search.json?q=stata", topscalars }
{space 10}{cmd: . return list }

{pstd}{it:Load a single page of a twitter feed (about 15 observations) into three variables, and check the status of the result}:{p_end}
{space 10}{cmd: . gen str240 tw_fu=""}
{space 10}{cmd: . gen str240 tw_uid =""}
{space 10}{cmd: . gen str240 tw_geo =""}
{space 10}{cmd: . insheetjson tw_fu tw_uid tw_geo using "http://search.twitter.com/search.json?q=stata", table(results) col("from_user" "from_user_id_str" "geo:coordinates") topscalars}
{space 10}{cmd: . return list}


{title:Selectors}
{pstd}Selectors are a series of named (or implicitly named in the case of arrays, which start at index "1") branches to take, starting from the given node (usually the root node).
All column names in the {opt:columns()} are flattened Selectors.
 
Given the following example JSON object: 
	{
	"foo" : "1", 
 	"bar": {
              "bar2":"2"
              },
  	"foobar": [ "bar1","bar2"]
     }
      
the results of the following selectors would be...
{lalign 30:{space 10}{opt ("foo")}} --> "1"
       
{lalign 30:{space 10}{opt ("foo","bar","bar2")}} --> "2"

{lalign 30:{space 10}{opt ("foobar","2")}} --> "bar2"

{title:Flattened Selectors}
{pstd}  A "flattened" selector is a single string with a colon inserted between each selector. For example,  ("foo":"bar") --> "foo:bar".
Selectors must be quoted if a space appears in one of the sub-selectors (ie. "foo bar:bar2"), though such selectors are rare.	

{title:Conversion Notes}
{pstd}Be aware that all values are ultimately converted into strings, so any further conversions are up to the user. 
Also, for a given position in the table (after the column selector has been applied), the following are attempted in this order:{p_end}
{ralign 10:(1)} Is it a string or other un-quoted literal (such as 'null')? If yes, use it.
{ralign 10:(2)} Is it an Array? If yes, combine the array values (scalars only) into a single string in the familiar "[ , ... ]" format.

{title:Missing libjson}
{pstd}This command uses the generic libjson library (libjson.mlib), and must be available in the Stata search path.
The latest library file can be downloaded from SSC (Boston College Archive) via the following link:

{title:Top level objects}
{pstd}If you need to retreieve a single scalar value from the top-level object (rather than a table of values), then omiting the {opt tableselector} will cause the top level object to be treated as a table with a single row. 

{pstd}
{stata ssc install libjson, replace}

{title:Author}

{pstd}
Erik Lindsley, Ph.D. ({browse "mailto:ssc@holocron.org":ssc@holocron.org})

{title:See also}

{pstd}
Required library: {help libjson}

{title:Special Thanks}

{pstd}To my testers & bug reporters:{p_end}
	Andrew Dyck ( http://www.andrewdyck.com/ )
	Stefan Bernhard
    Lucas Ferreira Mation
    Trevor Croft

{smcl}
{* 1.0.1 25jul2017}{...}
{ viewerdialog "twitter2stata" "dialog twitter2stata"}{...}
{ viewerjumpto "Syntax" "twitter2stata##syntax"}{...}
{ viewerjumpto "Options for twitter2stata search" "twitter2stata##search_options"}{...}
{ viewerjumpto "Description" "twitter2stata##description"}{...}
{ viewerjumpto "Remarks/Examples" "twitter2stata##remarks"}{...}
{ viewerjumpto "Authors" "twitter2stata##author"}{...}
{title:Title}

{p2colset 5 22 22 2}{...}
{p2col :{hi:twitter2stata} {hline 2}}Import data from Twitter{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}


{phang}
Set Twitter OAuth setting for your Twitter application

{p 8 32 2}
{cmdab:twitter2:stata} {cmd:setaccess} "{help twitter2stata##consumer_key:{it:consumer_key}}"  
"{help twitter2stata##consumer_secret:{it:consumer_secret}}"  
"{help twitter2stata##access_token:{it:access_token}}"  
"{help twitter2stata##access_secret:{it:access_secret}}"


{phang}
Import tweet data that match a specified search string

{p 8 32 2}
{cmdab:twitter2:stata} {cmdab:searcht:weets} "{help twitter2stata##search_string:{it:search_string}}"
[,  {it:{help twitter2stata##search_options:search_options}} {it:{help twitter2stata##fetch_options:fetch_options}}]


{phang}
Import user data on 1000 users that match the specified search string

{p 8 32 2}
{cmdab:twitter2:stata} {cmdab:searchu:sers} "{help twitter2stata##search_string:{it:search_string}}" [, {cmd:clear}]


{phang}
Import data for the specified user

{p 8 32 2}
{cmdab:twitter2:stata} {cmdab:getuser} "{help twitter2stata##id_name:{it:userId_or_userName}}"
[, {cmd:clear}]


{phang}
Import most recent like tweet data for a specified user

{p 8 32 2}
{cmdab:twitter2:stata} {cmdab:likes} "{help twitter2stata##id_name:{it:userId_or_userName}}" 
[, {cmd:clear} {opt sinceid(tweetid)}]


{phang}
Import most recent data on users the specified user is following

{p 8 32 2}
{cmdab:twitter2:stata} {cmdab:followi:ng} "{help twitter2stata##id_name:{it:userId_or_userName}}"
[, {cmd:clear}]


{phang}
Import most recent data on users the specified user is followed by

{p 8 32 2}
{cmdab:twitter2:stata} {cmdab:followe:rs} "{help twitter2stata##id_name:{it:userId_or_userName}}"
[, {cmd:clear}]


{phang}
Import most recent data on all lists the specified user either subscribes to or is a member of

{p 8 32 2}
{cmdab:twitter2:stata} {cmdab:lists} "{help twitter2stata##id_name:{it:userId_or_userName}}"
[, {it:{help twitter2stata##list_options:list_options}}]


{phang}
Import most recent tweet data for a specified user

{p 8 32 2}
{cmdab:twitter2:stata} {cmdab:tweets} "{help twitter2stata##id_name:{it:userId_or_userName}}"
[, clear {it:{help twitter2stata##fetch_options:fetch_options}}]


{phang}
Import most recent user data for the specified list

{p 8 32 2}
{cmdab:twitter2:stata} {cmdab:listu:sers} "{help twitter2stata##listid_name:{it:listId_or_listName}}"
[, {it:{help twitter2stata##list_options:list_options}}]


{phang}
Import most recent tweet data on the specified list

{p 8 32 2}
{cmdab:twitter2:stata} {cmdab:listt:weets} "{help twitter2stata##listid_name:{it:listId_or_listName}}"
[, clear {it:{help twitter2stata##fetch_options:fetch_options}}]


{marker consumer_key}{...}
{phang}
{it:consumer_key} is a valid OAuth consumer key for a user's Twitter application.

{marker consumer_secret}{...}
{phang}
{it:consumer_secret} is a valid OAuth consumer secret for a user's Twitter application.

{marker access_token}{...}
{phang}
{it:access_token} is a valid OAuth access token for a user account.

{marker access_secret}{...}
{phang}
{it:access_secret} is a valid OAuth access token secret for a user account.

{marker search_string}{...}
{phang}
{it:search_string} specifies the word or phrase to be searched for.

{marker id_name}{...}
{phang}
{it:userId_or_userName} is a valid Twitter user id ({cmd:747413565984800768}) 
or username ({cmd:KCrowStataCorp}).

{marker listid_name}{...}
{phang}
{it:listId_or_listName} is a valid Twitter list id ({cmd:747413565984800768}) or
list name and list owner ({cmd:statalist Stata}).



{synoptset 37}{...}
{marker search_options}{...}
{synopthdr :search_options}
{synoptline}
{synopt :{opt lang(langcode|all)}}restrict tweets to the given language{p_end}
{synopt :{cmdab:numt:weets(}#{bf:)}}set number of tweets to import{p_end}
{synopt :{cmdab:date:range:(}[{it:s_datestr}][{cmd:,} {it:e_datestr}]{cmd:)}}load tweet data within the last seven day date range {p_end}
{synopt :{cmd:geo(}{it:latitude}{cmd:,}{it:longitude}{cmd:,}{it:radius}[{cmd:,}{it:unit}]{cmd:)}}restrict data to tweets by users in a given location{p_end}
{synopt :{cmd:type(}{bf:mixed}|{bf:recent}|{bf:popular}{cmd:)}}set the type of tweets to be imported{p_end}
{synopt :{opt clear}}clear data in memory before loading Twitter data{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}{it:langcode} is a valid {browse "https://en.wikipedia.org/wiki/ISO_639-1":IS0 639-1} code.{p_end}
{p 4 6 2}{it:s_datestr and e_datestr} should be in YYYY-MM-DD format.{p_end}
{p 4 6 2}{it:unit} is either mi or km; default is mi.{p_end}


{synoptset 37}{...}
{marker fetch_options}{...}
{synopthdr :fetch_options}
{synoptline}
{synopt :{opt sinceid(tweetid)}}import tweets after {it:tweetid}{p_end}
{synopt :{opt maxid(tweetid)}}import tweets before {it:tweetid}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}{it:tweetid} is the string id that identifies a tweet.{p_end}

{synoptset 37}{...}
{marker list_options}{...}
{synopthdr :list_options}
{synoptline}
{synopt :{opt members}}import member data only; default is subscriber data only{p_end}
{synopt :{opt clear}}clear data in memory before loading data{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:twitter2stata} imports data from {browse "http://www.twitter.com/":Twitter}
using {browse "https://dev.twitter.com/overview/documentation":Twitter's REST API}.
Before using these commands, you must first grant {cmd:twitter2stata} access to 
your account.
{p_end}

{pstd}
{cmd:twitter2stata setaccess} sets the OAuth settings to access your Twitter 
application.
{p_end}

{pstd}
{cmd:twitter2stata searchtweets} imports tweet data that match the specified string.
The search string will be converted to a UTF-8/URL-encoded string.  This string 
cannot exceed 500 characters.
{p_end}

{pstd}
{cmd:twitter2stata searchusers} imports user data on 1000 users that
match the specified search string.  The command mimics the user search on 
Twitter's website.
{p_end}

{pstd}
{cmd:twitter2stata getuser} imports user data for the specified user. 
{cmd:twitter2stata likes} imports the most recent like
tweet dfdata for the specified user. {cmd:twitter2stata following} and
{cmd:twitter2stata followers} import data on the most recent users the 
specified user is following or is followed by, respectively.  
{cmd:twitter2stata lists} imports the most recent data on all lists the specified 
user either subscribes to or is a member of. {cmd:twitter2stata tweets} imports 
the most recent tweet data for the specified user.
{p_end}

{pstd}
{cmd:twitter2stata listusers} and  {cmd:twitter2stata listtweets} import user 
data and tweet data, respectively, for the specified list.
{p_end}

{pstd}
There are limits to the amount of data you can import.  {cmd:twitter2stata} will
import all data avaliable or as much data as the rate limit will allow.  The rate limits 
are subcommand specific.  See Twitters's  website for these
{browse "https://dev.twitter.com/rest/public/rate-limiting":rate limits}.  Commands
that import tweet data return {cmd:r(since_id)} or {cmd:r(max_id)} or both.  These
allow  you to remember your last fetch starting and ending points (tweetids). 
You can use {cmd:r(since_id)} to fetch the data that have been added since the 
previous fetch 15 minutes ago.  To search back in time (up to seven days), use 
{cmd:r(max_id)}.
{p_end}

{marker search_options}{...}
{title:Options}

{dlgtab:Search}

{phang}
{cmd:lang(}{it:langcode}|{it:all}{cmd:)} restricts tweets to the given language.  
The default language for tweets data is English ({cmd:en}).  You can specify 
{cmd:all}, which  will return tweets for all languages.

{phang}
{opt numtweets(#)} specifies the maximum number of tweet data to import.  If 
the number of tweet data imported is less than the number you specified, that
is all the tweet data available for the search string.  The default
is to import all tweet data available (unless the rate limit is reached).  

{phang}
{cmd:daterange(}[{it:s_datestr}],{it:e_datestr}{cmd:)} restricts 
tweets returned to a given date.  The date must be no older that seven days.  
{it:s_datestr} specifies the oldest day you want data returned from.   
{it:e_datestr} is the most recent date you want data returned from.  
If {it:s_datestr} is not specified, then {it:s_datestr} is seven days before today . 
If {it:e_datestr} is not specified, then today is assumed.   The format for 
both {it:s_datestr}  and {it:e_datestr} is YYYY-MM-DD.

{phang}
{cmd:geo(}{it:latitude}{cmd:,} {it:longitude}{cmd:,} {it:radius}[{cmd:,} {it:unit}]{cmd:)}
restricts data to tweets by users located within the given radius of the given 
latitude and longitude.  The radius unit can be kilometers {cmd:km} or miles 
{cmd:mi}.  The default radius unit is miles.

{phang}
{cmd:type(}{bf:mixed}|{bf:recent}|{bf:popular}{cmd:)} specifies the type of 
tweets to import. {cmd:mixed}, the default, includes both popular and real-time 
tweets.  {cmd:recent} imports only the most recent tweets. {cmd:popular} imports 
only the most popular tweets.

{phang}
{opt clear} specifies that the data in memory should be replaced 
with Twitter data.

{dlgtab:Fetch}

{phang}
{opt sinceid(tweetid)} imports tweet data that have been added since {it:tweetid}.

{phang}
{opt maxid(tweetid)} imports tweet data that came before {it:tweetid}.

{dlgtab:List}

{phang}
{opt members} with {bf:twitter2stata lists} imports the lists the given 
user is a member of.  {opt members} with {bf:twitter2stata listusers} imports 
user data on the members of the given list.  The default for both commands is 
to return subscriber (not member) data.

{phang}
{opt clear} specifies that the data in memory should be replaced 
with Twitter data.

{marker remarks}{...}
{title:Remarks}

{pstd}
Before you start using {cmd:twitter2stata}, you must first setup a Twitter application.
See the {browse "http://blog.stata.com/2017/07/25/importing-twitter-data-into-stata/":Stata blog}
for instructions on how to do this.  Once you have your Twitter application, copy the 
consumer key, consumer secret, access token, and access token secret strings 
into a do-file for use between Stata sessions.  You use the command
	
	{cmd}. twitter2stata setaccess "PNvEVSvy0BtGdZZZ" 	///
		"CMQTcbW3lBoXx5bETqLBYBd2iz9YYYYYUUU"	   ///
		"74741359848A076lTxYlATS6EgKxq5MnSP01Y"    ///
		"lkKb0ZvhJhg@u4MTBxEtFOpKG6DM8hCIFv6UdmAE"{txt}

{pstd}
to access your account data between Stata sessions.   We do not recommend you share
these strings with others because this could limit the amount of data you are allowed
to download.

{pstd}
If you recieve the error {cmd:r(655)} this means you have exceeded a Twitter
API rate limit.  You must wait 15 minutes before using the same command again.
You might look at using the {help sleep} command to help with this error.


{marker examples}{...}
{title:Examples}

{pstd}
Search tweet data for the string "star wars", importing tweets based on 
both recent data and popular data

	{cmd}. twitter2stata searchtweets "star wars"{txt}
	
{pstd}
Search tweet data for the string "star wars", for the dates 2017-07-06 through
2017-07-12, importing the first 1000 (or as many as you can) tweets

	{cmd}. twitter2stata searchtweets "star wars", numtweets(1000) ///
		daterange("2017-07-06", "2017-07-12"){txt}
		
{pstd}
Search tweet data for the string "star wars", from users located  in a 20-mile 
radius of College Station, TX, importing the first 1000 (or as many as you can) tweets.
		
	{cmd}. twitter2stata searchtweets "star wars", numtweets(1000) ///
		geo(30.6280, -96.3344, 20){txt}
		
{marker results}{...}
{title:Stored results}

{pstd}
{cmd:twitter2stata} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(max_id)}}the oldest tweet id of last query to the Twitter API{p_end}
{synopt:{cmd:r(since_id)}}the most recent tweet id of last query to the Twitter API{p_end}

{marker license}{...}
{title:License}

{pstd}
{cmd:twitter2stata} uses {browse "http://twitter4j.org/en/":Twitter4j} Java 
library. See the below license information.

{pstd}
Copyright 2007 Yusuke Yamamoto

{pstd}
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

      {browse "http://www.apache.org/licenses/LICENSE-2.0"}

{pstd}
Unless required by applicable law or agreed to in writing, software
Distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


{marker author}{...}
{title:Author}

{p 4} Kevin Crow, Dawson Deere{p_end}
{p 4} StataCorp LLC {p_end}
{p 4} kcrow@stata.com {p_end}

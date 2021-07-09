
*! version 1.1.0  01aug2011
*Neal Caren (neal.caren@unc.edu)


capture program drop nytimes

program nytimes
	syntax [, Number(numlist max=1) Feed(string)]
	version 9.2
tempname times


if "`number'"=="" {
	local items=5
}
else {
	local items=`number'
}
		
if "`feed'"=="" {
		local feed "homepage"
}

local feed: subinstr local feed " " "", all
tempfile xml xml1

capture copy "http://feeds.nytimes.com/nyt/rss/`feed'" `xml'
if _rc {
	capture copy "http://www.nytimes.com/services/xml/rss/nyt/`feed'" `xml'
	if _rc {
		capture copy "http://feeds1.nytimes.com/nyt/rss/`feed'" `xml'
		if _rc {
		    local url 
			capture copy "http://`feed'.blogs.nytimes.com/feed/" `xml'
				if _rc{
					di as error `"Trouble connecting to the `feed' feed. You might want to check the {browse "http://www.nytimes.com/services/xml/rss/index.html":Times feed list} to make sure a "`feed'" feed exists."'
					exit
				}
		}
	}
}

/*Fix some of the language issues*/
capture filefilter `xml' `xml1' , from("â€™") to("&#x2019;") replace
capture filefilter `xml1' `xml' , from("&rsquo;") to("&#x2019;") replace
	
	
file open `times' using `xml', read
file read `times' line
local count=1
while r(eof)==0 {
	if strpos(`"`line'"',"<channel>")!=0  {
		file read `times' line
		local title: subinstr local line "<title>NYT &gt; " "", all
		local title: subinstr local title "<title>" "", all
		local title: subinstr local title "</title>" "", all
		local title: subinstr local title `"`=char(9)'"' "", all
		local title=trim(`"`title'"')
	}
	
	if strpos(`"`line'"',"title>")!=0 & strpos(`"`line'"',"NYT")==0 {
		local line: subinstr local line "<title>" "", all
		local line: subinstr local line "</title>" "", all
		local headline: subinstr local line `"`=char(9)'"' "", all
		local headline=trim(`"`headline'"')
	}
	if strpos(`"`line'"',"isPermaLink")!=0  {
		local line: subinstr local line `"<guid isPermaLink="false">"' "", all
		local line: subinstr local line "</guid>" "", all
		local link: subinstr local line `"`=char(9)'"' "", all	
		local link=trim("`link'")
	}
	
	if strpos(`"`line'"',"pubDate")!=0  {
		local line: subinstr local line "<pubDate>" "", all
		local line: subinstr local line "</pubDate>" "", all
		local time: subinstr local line `"`=char(9)'"' "", all	
		local time: subinstr local time "+0000" "", all
		local time=trim(`"`time'"')	
	}			
	
	if strpos(`"`line'"',"<description>")!=0  {
		local line: subinstr local line "<description>" "", all
		local line: subinstr local line "</description>" "", all
		local line: subinstr local line "<![CDATA[" "", all
		local line: subinstr local line "]]>" "", all
		local line: subinstr local line "&lt;br clear=&quot;both&quot; style=&quot;clear: both;&quot;/&gt;" "", all
		local description: subinstr local line `"`=char(9)'"' "", all	
	}				

			
	if strpos(`"`line'"',"</item>")!=0 & `"`headline'"'~="" & `"`time'"'~="" {
		local headline`count' `"{browse "`link'":`headline'}"'
		local text`count'  `"`description' `time'."'
		local order "`order' \ `count'"
        local time2: subinstr local time "GMT" ""

        foreach word in Mon Tue Wed Thu Fri Sat Sun {
        	local time2: subinstr local time2 "`word', " ""
		}
		local clock=clock("`time2'", "DMYhms")
		local torder "`torder' \ `clock'"
		local ++count
	}
			
	file read `times' line
}

file close `times'

local start=`count'-`items'
if `start'<1 {
	local start=1
}

if `items'>`count' {
	local items=`count'
}




/*Figure out time order-thanks NJC for posting to Statalist about matrix sorting*/
     local order: subinstr local order "\" ""
     local torder: subinstr local torder "\" ""
     matrix time =((`order'),(`torder'))     
     mata : st_matrix("time", sort(st_matrix("time"), 2))

/*Print out feeds*/
di  as result _n "New York Times `title' Headlines" 
local count=`count'-1
local stop=`count'-`items'+1		/*Figure out where to stop*/
	 forvalues zt=`count'(-1)`stop' {
	 local z=time[`zt',1]
	 if `"`headline`z''"'~="" & strpos(`"`headline`z''"',"nytim")>0 {
	foreach clean in text`z' headline`z' {
		local `clean' : subinstr local `clean' "&amp;" "&", all
		local `clean': subinstr local `clean' "&#x201D;" `"""', all
		local `clean': subinstr local `clean' "&#x201C;" `"""', all
		local `clean': subinstr local `clean' "&#x2019;" "'", all
		local `clean': subinstr local `clean' "&#x2018;" "`", all
		local `clean': subinstr local `clean' "&#x2014;" "Ñ", all
		local `clean': subinstr local `clean' "&#xF3;" "`=char(151)'", all
	}


	 di  _n `"`headline`z''"' /*Display headline*/
	 local text`z': subinstr local text`z' "&amp;" "&", all
			forvalues i=1/5 {  /*Split text so it doesn't go too wide */
				local print: piece `i' 80 of `"`text`z''"', nobreak
				if `"`print'"'~="" {
				 di `"{text}`print'"'
					}
				}
		}		
	 }
end

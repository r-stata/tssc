{smcl}
{* *! version 2.0 09jun2015}{...}
{title:Title}

{phang}
{bf:asciiplot} {hline 2} Generate ASCII character map


{title:Syntax}

{p 8 17 2}
{cmd:asciiplot} [ {cmd:,} {it:scatter_options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{it:scatter_options}}Modifications to character map appearance{p_end}
{synoptline}


{title:Description}

{pstd}{cmd:asciiplot} creates a graph with a character map showing the 
decimal codes for plain ASCII and extended ASCII characters. With Stata before 
version 14, it uses the operating system's extended ASCII character encoding; 
with Stata version 14+, it uses Unicode encoding. The graph can be used to
identify quickly the ASCII code of a symbol or nonstandard character which you 
want to insert into a graph or SMCL text.


{title:Options} 

{p 4 8 2}{it:scatter_options} are options of 
{help twoway_scatter:twoway scatter}. 


{title:Examples}

{p 8}{cmd:asciiplot}{p_end}
{p 8}{cmd:asciiplot , scheme(lean1) saving(ascii.gph)}{p_end}

{pstd}We want to include the name of the Icelandic parliament, the 
"Al{c 254}ing", in a graph title. Use the character map graph to identify the 
code for the Icelandic character {bf:{c 254}} (thorn, pronounced like th in 
"thing"). On a computer with Western European encoding, the ASCII code is 
{cmd:254}; this is also the Unicode code. Here are four ways to enter this 
character in a graph text:

{phang}{ul:Method 1:} (Windows only) Press the 
{it:Alt} key while entering on the numeric keypad the 4-digit code, including 
leading zeros. {it:Alt}+{it:0254} inserts {bf:{c 254}}:{p_end}
{p 12}{cmd:.} {it:graph_command} {cmd:, title("Al{c 254}ing meetings")} ...

{phang}{ul:Method 2:} Enter one of these commands in the Command window:{p_end}
{p 12}{cmd:. display char(254)}{space 6}(Stata <14){p_end}
{p 12}{cmd:. display uchar(254)}{space 5}(Stata 14+){p_end}

{p 8}Next, copy-and-paste {bf:{c 254}} from the Results window 
to the graph command:{p_end}
{p 12}{cmd:.} {it:graph_command} {cmd:, title("Al{c 254}ing meetings")} ...

{phang}{ul:Method 3:} Use the {cmd:{c -(}{bind:char #}{c )-}} or
{cmd:{c -(}{bind:c #}{c )-}} SMCL directive:{p_end}
{p 12}{cmd:.} {it:graph_command} {cmd:, title("Al{c -(}c 254{c )-}ing meetings")} ... 

{phang}{ul:Method 4:} Use the {cmd:char(#)} or {cmd:uchar(#)} function to 
assign the symbol to a local macro which is then referenced in a subsequent 
graph command:{p_end}
{p 12}{cmd:. local th = char(254)}{space 6}(Stata <14){p_end}
{p 12}{cmd:. local th = uchar(254)}{space 5}(Stata 14+){p_end}
{p 12}{cmd:.} {it:graph_command} {cmd:, title("Al`th'ing meetings")} ...


{title:Alternatives}

{pstd}The help for {help smcl} describes how to insert some Western European 
characters in graphs and other SMCL text without using the extended ASCII or 
Unicode code. For example, you can generate the letter {bf:{c AE}} with 
{cmd:{c -(}{bind:c AE}{c )-}}, the letter {bf:{c c,}} with 
{cmd:{c -(}{bind:c c,}{c )-}}, and the Euro symbol with
{cmd:{c -(}{bind:c C=}{c )-}}. However, the list of characters is limited, 
and nonstandard characters used in other than Western European languages are not 
included. 

{pstd}The help for {help graph text} describes SMCL tags for Greek 
characters and for some other symbols and characters. To write a Greek 
sigma, enter {bf:{c -(}&sigma{c )-}}. To write a capital sigma, enter 
{bf:{c -(}&Sigma{c )-}}.

{pstd}The user-written {cmd:grtext} command requires Stata 14+. It helps inserting 
Unicode characters beyond those displayed by {cmd:asciiplot}. Install it by:{p_end}
{p 8}{cmd:. ssc install grtext}


{title:Remarks} 

{pstd}Prior to version 14, Stata used ASCII encoding of characters. The 
codes for plain ASCII are 33-127; for extended ASCII they are 128-255. There 
are several extended ASCII encoding schemes, for example, {cmd:Latin 1} and
{cmd:Windows-1252} for Western European Languages, {cmd:Latin 2} for some Central 
and Eastern European languages, and {cmd:Latin 4} using the Cyrillic 
alphabet. Thus, the same extended ASCII code may display different characters 
by computers using different encoding schemes.

{pstd}From version 14, Stata uses Unicode encoding of characters. This
gives access to thousands of characters and symbols, including Arabic, 
Cyrillic, Chinese, and other alphabets. The Unicode code point is the number 
we use with {cmd:uchar(#)} and other functions, but behind it is a more complex 
encoding (UTF-8) where each character is defined by one to four 8-bit bytes. For 
the characters represented in plain ASCII and in the {cmd:Latin 1} extended ASCII 
encoding, the Unicode code point is the same as the ASCII code.


{title:Authors}

{p 4 4 2}Michael Blasnik{break}
michael.blasnik@verizon.net
	 
{p 4 4 2}Svend Juul{break} 
Aarhus University{break}  
sj@ph.au.dk

{p 4 4 2}Nicholas J. Cox{break}
Durham University{break} 
n.j.cox@durham.ac.uk

{p 4 4 2}Michael Blasnik developed the original idea of the graph. Svend Juul
provided some design suggestions, and Nick Cox wrote the initial ado
file. Svend Juul developed version 2 of the command which works both with Stata 
14+ and earlier Stata versions.


{title:Also see}

{p 4}help for {help graph_text}{p_end}
{p 4}help for {help smcl}{p_end}
{p 4}help for {help char()}{p_end}
{p 4}help for {help uchar()} (Stata 14+ only){p_end}
{p 4}help for {help unicode} (Stata 14+ only)

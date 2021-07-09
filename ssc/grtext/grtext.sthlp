{smcl}
{* *! version 1.0 09jun2015}{...}
{title:Title}

{phang}
{bf:grtext} {hline 2} Inserting nonstandard characters in graph text


{title:Syntax}

{p 8 17 2}{cmd:grtext} {it:hexadecimal_number}


{title:Description}

{pstd}The purpose of {cmd:grtext} is to help creating graph texts with 
nonstandard characters, i.e., characters that are not directly available on the 
keyboard. {cmd:grtext} uses Unicode and requires Stata version 14 or higher;
users of earlier Stata versions may benefit from the user-written 
{cmd:asciiplot} command; see later.

{pstd}{cmd:grtext} reads a hexadecimal number and displays the corresponding
decimal number and the corresponding Unicode character. The decimal code is 
stored in {cmd:r(b10)} and the character in {cmd:r(char)}.

{pstd}Find some background information on ASCII and Unicode codes in the 
Remarks section of this help file.


{title:Examples}

{pstd}You may find the Unicode code for a character by the code charts from the 
Unicode Consortium, by Windows' {cmd:charmap} command, by similar functions in 
MS Word and Open Office, or by Mac's Character Viewer. However, these facilities 
all display the codes in hexadecimal format, while Stata's {cmd:uchar(#)} 
function requires the code in decimal format.

{pstd}We want to include the symbol for Indian Rupees ({bf:₹}) in an axis 
title. Use Unicode Corsortium's code charts,
{browse "http://unicode.org/charts/":http://unicode.org/charts/} and select:{p_end}
{p 8}{cmd:Other Symbols > Currency Symbols}

{pstd}Locate the {bf:₹} symbol and find its hexadecimal code, {bf:20B9}. To see 
the code in decimal format, type:{p_end}
{p 8}{cmd:. grtext 20b9}{p_end}
{p 8}Hex: 20B9{space 7}Dec: 8377{space 7}uchar(8377) = ₹

{pstd}Hexadecimal Unicode codes are sometimes prefixed by "{bf:U+}" or
"{bf:0x}". You may include or omit these prefixes when entering the code. Any 
leading zeros may be omitted, and you may use uppercase or lowercase letters.

{pstd}Here are two ways to enter the character in a graph text:

{phang}{ul:Method 1:} Copy-and-paste {bf:₹} from the Results window 
to the graph command:{p_end}
{p 12}{cmd:. }{it:graph command}{cmd: , ytitle("₹ per 100 $")} ...

{phang}{ul:Method 2:} Create a local macro containing the character, and 
insert it in the graph command:{p_end}
{p 12}{cmd:. local INR = uchar(8377)}{p_end}
{p 12}{cmd:. }{it:graph command}{cmd: , ytitle("`INR' per 100 $")} ...

{pstd}The {cmd:ustrunescape()} function uses the hexadecimal code directly,
albeit in a slightly more complex style:{p_end}
{p 8}{cmd:. local INR = ustrunescape("\u20b9")}


{title:Alternatives}

{pstd}The Character Map in Windows and the Character Viewer on a Mac display 
hexadecimal Unicode codes, but they also allow to copy characters directly to 
the Command window or the Do-file Editor. To open the Character Map in Windows, 
press {it:Windows_key}+{it:R} and enter {bf:charmap} in the dialog that 
opens. 

{pstd}Here we want to write the name of the Pravda newspaper with Cyrillic 
characters. In the Caracter Map, locate the Cyrillic character set and 
select the characters {bf:Правда}. Click on the Copy button; go to the Do-file 
Editor, and paste the text to the graph command:{p_end}
{p 8}{cmd:. }{it:graph_command}{cmd: , title("Правда circulation 1912-1991")} ...

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

{pstd}The user-written {cmd:asciiplot} command displays a graph with plain and 
extended ASCII codes with their decimal numbers; it works both with Stata 14+
and with Stata <14. To install it, type:{p_end}
{p 8}{cmd:. ssc install asciiplot}


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
encoding (UTF-8) where each character is defined by one to four 8-bit 
bytes. For the characters represented in plain ASCII and in the {cmd:Latin 1} 
extended ASCII encoding, the Unicode code point is the same as the ASCII code.


{title:Author}
	 
{pstd}Svend Juul{break} 
Aarhus University{break}  
sj@ph.au.dk


{title:Also see}

{p 4}help for {help graph text}{p_end}
{p 4}help for {help smcl}{p_end}
{p 4}help for {help unicode} (Stata 14+ only){p_end}
{p 4}help for {help uchar()} (Stata 14+ only)

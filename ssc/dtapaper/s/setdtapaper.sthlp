{smcl}
help for {cmd:setdtapaper}{right:also see: {helpb dtapaper}}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :Create global macros for {helpb dtapaper}} {p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}{cmd:setdtapaper, [{help setdtapaper##opt:{it:options}}]}

{p 8 17 2}{it: - or - }

{p 8 17 2}{cmd:setdtapaper, clear}

{title:Description}

{pstd} You can use {cmd: setdtapaper} to create global macros that will be used as default values in {helpb dtapaper}. 
With {cmd: setdtapaper} you can also enable (value "1") or disable (value "0") the checkboxes in {helpb dtapaper}. 
Thus you avoid entering all the information, that is required for {helpb dtapaper}, over and over again.

{title:Options}

{pstd} For a detailed description of each field see: {helpb dtapaper}

{marker opt}
    {it:options}{col 38}description
    {hline 70}
    {cmdab:t:itle:()}{col 30}{...} Dataset title

    {cmdab:ab:stract:()}{col 30}{...} Short description
    
    {cmdab:k:eywords:()}{col 30}{...} Keywords describing the data. Separate by ";"
    
    {cmdab:s:ource:()}{col 30}{...} Original source of data
    
    {cmdab:ac:cess:()}{col 30}{...} Access to data: DOI, URL, ...

    {cmdab:f:rom:()}{col 30}{...} Year of data: start

    {cmdab:t:o:()}{col 30}{...} Year of data: end

    {cmdab:au:thor:()}{col 30}{...} Author. Separate multiple authors with "and". 
    	
    {col 30}{...} Format: {it: (lastname, firstname)}

    {cmdab:i:nstitution:()}{col 30}{...} Institution

    {cmdab:c:ontact:()}{col 30}{...} Contact (E-Mail, Address, ...)

    {cmdab:p:ath:()}{col 30}{...} Path to an *.html file on your computer

    {hline 70}
    {cmdab:cb_var()}{col 30}{...} Include list of variables and labels (default 1)
    
    {cmdab:cb_val()}{col 30}{...} Include value labels (default 0)

    {cmdab:cb_lab()}{col 30}{...} Label dataset (default 1)

    {cmdab:cb_note()}{col 30}{...} Add note to dataset (default 1) *

    {cmdab:cb_drop()}{col 30}{...} Drop old note (default 0)

    {cmdab:cb_save()}{col 30}{...} Save and replace data (default 0)

    {cmdab:cb_n()}{col 30}{...} Include number of observations (default 1)

    {cmdab:cb_nvar()}{col 30}{...} Include number of variables (default 1)

    {cmdab:cb_name()}{col 30}{...} Include filename (default 1)

    {hline 70}
    {cmdab:clear}{col 30}{...} clears out all global macros
	
 
    * The single notes cannot be modified by {cmd:setdtapaper}. 
      If you want to enable/disable those checkboxes you have to use {helpb dtapaper}.
	
	
{title:Examples}

{cmd:. setdtapaper, author(Thewes, Christoph) contact(thewes@uni-potsdam.de)}

{cmd:. setdtapaper, ///}
{cmd:{col 4} title(A new Panel Survey) ///}
{cmd:{col 4} abstract(This new panel survey is based on ...) ///}
{cmd:{col 4} keywords(Panel; Income; Inequality; Germany) ///}
{cmd:{col 4} access(http://webserver.com/files.zip) ///}
{cmd:{col 4} from(2011) ///}
{cmd:{col 4} to(2014) ///}
{cmd:{col 4} author(Thewes, Christoph and Saalbach, Claudia) ///}
{cmd:{col 4} institution(University of Potsdam) ///}
{cmd:{col 4} contact(thewes@uni-potsdam.de) ///}
{cmd:{col 4} path(D:/Folder/filename.html)}

{cmd:. setdtapaper, ///}
{cmd:{col 4} author(Thewes, Christoph and Saalbach, Claudia) ///}
{cmd:{col 4} title(A new Panel Survey) ///}
{cmd:{col 4} cb_var(1) ///}
{cmd:{col 4} cb_val(1) ///}
{cmd:{col 4} cb_lab(0) ///}
{cmd:{col 4} cb_note(1) ///}
{cmd:{col 4} cb_drop(0) ///}
{cmd:{col 4} cb_save(1) ///}
{cmd:{col 4} cb_n(1) ///}
{cmd:{col 4} cb_nvar(0) ///}
{cmd:{col 4} cb_name(0)}


{p 1 17 2}{it: with abbreviations:}

{cmd:. setdtapaper, ///}
{cmd:{col 4} t(A new Panel Survey) ///}
{cmd:{col 4} ab(This new panel survey is based on ...) ///}
{cmd:{col 4} k(Panel; Income; Inequality; Germany) ///}
{cmd:{col 4} ac(http://webserver.com/files.zip) ///}
{cmd:{col 4} f(2011) ///}
{cmd:{col 4} t(2014) ///}
{cmd:{col 4} au(Thewes, Christoph and Saalbach, Claudia) ///}
{cmd:{col 4} i(University of Potsdam) ///}
{cmd:{col 4} c(thewes@uni-potsdam.de) ///}
{cmd:{col 4} p(D:/Folder/filename.html)}


{p 1 17 2}{it: Clear out all global macros:}

{cmd:. setdtapaper, clear}

{title:Author}
{pstd}Christoph Thewes, University of Potsdam, thewes@uni-potsdam.de{p_end}
{psee} {hi:http://www.uni-potsdam.de/soziologie-methoden/thewes.html}

{title:Version}
{pstd}1.0.0: 02/12/2015

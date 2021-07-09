{smcl}
{hline}
{hi:help htmltab2stata}{right: v. 1.0 - January 2019}
{hline}
{title:Title}

{p 4 4}{cmd:htmltab2stata} - Loading html tables into Stata.{p_end}

{title:Contents}

{p 4}{help htmltab2stata##syntax:Syntax}{p_end}
{p 4}{help htmltab2stata##description:Description}{p_end}
{p 4}{help htmltab2stata##options:Options}{p_end}
{p 4}{help htmltab2stata##Examples:Examples}{p_end}
{p 4}{help htmltab2stata##about:About}{p_end}


{marker syntax}{title:Syntax}

{p 4 13}The general syntax is:{p_end}

{p 6 13}{cmd: htmltab2stata  , url({it:url}) [tablenumber({it:integer}) firstrow href]}{p_end}

{marker options}{title:Options}

{p 4 8}{cmd:url({it:url})} the url of the html website to be processed.
The url has to be a downloadable html website.
{it:url} can be a webadress or a local html file.
{p_end}

{p 4 8}{cmd:tablenumber({it:integer})} number of table within the html document.
Default is 1, i.e. the first table is processed.{p_end}

{p 4 8}{cmd:firstrow} Use firstrow of table as variable names.{p_end}

{p 4 8}{cmd:href} Links enclosed in {cmd:<a href=....></a>} are added to the content
transferred to Stata.
{p_end}

{marker description}{title:Description}

{p 4 4}{cmd:htmltab2stata} parses html code from websites.
It detects tables enclosed with the html {cmd:<table>} environment and transforms 
the table into a Stata dataset. 
To do so, {cmd:htmltab2stata} parses the html code and uses {cmd:<tr>} as
row identifiers and code enclosed in {cmd:<td>} as columns.
It only transfers content which is not enclosed in {cmd:< >} to Stata,
unless option {cmd:href} is used for links.
Empty cells remain empty in the Stata dataset.{p_end}

{marker Examples}{title:Examples}

{p 4 8}For all examples, the following table in html code saved in
{it:table.html} is processed:

{col 12}{com}Content
{col 12}Table 1
{col 12}<table>
{col 12} <tr><th>Country</th><th>Population</th><th>GDP</th></tr>
{col 12}  <tr><td>Country A</td><td>10</td><td>100</td></tr>
{col 12}  <tr><td>Country B</td><td>20</td><td>5</td></tr>
{col 12}  <tr><td>Country C</td><td>500</td><td>10</td></tr>
{col 12}</table>
{col 12}More Content
{col 12}Table 2
{col 12}<table>
{col 12}  <tr><th>Firstname</th><th>Surname</th><th>Webpage</th></tr>
{col 12}  <tr><td>Adam</td><td>Smith</td><td>none</td></tr>
{col 12}  <tr><td>Allan</td><td>Richards</td><td><a href="www.google.com">webpage</a></td></tr>
{col 12}  <tr><td>Richard</td><td>Johnson</td><td></td></tr>
{col 12}</table>
{reset} 

{p 4 8}Loading Table into Stata as a dataset:{p_end}

{col 12}{stata htmltab2stata , url(table.html)}

{p 4 8}Returns:{p_end}

{col 12}{com}.list
{col 12}
{col 12}     +---------------------------------+
{col 12}     |    myvar1       myvar2   myvar3 |
{col 12}     |---------------------------------|
{col 12}  1. |   Country   Population      GDP |
{col 12}  2. | Country A           10      100 |
{col 12}  3. | Country B           20        5 |
{col 12}  4. | Country C          500       10 |
{col 12}     +---------------------------------+
{reset}

{p 4 8}To use the first column as variable names the option {cmd:firstrow} is required.{p_end}

{col 12}{stata htmltab2stata , url(table.html) firstrow}

{col 12}{com}.list
{col 12}
{col 12}     +----------------------------+
{col 12}     |   Country   Popula~n   GDP |
{col 12}     |----------------------------|
{col 12}  1. | Country A         10   100 |
{col 12}  2. | Country B         20     5 |
{col 12}  3. | Country C        500    10 |
{col 12}     +----------------------------+
{reset}

{p 4 8}To process Table 2, use the first row as variable names and add the url
of the hyperlink as text to the contents:{p_end}

{col 12}{stata htmltab2stata , url(table.html) firstrow tablenumber(2) href}

{col 12}{com}. list
{col 12}
{col 12}     +----------------------------------------------+
{col 12}     | Firstn~e    Surname                  Webpage |
{col 12}     |----------------------------------------------|
{col 12}  1. |     Adam      Smith                     none |
{col 12}  2. |    Allan   Richards   www.google.com webpage |
{col 12}  3. |  Richard    Johnson                          |
{col 12}     +----------------------------------------------+
{reset}

{marker about}{title:Author}

{p 4}Jan Ditzen (Heriot-Watt University){p_end}
{p 4}Email: {browse "mailto:j.ditzen@hw.ac.uk":j.ditzen@hw.ac.uk}{p_end}
{p 4}Web: {browse "www.jan.ditzen.net":www.jan.ditzen.net}{p_end}

{marker changelog}{title:Changelog}

{p 4 8}This version: 1.0{p_end}

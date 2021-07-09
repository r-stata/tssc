{smcl}
{* *! version 0.13.03  5mar2013}{...}
{cmd:help valcuofon_afc}
{hline}

{title:Title}

{phang}
{bf:valcuofon_afc} {hline 2} M{c o'}dulo de stata para descargar valores cuota (y patrimonio) diarios de los fondos de cesant{c i'}a

{title:Syntax}

{p 8 17 2}
{cmdab:valcuofon_afc}
[, {opt a:gno}(#)
{opt s:ave}({help filename})
{opt c:lear}]

{phang}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt a:gno}(#)}A{c n~}o que se desea descargar (por defecto 2013).{p_end}
{synopt:{opt s:ave}({it:filename})}Nombre del archivo (dta) al cual exportar los datos (preservar{c a'} la informaci{c o'}n cargada).{p_end}
{synopt:{opt c:lear}}Reemplaza los datos actualmente cargados por los que se descargar{c a'}n.{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
{cmd:valcuofon_afc} Se conecta directamente al centro de estad{c i'}sticas de la
Superintendencia de Pensiones y, en base a a{c n~}o seleccionado, descarga los 
valores cuota y patrimonio diarios para los fondos CIC y FCS.{p_end}

{title:Examples}

{pstd}Descargando datos del 2013{p_end}
{phang2}{cmd:. valcuofon_afc}{p_end}
{phang2}{it:   ({stata valcuofon_afc:click para ejecutar})}{p_end}

{pstd}Descargando datos del 2010 y guard{c a'}ndolos en {it:cuotas_y_patrimonio.dta}{p_end}
{phang2}{cmd:. valcuofon_afc, agno(2010) save(cuotas_y_patrimonio.dta)}{p_end}
{phang2}{it:   ({stata valcuofon_afc, agno(2010) save(cuotas_y_patrimonio.dta):click para ejecutar})}{p_end}

{title:References}

{pstd}Superintendencia de Pensiones, {it:Centro de Estad{c i'}sticas} {browse "http://www.spensiones.cl/safpstats/stats/"}{p_end}

{title:Author}

{pstd}
George Vega Yon, Superindentencia de Pensiones. {browse "mailto:gvega@spensiones.cl"}
{p_end}

{title:Also see}

{psee}{help valcuofon_afp}, {rnethelp "http://fmwww.bc.edu/RePEc/bocode/w/worldstat.sthlp":worldstat} (online){p_end}


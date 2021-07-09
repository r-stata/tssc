{smcl}
{* *! version 0.13.03  5mar2013}{...}
{cmd:help valcuofon_afp}
{hline}

{title:Title}

{phang}
{bf:valcuofon_afc} {hline 2} M{c o'}dulo de stata para descargar valores cuota (y patrimonio) diarios de los fondos de pensiones

{title:Syntax}

{p 8 17 2}
{cmdab:valcuofon_afp}
[, {opt agnoi:nicio}(#)
{opt agnof:in}(#)
{opt f:ondo}({it:nombre})
{opt s:ave}({help filename})
{opt c:lear}]

{phang}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt agnoi:nicio}(#)}A{c n~}o desde el que se desea descargar (por defecto 2013).{p_end}
{synopt:{opt agnof:in}(#)}A{c n~}o hasta el que que se desea descargar (por defecto 2013).{p_end}
{synopt:{opt f:ondo}({it:nombre})}Fondo de pensi{c o'}n del cual se desea obtener los valores cuota (por defecto el A).{p_end}
{synopt:{opt s:ave}({it:filename})}Nombre del archivo (dta) al cual exportar los datos (preservar{c a'} la informaci{c o'}n cargada).{p_end}
{synopt:{opt c:lear}}Reemplaza los datos actualmente cargados por los que se descargar{c a'}n.{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
{cmd:valcuofon_afp} Se conecta directamente al centro de estad{c i'}sticas de la
Superintendencia de Pensiones y, en base al rango de a{c n~}os seleccionado, descarga los 
valores cuota y patrimonio diarios para un fondo en espec{c i'}fico de las AFP.{p_end}

{title:Examples}

{pstd}Descargando datos del 2013{p_end}
{phang2}{cmd:. valcuofon_afp}{p_end}
{phang2}{it:   ({stata valcuofon_afp:click para ejecutar})}{p_end}


{pstd}Descargando datos en el rango 2010-2011 y guard{c a'}ndolos en {it:cuotas_y_patrimonio.dta}
del fondo C{p_end}
{phang2}{cmd:. valcuofon_afp, agnoi(2010) agnof(2011) f(C) save(cuotas_y_patrimonio.dta)}{p_end}
{phang2}{it:   ({stata valcuofon_afp, agnoi(2010) agnof(2011) f(C) save(cuotas_y_patrimonio.dta):click para ejecutar})}{p_end}

{title:References}

{pstd}Superintendencia de Pensiones, {it:Centro de Estad{c i'}sticas} {browse "http://www.spensiones.cl/safpstats/stats/"}{p_end}

{title:Author}

{pstd}
George Vega Yon, Superindentencia de Pensiones. {browse "mailto:gvega@spensiones.cl"}
{p_end}

{title:Also see}

{psee}{help valcuofon_afc}, {rnethelp "http://fmwww.bc.edu/RePEc/bocode/w/worldstat.sthlp":worldstat} (online){p_end}


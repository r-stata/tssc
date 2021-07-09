{smcl}
{* *! version 0.13.03  6mar2013}{...}
{cmd:help mod11}
{hline}

{title:Title}

{phang}
{bf:mod11} {hline 2} Generador de digito verificador (DV) (Modulo 11)

{title:Syntax}

{phang}
Implementacion vectorial (gen).

{p 8 17 2}
{cmdab:mod11} {help varname}
, {opt g:enerate}({help newvar})
[{opt r:eplace}]

{phang}
Implementacion escalar.

{p 8 17 2}
{cmdab:mod11i} {it:#numero}

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt g:enerate}}Nombre de la variable a crear que contendra el DV.{p_end}
{synopt:{opt r:eplace}}En el caso de existir, reemplaza la variable especificada en el argumento {opt g:enerate}.{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
{cmd:mod11} Aplica el algoritmo {it:modulo 11} a un numero entero entregando 
como resultado la variable {it:digito verificador}.
{p_end}

{pstd}
En el caso de querer calcular el DV para solo un numero, {cmd:mod11i} permite
el calculo inmediato ingresando como unico argumento el numero en si.
{p_end}

{title:Examples}

{pstd}Generando la variable {it:dv} para la variable {it:rut}{p_end}
{phang2}{cmd:. mod11 rut, g(dv)}
{p_end}

{pstd}Calculo del DV para el 12345{p_end}
{phang2}{cmd:. mod11i 12345}
{p_end}

{title:Saved results}

{pstd}
{cmd:mod11i} almacena lo siguiente en {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Escalares}{p_end}
{synopt:{cmd:r(number)}}N{c u'}mero ingresado{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(dv)}}D{c i'}gito verificarod generado{p_end}


{title:Author}

{pstd}
George Vega Yon, Superindentencia de Pensiones. {browse "mailto:gvega@spensiones.cl"}
{p_end}
{pstd}
Eugenio Salvo Cifuentes, Superindentencia de Pensiones. {browse "mailto:esalvo@spensiones.cl"} (colaborador)
{p_end}

{title:References}

{pstd}
Rol Unico Tributario (Articulo en Wikipedia) {browse "http://es.wikipedia.org/wiki/Rol_%C3%9Anico_Tributario"}
{p_end}

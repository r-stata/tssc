{smcl}
{* *! version 1 16jan2012}{...}
{cmd:help cuentacot}
{hline}

{title:Título}
{phang}
{bf:cuentacot} {hline 2} Contador de cotizaciones


{title:Sintáxis}
{p 8 17 2}
{cmdab:cuentacot}
{it:periodo}
{it:persona}
[{it:empleador}
{cmd:,}
{it:{help cuentacot##resul_opt:cuentas}}
{it:{help cuentacot##para_opt:parametros}}
{it:{help cuentacot##variables_adicionales_opt:variables.adicionales}}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{marker resul_opt}{...}
{syntab:Cuentas}
{synopt:{opt dis:continuas}}Contador de cotizaciones discontinuas.{p_end}
{synopt:{opt con:tinuas}}Contador de {bf:ncot} cotizaciones continuas.{p_end}
{synopt:{opt contemp:leador}}Contador de {bf:ncot} cotizaciones continuas con un mismo empleador.{p_end}
{synopt:{opt emp:leador}}Contador de {bf:ncot} cotizaciones discontinuas con el mismo empleador.{p_end}
{synopt:{opt mennc:ont}}Contador de {bf:ncot} cotizaciones continuas en los últimos {bf:nper} periodos.{p_end}
{synopt:{opt mennd:iscont}}Contador de {bf:ncot} cotizaciones discontinuas en los últimos {bf:nper} periodos.{p_end}

{marker para_opt}{...}
{syntab:Parámetros}
{synopt:{opt nc:ot}}Número de cotizaciones (por defecto 12).{p_end}
{synopt:{opt np:er}}Número de periodos (por defecto 24).{p_end}

{marker variables_adicionales_opt}{...}
{syntab:Variables Adicionales}
{synopt:{opt ns:olic(varname)}}Variable de número de solicitud (para uso en seguro de cesantía).{p_end}
{synopt:{opt ti:pcon(varname)}}Variable de tipo de contrato.{p_end}
{synopt:{opt k:eep}}Preservar variables de cuenta.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
Es fundamental que el set de datos a utilizar corresponda a una base conformada en 
función de {it:individuo} y {it:periodo}. De especificar el campo {it:nsolic} (
número de solicitud al seguro de cesantía), al momento de registrar beneficio, 
i.e. {it:nsolic} deja de ser nulo, todos los contadores continuos parten desde 0.


{title:Descripción}
{pstd}
Para uso de bases de datos de remuneraciones/cotizaciones. Genera variables 
de tipo {it:dicotómicas} en base a algoritmo de cuenta de número de cotizaciones 
de cada individuo para cada momento del tiempo. Las variables de cuenta pueden
ser conservadas utilizando la opción {opt k:eep}.

{pstd}
Las variables principales a especificar en el contador corresponden a {cmd:periodo} 
(campo numérico de fecha en formato YYYYMM), {cmd:persona} (variable id del individuo) y, 
opcionalmente, {cmd:empleador} (variable id del empleador).

{pstd}
En base al campo {cmd:periodo}, el algoritmo determina qué periodos son válidos para
el cálculo en los resultados de {cmd: menncont} y {cmd: menndiscont}. Este punto es
importante pues el comando considera ventanas de tiempo entre observaciones de un 
mismo individuo; por lo que 3 observaciones seguidas no son consideradas como 3 
remuneraciones/cotizaciones continuas necesariamente, depende del periodo en que se
reliza cada una.

{pstd}
En el caso de contar con una base de cotizaciones y solicitudes al seguro de cesantía
(caso especial utilizado en la Superintendencia), de especificar número de solicitud
(en {opt ns:olic}), las cuentas considerarán solicitudes al seguro, haciendo que
en las observaciones marcadas como solicitudes al seguro el contador no avance y
vuelva a 0 inmediatamente después de la solicitud.

{pstd}
Si alguna de las variables a generar ya existe, por defecto el comando la reemplaza
por la nueva.

{pstd}
El comando conserva el orden original de la base de datos antes de ser ejecutado.


{title:Options}

{dlgtab:Cuentas}

{phang}
{cmd:discontinuas} Genera variable de cuenta de cotizaciones discontinuas independiente
del tipo de contrato, y la almacena como {bf:cuenta_cot_dis}.

{phang}
{cmd:continuas} Genera variable {it:dicotómica} en base a cuenta de cotizaciones continuas,
donde {bf:cotiza_continuas`ncot'} es igual a 1 si {bf:cotiza_continuas`ncot' >=} {opt nc:ot}.
Si cambia el tipo de contrato a plazo definido ({cmd:tipcon} es cero)

{phang}
{cmd:contemp} Genera variable {it:dicotómica} en base a cuenta de cotizaciones continuas
con el mismo empleador, donde {bf:cot_`ncot'_emp_cont} es igual a 1 si 
{bf:cuenta_cot_cont_emp >=} {opt nc:ot}.

{phang}
{cmd:empleador} Genera variable {it:dicotómica} en base a cuenta de cotizaciones discontinuas con
el mismo empleador, donde {bf:cot_`ncot'_emp_dis} es igual a 1 si {bf:`cuenta_`ncot'_ult_cot_emp' >=} {opt nc:ot}

{phang}
{cmd:menncont} Genera variable {it:dicotómica} en base a cuenta de cotizaciones continuas
en los últimos {opt n:per} periodos, donde {bf:cot_`ncot'_en_`nper'_cont} es igual a 1 si 
{bf:cuenta_cot_`ncot'_en_`nper'_cont >=} {opt nc:ot}

{pmore}
El resultado se puede leer como "{it:{cmd:ncot} cotizaciones continuas en los últimos {cmd:nper} periodos}"

{phang}
{cmd:menndisc} Genera variable {it:dicotómica} en base a cuenta de cotizaciones discontinuas
en los últimos {opt n:per} periodos, donde {bf:cot_`ncot'_en_`nper'_dis} es igual a 1 si 
{bf:cuenta_cot_`ncot'_en_`nper'_dis >=} {opt nc:ot}

{pmore}
El resultado se puede leer como "{it:{cmd:ncot} cotizaciones discontinuas en los últimos {cmd:nper} periodos}"

{dlgtab:Parámetros}

{phang}
{cmd:ncot} Entero. Número de cotizaciones (por defecto 12) a considerar en el cálculo
de {cmd:continuas}, {cmd:contemp}, {cmd:menncont} y {cmd:menndisc}.

{phang}
{cmd:nper} Entero. Número de periodos (por defecto 24) a considerar en el cálculo de
{cmd:menncont} y {cmd:menndisc}.

{dlgtab:Variables adicionales}

{phang}
{cmd:nsolic({it:{help varname:varname}})} Variable que contiene el número de solicitud. Se utiliza
para considerar solicitudes de beneficio de modo tal de llevar los contadores
a 0. El comando identifica un periodo como {it:solicitud} cuando {cmd:nsolic} deja
de ser {missing}.

{phang}
{cmd:tipcon({it:{help varname:varname}})} Variable que contiene el tipo de contrato.
Se utiliza para considerar el tipo de contrato al momento de la cuenta de cotizaciones 
continuas ({cmd:continuas}). Realizando cuenta de cotizaciones sólo cuando {cmd:tipcon}
es igual a 1, i.e. personas con contrato indefinido.


{title:Ejemplos}

{pstd}Generar dicotómica igual a 1 si es que la observación lleva 6 cotizaciones 
continuas acumuladas sin considerar tipo de contrato o solicitudes sin quedarse con el contador.{p_end}

{phang}
{cmd:. sysuse cuentacot}
{cmd:. cuentacot periodo idper, cont ncot(6)}

{pstd}para quedarse con el contador

{phang}
{cmd:. cuentacot periodo idper, cont ncot(6)}


{pstd}Generar dicotómica igual a 1 si es que la observación lleva 6 cotizaciones 
continuas acumuladas considerando el tipo de contrato y solicitudes.{p_end}

{phang}
{cmd:. cuentacot periodo idper, cont ncot(6) nsolic(nsolic) tipcon(tipcon)}


{pstd}Generar dicotómicaeana igual a 1 si es que la observación lleva 3 cotizaciones 
acumuladas en los últimos 6 periodos considerando el tipo de contrato y solicitudes 
al seguro de cesantía.{p_end}

{phang}
{cmd:. cuentacot periodo idper, mennd ncot(3) nper(6) nsolic(nsolic) tipcon(tipcon)}


{title:Referencias}

{p 0 2}Superintendencia de Pensiones (2010b) "Seguro de Cesantía en Chile", {it: Gráfica LOM}, disponible en {browse "http://www.spensiones.cl/573/article-7513.html"}

{p 0 2}George Vega Yon (2012) "Cuentas Difíciles: Implementación del comando cuentacot", disponible en {browse "https://sites.google.com/site/gvegayon/software/cuentacot.zip"}


{title:Autor}

{pstd}
Programador: George Vega Yon, Superindentencia de Pensiones. Cualquier problema a {browse "mailto:gvega@spensiones.cl"}

{pstd}
Colaboración: Evelyn Benvin Aramayo, Superintendencia de Pensiones {browse "mailito:ebenvin@spensiones.cl"}

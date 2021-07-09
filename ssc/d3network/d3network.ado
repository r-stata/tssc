*! version 1.0  23may2014  Sebastian Pink & Sabrina Vogel

program define d3network

	version 11

	syntax [using], network(varlist)     id(varlist) ///
			        distinction(varlist) nodecov(varlist) ///
			       [nodecov_newnames(string) ///
			        arrows replace]
			
quietly{


* --------------------------------------------------------------------------------------------------			
* Preamble1: Save original dataset, generate folder, deal with errors, ...
* --------------------------------------------------------------------------------------------------


* Check if d3networks already have been generated and would be overr
* ----------------------------------------
loc d3cpwd `c(pwd)'
loc d3path: word 2 of `using'
if "`d3path'" == "" {  
	if "`replace'" != "replace" {
		* Check existence of jsondata folder or index.html
		cap confirm file "index.html"
		loc indexexists = _rc
		cap confirm file "./jsondata/nul"
		if `indexexists' == 0 | _rc == 0 {
			n: di as err "One or multiple networks already exist. To override, specify the replace option."
			exit 602
		}
	}
	* Start out with an empty folder and no index file
	cap confirm file "index.html"
	if _rc == 0 {
		erase "index.html"
	}
	cap confirm file "./jsondata/nul"
	if _rc != 0 {
		mkdir "jsondata"
	}
	else {
		local d3list: dir "./jsondata/" files "*"
		foreach d3nwfile of loc d3list {
			erase `"./jsondata/`d3nwfile'"'
		}
	}
}
else {
	loc d3path: subinstr loc d3path "\" "/", all
	cd "`d3path'"
	if "`replace'" != "replace" {
		* Check existence of jsondata folder or index.html
		cap confirm file "index.html"
		loc indexexists = _rc
		cap confirm file "./jsondata/nul"
		if `indexexists' == 0 | _rc == 0 {
			n: di as err "One or multiple networks already exist. To override, specify the replace option."
			exit 602
		}
	}
	* Start out with an empty folder and no index file
	cap confirm file "`d3path'/index.html"
	if _rc == 0 {
		erase "`d3path'/index.html"
	}
	cap confirm file "./jsondata/nul"
	if _rc != 0 {
		mkdir "`d3path'/jsondata"
	}
	else {
		local d3list: dir "./jsondata/" files "*"
		foreach d3nwfile of loc d3list {
			erase `"./jsondata/`d3nwfile'"'
		}
	}

}


* Check for missing values on the nodal characteristics
* -----------------------------------------------------
d,s
loc d3nodoverall = r(N)
foreach d3nodvar of loc nodecov {
	su `d3nodvar', meanonly
	if `r(N)' != `d3nodoverall' {
		n: di as err "Nodal covariate `d3nodvar' exhibits missings. For further information see help file under 'Remarks'."
		exit 416
	}
}



* Save used dataset
* -----------------
tempname d3useddata
tempfile `d3useddata'
save ``d3useddata'', replace






* --------------------------------------------------------------------------------------------------







			
* --------------------------------------------------------------------------------------------------			
* Preamble2: Generate index.html as well as template.html
* --------------------------------------------------------------------------------------------------		
	
* (1) index.html to browse through networks
* -----------------------------------------
file open index using "index.html", write replace
file write index `"<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN"    "http://www.w3.org/TR/html4/frameset.dtd">"'
file write index `"<html><head><title>Networks</title></head><frameset cols="*,200">"'
file write index `"<frame src="jsondata/network1.html" name="networks">"'
file write index `"<frame src="jsondata/menu.html" name="Selection of students networks">"'
file write index `"<noframes><body><p><a href="Networks.html">Students networks</a>"'
file write index `"<a href="Selection.html">Selection of students networks</a></p></body>"'
file write index `"</noframes></frameset></html>"'
file close index	
			
	
* (2.1) Undirected: template.html to generate the various individual network html files from
* ------------------------------------------------------------------------------------------

if "`arrows'" != "arrows" {
file open template using "template.html", write replace
file write template `"<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN""' _n
file write template `""http://www.w3.org/TR/html4/loose.dtd">"' _n
file write template `"<html>"' _n
file write template `"<head>"' _n
file write template `"<title> Students networks</title>"' _n
file write template `"<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">"' _n
file write template `"<meta charset="utf-8">"' _n
file write template `"<style>"' _n
file write template `".link {"' _n
file write template `"stroke: #000;"' _n
file write template `"stroke-width: 1.5px;"' _n
file write template `"}"' _n
file write template `".node {"' _n
file write template `"cursor: move;"' _n
file write template `"fill: #ccc;"' _n
file write template `"stroke: #000;"' _n
file write template `"stroke-width: 1.5px;"' _n
file write template `"}"' _n
file write template `".node.fixed {"' _n
file write template `"fill: #f00;"' _n
file write template `"}"' _n
file write template `"div {float: left;}"' _n
file write template `".title {font-weight: bold;"' _n
file write template `"color: #1b87a2;}"' _n
file write template `"div.tooltip {/* set the CSS for tooltip divs */"' _n
file write template `"  "' _n
file write template `"position: absolute;/* reference for measurement */"' _n
file write template `"text-align: center;/* align the text to the center */"' _n
file write template `"width: 60px;/* set the width of the rectangle */"' _n
file write template `"height: 28px;/* set the height of the rectangle */"' _n
file write template `"padding: 2px;/* set a border around the rectangle */"' _n
file write template `"font: 12px sans-serif;/* set the font type for the tooltips */"' _n
file write template `"background: lightsteelblue;/* set the colour of the rectangle */"' _n
file write template `"border: 0px;/* turn off the border (0px) */"' _n
file write template `"border-radius: 8px;/* set how rounded the edges of the rectangle is */"' _n
file write template `"pointer-events: none;/* 'none' tells the mouse to ignore the rectangle */"' _n
file write template `"}"' _n
file write template `"</style>"' _n
file write template `"</head>"' _n
file write template `"<body bgcolor="fafcf9">"' _n
file write template `"<table border="0">"' _n
file write template `"<tr>"' _n
file write template `"<td colspan="6">"' _n
file write template `"<div id="container"></div>"' _n
file write template `"</td>"' _n
file write template `"</tr>"' _n
file write template `"<tr class="title">"' _n
file write template `"<td>Network: XY<br>Size of the nodes</td>"' _n
file write template `"</tr>"' _n
file write template `"<tr>"' _n
file write template `"<td>Variable</td>"' _n
file write template `"<td><select id="size" onchange="change_size()"></select></td>"' _n
file write template `"<td>Size from</td>"' _n
file write template `"<td><input type="range" id="size_to" min="1" max="20" value="5" step="1" onchange = "change_size()"></td>"' _n
file write template `"<td>Size to</td>"' _n
file write template `"<td><input type="range" id="size_from" min="1" max="20" value="9" step="1" onchange = "change_size()"></td>"' _n
file write template `"</tr>"' _n
file write template `"<tr class="title">"' _n
file write template `"<td>Color of the nodes</td>"' _n
file write template `"</tr>"' _n
file write template `"<tr>"' _n
file write template `"<td>Variable</td>"' _n
file write template `"<td><select id="color" onchange="change_color()"></select></td>"' _n
file write template `"<td>Color to</td>"' _n
file write template `"<td><select id="color_to" onchange="change_color()" ></select></td>"' _n
file write template `"<td>Color from</td>"' _n
file write template `"<td><select id="color_from" onchange="change_color()" ></select></td>"' _n
file write template `"</tr>"' _n
file write template `"<tr class="title">"' _n
file write template `"<td>Label</td>"' _n
file write template `"</tr>"' _n
file write template `"<tr>"' _n
file write template `"<td>Variable</td>"' _n
file write template `"<td><select id="label" onchange="change_label()"></select></td>"' _n
file write template `"<td>Size</td>"' _n
file write template `"<td><input type="range" id="label_size" min="5" max="30" value="10" step="1" onchange = "change_label()"></td>"' _n
file write template `"<td></td>"' _n
file write template `"<td></td>"' _n
file write template `"</tr>"' _n
file write template `"<tr class="title">"' _n
file write template `"<td>Color of the links</td>"' _n
file write template `"<tr>"' _n
file write template `"<td>Link not reciprocal</td>"' _n
file write template `"<td><select id="both" onchange="setReciprocity()"></select></td>"' _n
file write template `"<td>Link reciprocal</td>"' _n
file write template `"<td><select id="single" onchange="setReciprocity()" ></select></td>"' _n
file write template `"</tr>"' _n
file write template `"<tr class="title">"' _n
file write template `"<td>Additional information</td>"' _n
file write template `"</tr>"' _n
file write template `"<tr>"' _n
file write template `"<td>Nodes =</td><td></td><td>Edges =</td><td></td>"' _n
file write template `"</tr>"' _n
file write template `"</table>"' _n
file write template `"</div>"' _n
file write template `"<script src="http://d3js.org/d3.v3.min.js">"' _n
file write template `"</head>"' _n
file write template `"</script> "' _n
file write template `"<script>"' _n
file write template `"console.log(d3); // --> Methoden von Object d3 anschauen"' _n
file write template `"var width = 850,"' _n
file write template `"height = 520;"' _n
file write template `"var fill = d3.scale.category20();"' _n
file write template `"var force = d3.layout.force()"' _n
file write template `".size([width, height])"' _n
file write template `".charge(-120)"' _n
file write template `".linkDistance(40)"' _n
file write template `".on("tick", tick);"' _n
file write template `"var drag = force.drag()"' _n
file write template `".on("dragstart", dragstart);"' _n
file write template `"var svg = d3.select("#container")// svg Object erstellt"' _n
file write template `".append("svg")"' _n
file write template `".attr("width", width)"' _n
file write template `".attr("height", height);"' _n
file write template `"d3.json("data.json", function(error, json) {"' _n
file write template `"nodes = json.nodes"' _n
file write template `"links = json.links"' _n
file write template `" force.nodes(json.nodes)"' _n
file write template `".links(json.links)"' _n
file write template `".on("tick",tick)"' _n
file write template `".charge(-400)"' _n
file write template `".gravity(0.1)"' _n
file write template `".linkDistance(75)"' _n
file write template `".start();"' _n
file write template `"link = svg.selectAll(".link")"' _n
file write template `".data(json.links) // Daten hinzufügen"' _n
file write template `".enter()"' _n
file write template `".append("line")"' _n
file write template `".attr("class", "link")"' _n
file write template `".style("stroke-width",1)"' _n
file write template `".style("stroke", setReciprocity());"' _n
file write template `"node = svg.selectAll(".node")"' _n
file write template `".data(json.nodes)"' _n
file write template `".enter()"' _n
file write template `".append("circle")"' _n
file write template `".attr("class", "node")"' _n
file write template `".attr("cx", function(d) { return d.x; })"' _n
file write template `".attr("cy", function(d) { return d.y; })"' _n
file write template `".attr("r",5)"' _n
file write template `".style("stroke","white")"' _n
file write template `".style("fill", change_color())"' _n
file write template `".call(force.drag)"' _n
file write template `"text = svg.selectAll("text")"' _n
file write template `".data(json.nodes)"' _n
file write template `".enter()"' _n
file write template `".append("text")"' _n
file write template `".attr("class", "text")"' _n
file write template `".style("fill", 1)"' _n
file write template `".attr("font-size", 5)"' _n
file write template `".text(function(d) { return "" })"' _n
file write template `".call(force.drag);"' _n
file write template `"});"' _n
file write template `"function tick() {"' _n
file write template `" link.attr("x1", function(d) { return d.source.x; })"' _n
file write template `".attr("y1", function(d) { return d.source.y; })"' _n
file write template `".attr("x2", function(d) { return d.target.x; })"' _n
file write template `".attr("y2",function(d) { return d.target.y; });"' _n
file write template `"node.attr("cx", function(d) { return d.x; })"' _n
file write template `".attr("cy", function(d) { return d.y; });"' _n
file write template `"text.attr("x", function(d) { return d.x + 10; })"' _n
file write template `".attr("y", function(d) { return d.y + 10; });"' _n
file write template `"}"' _n
file write template `"function dragstart(d) {"' _n
file write template `"d.fixed = true;"' _n
file write template `"d3.select(this).classed("fixed", true);"' _n
file write template `"}"' _n
file write template `"</script>"' _n
file write template `"<script src="http://code.jquery.com/jquery-latest.min.js"></script>"' _n
file write template `"<script>"' _n
file write template `"var variables = ["VARIABLES"]"' _n
file write template `"var colors = ["aqua", "black", "blue", "fuchsia", "gray", "green", "lime", "maroon", "navy", "olive", "orange", "purple", "red", "silver", "teal", "white", "yellow"]"' _n
file write template `"$.each(variables, function(key, value) { $('#size')"' _n
file write template `".append($('<option>', { value : value })"' _n
file write template `".text(value)); });"' _n
file write template `"$.each(variables, function(key, value) { $('#color')"' _n
file write template `".append($('<option>', { value : value })"' _n
file write template `".text(value)); });"' _n
file write template `"$.each(colors, function(key, value) { $('#color_to')"' _n
file write template `".append($('<option>', { value : value })"' _n
file write template `".text(value)); });"' _n
file write template `"$.each(colors, function(key, value) { $('#color_from')"' _n
file write template `".append($('<option>', { value : value })"' _n
file write template `".text(value)); });"' _n
file write template `"$.each(colors, function(key, value) { $('#both')"' _n
file write template `".append($('<option>', { value : value })"' _n
file write template `".text(value)); });"' _n
file write template `"$.each(colors, function(key, value) { $('#single')"' _n
file write template `".append($('<option>', { value : value })"' _n
file write template `".text(value)); });"' _n
file write template `"variables = ["nothing", "name"].concat(variables) // 2 Attribute hinzufügen"' _n
file write template `"$.each(variables, function(key, value) { $('#label')"' _n
file write template `".append($('<option>', { value : value })"' _n
file write template `".text(value)); });"' _n
file write template `"function setReciprocity()"' _n
file write template `"{"' _n
file write template `"min_size_domain = d3.min(links, function(d) { return d['reciprocal']; }),"' _n
file write template `"max_size_domain = d3.max(links, function(d) { return d['reciprocal']; }),"' _n
file write template `"min_size_range = $("#both").val(),"' _n
file write template `"max_size_range = $("#single").val();"' _n
file write template `"var color = d3.scale.linear()"' _n
file write template `".domain([min_size_domain, max_size_domain])"' _n
file write template `".range([min_size_range, max_size_range]);"' _n
file write template `"d3.selectAll(".link")"' _n
file write template `".transition()"' _n
file write template `".style("stroke", function(d)"' _n
file write template `"{"' _n
file write template `"return color(d['reciprocal']);"' _n
file write template `"})"' _n
file write template `"}"' _n
file write template `"// http://stackoverflow.com/a/478445/829971"' _n
file write template `"function roundNumber(number, digits)"' _n
file write template `"{"' _n
file write template `"var multiple = Math.pow(10, digits);"' _n
file write template `"var rndedNum = Math.round(number * multiple) / multiple;"' _n
file write template `"return rndedNum;"' _n
file write template `"}"' _n
file write template `"function change_size()"' _n
file write template `"{"' _n
file write template `"var variable = $("#size").val(),  // Wert"' _n
file write template `"min_size_domain = d3.min(nodes, function(d) { return d[variable]; }),"' _n
file write template `"max_size_domain = d3.max(nodes, function(d) { return d[variable]; }),"' _n
file write template `"min_size_range = $("#size_to").val(),"' _n
file write template `"max_size_range = $("#size_from").val();"' _n
file write template `"var scale = d3.scale.linear()"' _n
file write template `".domain([min_size_domain, max_size_domain]) // Wertebereich"' _n
file write template `".range([min_size_range, max_size_range])// reale Spannweite"' _n
file write template `"d3.selectAll(".node").transition().attr("r", function(d)"' _n
file write template `"{"' _n
file write template `"return scale(d[variable]);"' _n
file write template `"})"' _n
file write template `"}"' _n
file write template `"function change_color()"' _n
file write template `"{"' _n
file write template `"var variable = $("#color").val();"' _n
file write template `"min_size_domain = d3.min(nodes, function(d) { return d[variable]; }),"' _n
file write template `"max_size_domain = d3.max(nodes, function(d) { return d[variable]; }),"' _n
file write template `"min_size_range = $("#color_to").val(),"' _n
file write template `"max_size_range = $("#color_from").val()"' _n
file write template `"var color = d3.scale.linear()"' _n
file write template `".domain([min_size_domain, max_size_domain])"' _n
file write template `".range([min_size_range, max_size_range])"' _n
file write template `"d3.selectAll(".node").transition()"' _n
file write template `".style("fill", function(d)"' _n
file write template `"{"' _n
file write template `"return color(d[variable]);"' _n
file write template `"})"' _n
file write template `"}"' _n
file write template `"function change_label()"' _n
file write template `"{"' _n
file write template `"var variable = $("#label").val(),"' _n
file write template `"size = $("#label_size").val(),"' _n
file write template `"round = parseInt($("#label_round").val());"' _n
file write template `"d3.selectAll(".text")"' _n
file write template `".transition()"' _n
file write template `".attr("font-size", size)"' _n
file write template `".text( function(d)"' _n
file write template `"{"' _n
file write template `"label = roundNumber(d[variable], round);"' _n
file write template `"if(isNaN(label))"' _n
file write template `"{"' _n
file write template `"label = d[variable];"' _n
file write template `"}"' _n
file write template `"return label;"' _n
file write template `"}"' _n
file write template `");"' _n
file write template `"}"' _n
file write template `"document.getElementById('color_to').options.selectedIndex=14;"' _n
file write template `"document.getElementById('color_from').options.selectedIndex=10;"' _n
file write template `"document.getElementById('size').options.selectedIndex=1;"' _n
file write template `"document.getElementById('both').options.selectedIndex=13;"' _n
file write template `"document.getElementById('single').options.selectedIndex=1;"' _n
file write template `"</script>"' _n
file write template `"</body>"' _n
file write template `"</html>"' _n
file close template					
			
}		
			
			

			
* (2.2) Directed: template.html to generate the various individual network html files from
* ----------------------------------------------------------------------------------------

if "`arrows'" == "arrows" {

file open template using "template.html", write replace
file write template `"<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN""' _n
file write template `""http://www.w3.org/TR/html4/loose.dtd">"' _n
file write template `"<html>"' _n
file write template `"<head>"' _n
file write template `"<title> Students networks</title>"' _n
file write template `"<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">"' _n
file write template `"<meta charset="utf-8">"' _n
file write template `"<style>"' _n
file write template `".link {"' _n
file write template `"stroke: #000;"' _n
file write template `"stroke-width: 1.5px;"' _n
file write template `"}"' _n
file write template `".node {"' _n
file write template `"cursor: move;"' _n
file write template `"fill: #ccc;"' _n
file write template `"stroke: #000;"' _n
file write template `"stroke-width: 1.5px;"' _n
file write template `"}"' _n
file write template `".node.fixed {"' _n
file write template `"fill: #f00;"' _n
file write template `"}"' _n
file write template `"div {float: left;}"' _n
file write template `".title {font-weight: bold;"' _n
file write template `"color: #1b87a2;}"' _n
file write template `"div.tooltip {/* set the CSS for tooltip divs */"' _n
file write template `"position: absolute;/* reference for measurement */"' _n
file write template `"text-align: center;/* align the text to the center */"' _n
file write template `"width: 60px;/* set the width of the rectangle */"' _n
file write template `"height: 28px;/* set the height of the rectangle */"' _n
file write template `"padding: 2px;/* set a border around the rectangle */"' _n
file write template `"font: 12px sans-serif;/* set the font type for the tooltips */"' _n
file write template `"background: lightsteelblue;/* set the colour of the rectangle */"' _n
file write template `"border: 0px;/* turn off the border (0px) */"' _n
file write template `"border-radius: 8px;/* set how rounded the edges of the rectangle is */"' _n
file write template `"pointer-events: none;/* 'none' tells the mouse to ignore the rectangle */"' _n
file write template `"}"' _n
file write template `"</style>"' _n
file write template `"</head>"' _n
file write template `"<body bgcolor="fafcf9">"' _n
file write template `"<table border="0">"' _n
file write template `"<tr>"' _n
file write template `"<td colspan="6">"' _n
file write template `"<div id="container"></div>"' _n
file write template `"</td>"' _n
file write template `"</tr>"' _n
file write template `"<tr class="title">"' _n
file write template `"<td>Network: XY<br>Size of the nodes</td>"' _n
file write template `"</tr>"' _n
file write template `"<tr>"' _n
file write template `"<td>Variable</td>"' _n
file write template `"<td><select id="size" onchange="change_size()"></select></td>"' _n
file write template `"<td>Size from</td>"' _n
file write template `"<td><input type="range" id="size_to" min="1" max="20" value="5" step="1" onchange = "change_size()"></td>"' _n
file write template `"<td>Size to</td>"' _n
file write template `"<td><input type="range" id="size_from" min="1" max="20" value="9" step="1" onchange = "change_size()"></td>"' _n
file write template `"</tr>"' _n
file write template `"<tr class="title">"' _n
file write template `"<td>Color of the nodes</td>"' _n
file write template `"</tr>"' _n
file write template `"<tr>"' _n
file write template `"<td>Variable</td>"' _n
file write template `"<td><select id="color" onchange="change_color()"></select></td>"' _n
file write template `"<td>Color to</td>"' _n
file write template `"<td><select id="color_to" onchange="change_color()" ></select></td>"' _n
file write template `"<td>Color from</td>"' _n
file write template `"<td><select id="color_from" onchange="change_color()" ></select></td>"' _n
file write template `"</tr>"' _n
file write template `"<tr class="title">"' _n
file write template `"<td>Label</td>"' _n
file write template `"</tr>"' _n
file write template `"<tr>"' _n
file write template `"<td>Variable</td>"' _n
file write template `"<td><select id="label" onchange="change_label()"></select></td>"' _n
file write template `"<td>Size</td>"' _n
file write template `"<td><input type="range" id="label_size" min="5" max="30" value="10" step="1" onchange = "change_label()"></td>"' _n
file write template `"<td></td>"' _n
file write template `"<td></td>"' _n
file write template `"</tr>"' _n
file write template `"<tr class="title">"' _n
file write template `"<td>Color of the links</td>"' _n
file write template `"<tr>"' _n
file write template `"<td>Link not reciprocal</td>"' _n
file write template `"<td><select id="single" onchange="setReciprocity()"></select></td>"' _n
file write template `"<td>Link reciprocal</td>"' _n
file write template `"<td><select id="both" onchange="setReciprocity()" ></select></td>"' _n
file write template `"</tr>"' _n
file write template `"<tr class="title">"' _n
file write template `""' _n
file write template `"<td>Additional information</td>"' _n
file write template `""' _n
file write template `"</tr>"' _n
file write template `""' _n
file write template `"<tr>"' _n
file write template `"<td>Nodes =</td><td></td><td>Edges =</td><td></td>"' _n
file write template `"</tr>"' _n
file write template `"</table>"' _n
file write template `"</div>"' _n
file write template `"<script src="http://d3js.org/d3.v3.min.js">"' _n
file write template `"</head>"' _n
file write template `"</script>"' _n
file write template `"<script>"' _n
file write template `"console.log(d3); // --> Methoden von Object d3 anschauen"' _n
file write template `"var width = 850,"' _n
file write template `"height = 520;"' _n
file write template `"var fill = d3.scale.category20();"' _n
file write template `"var force = d3.layout.force()"' _n
file write template `".size([width, height])"' _n
file write template `".charge(-120)"' _n
file write template `".linkDistance(40)"' _n
file write template `".on("tick", tick);"' _n
file write template `"var drag = force.drag()"' _n
file write template `".on("dragstart", dragstart);"' _n
file write template `"var svg = d3.select("#container")// svg Object erstellt"' _n
file write template `".append("svg")"' _n
file write template `".attr("width", width)"' _n
file write template `".attr("height", height);"' _n
file write template `"/*Build the directional arrows for the links/edges */"' _n
file write template `"svg.append("svg:defs")"' _n
file write template `".selectAll("marker")"' _n
file write template `".data(["end"])"' _n
file write template `".enter().append("svg:marker")"' _n
file write template `".attr("id", String)"' _n
file write template `".attr("viewBox", "0 -5 8 8")"' _n
file write template `".attr("refX", 16)"' _n
file write template `".attr("refY", -1.5)"' _n
file write template `".attr("markerWidth", 8)"' _n
file write template `".attr("markerHeight", 8)"' _n
file write template `".attr("orient", "auto")"' _n
file write template `".append("svg:path")"' _n
file write template `".attr("d", "M0,-5L10,0L0,5");"' _n
file write template `"d3.json("data.json", function(error, json) {"' _n
file write template `"nodes = json.nodes"' _n
file write template `"links = json.links"' _n
file write template `"force.nodes(json.nodes)"' _n
file write template `".links(json.links)"' _n
file write template `".on("tick",tick)"' _n
file write template `".charge(-400)"' _n
file write template `".gravity(0.1)"' _n
file write template `".linkDistance(75)"' _n
file write template `".start();"' _n
file write template `"link = svg.selectAll(".link")"' _n
file write template `".data(json.links) // Daten hinzufügen"' _n
file write template `".enter()"' _n
file write template `".append("line")"' _n
file write template `".attr("class", "link")"' _n
file write template `".style("stroke-width",1)"' _n
file write template `".style("stroke", setReciprocity())"' _n
file write template `".attr("marker-end", "url(#end)");"' _n
file write template `"node = svg.selectAll(".node")"' _n
file write template `".data(json.nodes)"' _n
file write template `".enter()"' _n
file write template `".append("circle")"' _n
file write template `".attr("class", "node")"' _n
file write template `".attr("cx", function(d) { return d.x; })"' _n
file write template `".attr("cy", function(d) { return d.y; })"' _n
file write template `".attr("r",5)"' _n
file write template `".style("stroke","white")"' _n
file write template `".style("fill", change_color())"' _n
file write template `".call(force.drag)"' _n
file write template `"text = svg.selectAll("text")"' _n
file write template `".data(json.nodes)"' _n
file write template `".enter()"' _n
file write template `".append("text")"' _n
file write template `".attr("class", "text")"' _n
file write template `".style("fill", 1)"' _n
file write template `".attr("font-size", 5)"' _n
file write template `".text(function(d) { return "" })"' _n
file write template `".call(force.drag);"' _n
file write template `"});"' _n
file write template `"function tick() {"' _n
file write template `"link.attr("x1", function(d) { return d.source.x; })"' _n
file write template `".attr("y1", function(d) { return d.source.y; })"' _n
file write template `".attr("x2", function(d) { return d.target.x; })"' _n
file write template `".attr("y2", function(d) { return d.target.y; });"' _n
file write template `"node.attr("cx", function(d) { return d.x; })"' _n
file write template `".attr("cy", function(d) { return d.y; });"' _n
file write template `"text.attr("x", function(d) { return d.x + 10; })"' _n
file write template `".attr("y", function(d) { return d.y + 10; });"' _n
file write template `"}"' _n
file write template `"function dragstart(d) {"' _n
file write template `"d.fixed = true;"' _n
file write template `"d3.select(this).classed("fixed", true);"' _n
file write template `"}"' _n
file write template `"</script>"' _n
file write template `"<script src="http://code.jquery.com/jquery-latest.min.js"></script>"' _n
file write template `"<script>"' _n
file write template `"// Dropboxen erstellen"' _n
file write template `"var variables = ["VARIABLES"]"' _n
file write template `"var colors = ["aqua", "black", "blue", "fuchsia", "gray", "green", "lime", "maroon", "navy", "olive", "orange", "purple", "red", "silver", "teal", "white", "yellow"]"' _n
file write template `"$.each(variables, function(key, value) { $('#size')"' _n
file write template `".append($('<option>', { value : value })"' _n
file write template `".text(value)); });"' _n
file write template `"$.each(variables, function(key, value) { $('#color')"' _n
file write template `".append($('<option>', { value : value })"' _n
file write template `".text(value)); });"' _n
file write template `"$.each(colors, function(key, value) { $('#color_to')"' _n
file write template `".append($('<option>', { value : value })"' _n
file write template `".text(value)); });"' _n
file write template `"$.each(colors, function(key, value) { $('#color_from')"' _n
file write template `".append($('<option>', { value : value })"' _n
file write template `".text(value)); });"' _n
file write template `"$.each(colors, function(key, value) { $('#both')"' _n
file write template `".append($('<option>', { value : value })"' _n
file write template `".text(value)); });"' _n
file write template `"$.each(colors, function(key, value) { $('#single')"' _n
file write template `".append($('<option>', { value : value })"' _n
file write template `".text(value)); });"' _n
file write template `"variables = ["nothing", "name"].concat(variables) // 2 Attribute hinzufügen"' _n
file write template `"$.each(variables, function(key, value) { $('#label')"' _n
file write template `".append($('<option>', { value : value })"' _n
file write template `".text(value)); });"' _n
file write template `"function setReciprocity()"' _n
file write template `"{"' _n
file write template `"min_size_domain = d3.min(links, function(d) { return d['reciprocal']; }),"' _n
file write template `"max_size_domain = d3.max(links, function(d) { return d['reciprocal']; }),"' _n
file write template `"min_size_range = $("#single").val(),"' _n
file write template `"max_size_range = $("#both").val();"' _n
file write template `"var color = d3.scale.linear()"' _n
file write template `".domain([min_size_domain, max_size_domain])"' _n
file write template `".range([min_size_range, max_size_range]);"' _n
file write template `"d3.selectAll(".link")"' _n
file write template `".transition()"' _n
file write template `".style("stroke", function(d)"' _n
file write template `"{"' _n
file write template `"return color(d['reciprocal']);"' _n
file write template `"})"' _n
file write template `"}"' _n
file write template `"// http://stackoverflow.com/a/478445/829971"' _n
file write template `"function roundNumber(number, digits)"' _n
file write template `"{"' _n
file write template `"var multiple = Math.pow(10, digits);"' _n
file write template `"var rndedNum = Math.round(number * multiple) / multiple;"' _n
file write template `"return rndedNum;"' _n
file write template `"}"' _n
file write template `"function change_size()"' _n
file write template `"{"' _n
file write template `"var variable = $("#size").val(),// Wert"' _n
file write template `"min_size_domain = d3.min(nodes, function(d) { return d[variable]; }),"' _n
file write template `"max_size_domain = d3.max(nodes, function(d) { return d[variable]; }),"' _n
file write template `"min_size_range = $("#size_to").val(),"' _n
file write template `"max_size_range = $("#size_from").val();"' _n
file write template `"var scale = d3.scale.linear()"' _n
file write template `".domain([min_size_domain, max_size_domain]) // Wertebereich"' _n
file write template `".range([min_size_range, max_size_range])// reale Spannweite"' _n
file write template `"d3.selectAll(".node").transition().attr("r", function(d)"' _n
file write template `"{"' _n
file write template `"return scale(d[variable]);"' _n
file write template `"})"' _n
file write template `"}"' _n
file write template `"function change_color()"' _n
file write template `"{"' _n
file write template `"var variable = $("#color").val();"' _n
file write template `"min_size_domain = d3.min(nodes, function(d) { return d[variable]; }),"' _n
file write template `"max_size_domain = d3.max(nodes, function(d) { return d[variable]; }),"' _n
file write template `"min_size_range = $("#color_to").val(),"' _n
file write template `"max_size_range = $("#color_from").val()"' _n
file write template `"var color = d3.scale.linear()"' _n
file write template `".domain([min_size_domain, max_size_domain])"' _n
file write template `".range([min_size_range, max_size_range])"' _n
file write template `"d3.selectAll(".node").transition()"' _n
file write template `".style("fill", function(d)"' _n
file write template `"{"' _n
file write template `"return color(d[variable]);"' _n
file write template `"})"' _n
file write template `"}"' _n
file write template `"function change_label()"' _n
file write template `"{"' _n
file write template `"var variable = $("#label").val(),"' _n
file write template `"size = $("#label_size").val(),"' _n
file write template `"round = parseInt($("#label_round").val());"' _n
file write template `"d3.selectAll(".text")"' _n
file write template `".transition()"' _n
file write template `".attr("font-size", size)"' _n
file write template `".text( function(d)"' _n
file write template `"{"' _n
file write template `"label = roundNumber(d[variable], round);"' _n
file write template `"if(isNaN(label))"' _n
file write template `"{"' _n
file write template `"label = d[variable];"' _n
file write template `"}"' _n
file write template `"return label;"' _n
file write template `"}"' _n
file write template `");"' _n
file write template `"}"' _n
file write template `"document.getElementById('color_to').options.selectedIndex=14;"' _n
file write template `"document.getElementById('color_from').options.selectedIndex=10;"' _n
file write template `"document.getElementById('size').options.selectedIndex=1;"' _n
file write template `"document.getElementById('both').options.selectedIndex=1;"' _n
file write template `"document.getElementById('single').options.selectedIndex=13;"' _n
file write template `"</script>"' _n
file write template `"</body>"' _n
file write template `"</html>"' _n

file close template

}		
			
			
			
* --------------------------------------------------------------------------------------------------







* Get Stata data to json data (distinct for each network)
* -------------------------------------------------------

	* Keep only the pertaining network and nodecovariates and rename them
	keep `distinction' `id' `network' `nodecov'
	
	* Nodecov
	if "`nodecov_newnames'" != "" {
		forv i = 1/`: word count `nodecov_newnames'' {
			ren `: word `i' of `nodecov'' `: word `i' of `nodecov_newnames''
		}
	}
	else loc nodecov_newnames "`nodecov'"
	loc nodecovariates_sum: word count `nodecov_newnames'


	* Networkvar
	unab nwvarlist: `network'
	loc i = 1
	foreach nwvar of loc nwvarlist {
		ren `nwvar' nwvar`i'
		loc ++i
	}
	
	

	* Generate unique grade ids to loop over and to distinguish datasets
	preserve
		keep `distinction'
		duplicates drop `distinction', force
		sort `distinction'

			* Save matrix containing the distinction criteria to display them later in menu.html
			* for better navigatability
			mkmat `distinction', mat(distinction_names)
		
		gen distinction_id = _n
		tempfile distinction_unique
		save `distinction_unique', replace
	restore
	merge n:1 `distinction' using `distinction_unique', nogen keep(3)
	su distinction_id, meanonly
	loc distinction_sum = r(max)
	
	compress
	tempfile fulldata
	save `fulldata', replace


	

n: di as txt "Processing " as res `distinction_sum' as txt " networks."
forv singlenw = 1/`distinction_sum' {


	
	* Begin by selecting only the pertaining grade from the selected dataset
	use `fulldata', clear        // select only the pertaining grade
	keep if distinction_id == `singlenw'
	
		* Temporary: Get information about networks
		qui d,s
		glo sum_nodes = r(N)

	
	* Generate unique ids that d3.js can work with
	sort `: word 1 of `nodecov_newnames'' `id'
	gen id_d3js = _n-1  // achtung: richtig?
	
	gen name = `id'

	* Save two versions of this dataset, one for nodes part and one for dyadic part
	preserve
		drop nwvar*
		save "jsondata/fulldata_d3jsids_wonetwork", replace
	restore
	
	preserve
		loc i = 1
		foreach nodecov of loc nodecov_newnames {
			if `i' != 1 drop `nodecov'
			loc ++i
		}
		save "jsondata/fulldata_d3jsids_wocov", replace
	restore

	clear

	
	
	
		
	* -------------------------------------------------------------------------------------
	* Start first procedure: First nodes and their covariates and then the edgelist to json
	* -------------------------------------------------------------------------------------
	


	/*
	Steps:
	-----
	Step 1:   Generate list of nodes with characteristics as a json data document
	Step 2:   Generate list of links with characteristics as a json data document 
	          and append it to the node list
	Step 2.1: Change the ids according to the ids needed by d3js
	Step 2.2: Change the data structure (or format) to the one needed by d3js
	          d3js needs a list of links in long-format, not in wide-format
	*/




	* Step 1: List of nodes w/ characteristics
	* (Important: the d3js wants to have a 
	*  succeeding list of nodes, i.e. 0,1,2,3,...,40 not 101,102,...,220)
	* ----------------------------------------------------------------- +

	use "jsondata/fulldata_d3jsids_wonetwork", clear



	file open nodes using "jsondata/network`singlenw'.json", write replace

	* Header of nodes section
	file write nodes "{" _n
	file write nodes `" "nodes" : ["' _n

	* Retrieve and insert all artists' names
	qui d,s
	loc sum_elements = r(N)-1
	forv x = 0/`sum_elements' {
	
		* Extract person specific characteristics in terms of the variables
		foreach variable in name `nodecov_newnames' {
			su `variable' if id_d3js == `x', meanonly
			loc char_`variable' = r(mean)
		}


			
		* Write each person and their respective characteristics in json format to the json data document (ascii text file)
		if `x' != `sum_elements' {
		
			file write nodes "  {"
			loc i = 1
			foreach charname in name `nodecov_newnames' {
				if `i' <  `: word count name `nodecov_newnames''  file write nodes `""`charname'":`char_`charname'', "'
				if `i' == `: word count name `nodecov_newnames''  file write nodes `""`charname'":`char_`charname''"'
				loc ++i
			}
			file write nodes "}," _n
		}
		else {   // last entry of all nodes does not end with a comma
			file write nodes "  {"
			loc i = 1
			foreach charname in name `nodecov_newnames' {
				if `i' <  `: word count name `nodecov_newnames''  file write nodes `""`charname'":`char_`charname'', "'
				if `i' == `: word count name `nodecov_newnames''  file write nodes `""`charname'":`char_`charname''"'
				loc ++i
			}
			file write nodes "}" _n
		}
		
	}
	

	* End of nodes section
	file write nodes "]" _n
	file write nodes "," _n
	
	file close nodes   // the file does not contain the ids. This is not necessary as d3js generates them automatically.
                   // However, d3js starts counting ids at 0, not 1. So the first student (id_p = 1 & id_c =1 is the student 0 in d3js)




   
				   


	* Step 2: Generate list of links
	* ------------------------------ +

	use "jsondata/fulldata_d3jsids_wocov.dta", clear



	* Step 2.1
	* --------

	* Generate new id for d3js
	order id_d3js, first
	sort  id_d3js

	* Generate temporary concordance list of internal ids (id_internal) and d3js compatible ids (id_d3js)

	preserve // temporary change in dataset
		tempfile concordance_list // generate temporary dataset that exists as long as do-file is running
		keep id_d3js `id'
		save `concordance_list', replace
	restore

	ren id_d3js  id_d3js_sender
	drop `id'
	
	* Replace the internal id numbers with d3js compatible id numbers (1,...,40)
	foreach x of varlist nwvar* {

		ren `x' `id'
		qui merge n:1 `id' using `concordance_list', nogen keep(1 3)
		drop `id'
		ren id_d3js `x'
		sort id_d3js_sender

	}



	* Step 2.2
	* --------


	reshape long nwvar@, i(id_d3js_sender) j(newvar)
	drop newvar
	drop if mi(nwvar) // If the connection is missing, remove it, because there has not been any nomination
	ren nwvar id_d3js_receiver
	sort id_d3js_sender id_d3js_receiver
	drop if id_d3js_sender == id_d3js_receiver  // delete self-nominations (just to be sure)
	duplicates drop id_d3js_sender id_d3js_receiver, force  // duplicates might be due to wrong verification

	* Generate a characteristic of the links: reciprocity (both people nominated each other)
	preserve
		ren id_d3js_sender id_d3js_receiver1
		ren id_d3js_receiver id_d3js_sender
		ren id_d3js_receiver1 id_d3js_receiver
		sort id_d3js_sender id_d3js_receiver
		tempfile links_reciprocity
		save `links_reciprocity', replace
	restore

	merge 1:1 id_d3js_sender id_d3js_receiver using `links_reciprocity', keep(1 3)

	gen reciprocal = _merge == 3
	drop _merge
	sort id_d3js_sender id_d3js_receiver

		* Temporary: Gen count of Edges
		qui d,s
		glo sum_edges = r(N)


		
		file open links using "jsondata/network`singlenw'.json", write append

		* Header of links section
		file write links `" "links" : ["' _n

		* Retrieve and insert all artists' names
		qui d,s
		loc sum_links = r(N)
		forv x = 1/`sum_links' {
		
			qui su id_d3js_sender if _n == `x'
			loc source = r(mean)
			qui su id_d3js_receiver if _n == `x'
			loc target = r(mean)
			qui su reciprocal if _n == `x'
			loc char_reciprocal = r(mean)

			
			if `x' != `sum_links' {
				file write links `" {"source":`source', "target":`target', "reciprocal":`char_reciprocal'},"' _n
			}
			else {
				file write links `" {"source":`source', "target":`target', "reciprocal":`char_reciprocal'}"' _n
		}
			
		}
		

		* End of links section
		file write links "]" _n
		file write links "}" _n
		
	file close links



	
		* Get rid of old tempfiles
		erase "jsondata/fulldata_d3jsids_wonetwork.dta"
		erase "jsondata/fulldata_d3jsids_wocov.dta"
		
		

		
	* ----------------------------------------------------------------------------	
	* Start second procedure: Generate different html files for each grade network
	* ----------------------------------------------------------------------------
	
	file open template using "template.html", read  // template document that is duplicated
	file read template line

		file open duplikat using "jsondata/network`singlenw'.html", write replace  // duplicate in which only the dataset is changed


	while r(eof)==0 {
		
		if `"`line'"' == `"d3.json("data.json", function(error, json) {"' {  
			file write duplikat `"d3.json("network`singlenw'.json", function(error, json) {"' _n // make new data assignment
		}
		else if `"`line'"' == "<td>Nodes =</td><td></td><td>Edges =</td><td></td>" {  // write some additional information
			file write duplikat "<td>Nodes =</td><td>${sum_nodes}</td><td>Edges =</td><td>${sum_edges}</td>"
		}
		else if `"`line'"' == `"var variables = ["VARIABLES"]"' {  // write selected covariates
			loc i = 1
			file write duplikat "var variables = ["
			foreach newvar of loc nodecov_newnames {
				if `i' < `nodecovariates_sum' {
					file write duplikat `""`newvar'", "'
				}
				else {
					file write duplikat `""`newvar'""'
				}
				loc ++i
			}
			file write duplikat "]" _n
		}
		else if `"`line'"' == "<td>Network: XY<br>Size of the nodes</td>" {
			file write duplikat `"<td>Network: `singlenw'<br>Size of the nodes</td>"' _n
		}
		else {
			file write duplikat `"`line'"' _n
		}
	file read template line
	}

	
	file close duplikat
	file close template


}

erase "template.html"





* ----------------------------------------------------------------------------------------------------------
* Start third procedure: Write menu.html containing all networks so that one can browse through them quickly
* ----------------------------------------------------------------------------------------------------------

file open menu using "jsondata/menu.html", write replace
file write menu `"<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">"' _n
file write menu `"<html><head><title>Selection of the networks</title></head><body bgcolor="fafcf9">"' _n
file write menu `"<html><head><title>Selection of the networks</title></head><body bgcolor="fafcf9">"' _n
file write menu "<p><b>To change the current network please select:</b></p>" _n
forv singlenw = 1/`distinction_sum' {
	loc distinction_names_loc ""
	forv distnames = 1/`: word count `distinction'' {
		if `distnames' < `: word count `distinction'' {
			loc distinction_names_loc "`distinction_names_loc' `=distinction_names[`singlenw',`distnames']',"
		}
		else {
			loc distinction_names_loc "`distinction_names_loc' `=distinction_names[`singlenw',`distnames']'"
		}
	}
	loc distinction_names_loc = trim("`distinction_names_loc'")
	file write menu `"<a href="network`singlenw'.html" target="networks"><b>Network`singlenw' (`distinction_names_loc')</b></a><br>"' _n
}
file write menu "</body></html>"
file close menu


* Reload data set
use ``d3useddata'', clear
cd "`d3cpwd'"

* Provide neat way to directly view the networks
if "`d3path'" == "" {
	n: di as txt "(output written to {browse index.html})"
}
else {

	n: di as txt `"(output written to {browse "`d3path'/index.html"})"'
}

* Clean up macros and one matrix
macro drop sum_nodes sum_edges
matrix drop distinction_names

}

end
* End.




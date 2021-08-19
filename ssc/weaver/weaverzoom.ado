/*

	   Developed by E. F. Haghish (2014)
	  Center for Medical Biometry and Medical Informatics
University of Freiburg, Germany

  haghish@imbi.uni-freiburg.de
   
                    * These software come with no warranty *
	
	This program installs the EasingJS JavaScript to enlarge photos to 
	full screen mode when they are clicked in the HTML log
*/
	
	
program define weaverzoom
	version 11
	
	tempname canvas 
	capture file open `canvas' using "$htmldoc" , write text append

	
	********************************************************************
	* JavaScript "Easing" Code
	********************************************************************
	file write `canvas' _n(2) "<script>" _n /// 
			"jQuery.easing['jswing'] = jQuery.easing['swing'];" _n /// 
			"jQuery.extend( jQuery.easing," _n /// 
			"{" _n /// 
					_skip(4) "def: 'easeOutQuad'," _n /// 
					_skip(4) "swing: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	/// /* --- alert(jQuery.easing.default); --- */
					_skip(6) 	"return jQuery.easing[jQuery.easing.def](x, t, b, c, d);" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInQuad: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"return c*(t/=d)*t + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeOutQuad: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"return -c *(t/=d)*(t-2) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInOutQuad: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"if ((t/=d/2) < 1) return c/2*t*t + b;" _n /// 
					_skip(6) 	"return -c/2 * ((--t)*(t-2) - 1) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInCubic: function (x, t, b, c, d) {" _n /// 
					_skip(4) "return c*(t/=d)*t*t + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeOutCubic: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"return c*((t=t/d-1)*t*t + 1) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInOutCubic: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"if ((t/=d/2) < 1) return c/2*t*t*t + b;" _n /// 
					_skip(6) 	"return c/2*((t-=2)*t*t + 2) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInQuart: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"return c*(t/=d)*t*t*t + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeOutQuart: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"return -c * ((t=t/d-1)*t*t*t - 1) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInOutQuart: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"if ((t/=d/2) < 1) return c/2*t*t*t*t + b;" _n /// 
					_skip(6) 	"return -c/2 * ((t-=2)*t*t*t - 2) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInQuint: function (x, t, b, c, d) {" _n /// 
					_skip(6) "return c*(t/=d)*t*t*t*t + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeOutQuint: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"return c*((t=t/d-1)*t*t*t*t + 1) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInOutQuint: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"if ((t/=d/2) < 1) return c/2*t*t*t*t*t + b;" _n /// 
					_skip(6) 	"return c/2*((t-=2)*t*t*t*t + 2) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInSine: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"return -c * Math.cos(t/d * (Math.PI/2)) + c + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeOutSine: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"return c * Math.sin(t/d * (Math.PI/2)) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInOutSine: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"return -c/2 * (Math.cos(Math.PI*t/d) - 1) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInExpo: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"return (t==0) ? b : c * Math.pow(2, 10 * (t/d - 1)) + b" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeOutExpo: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"return (t==d) ? b+c : c * (-Math.pow(2, -10 * t/d) + 1) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInOutExpo: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"if (t==0) return b;" _n /// 
					_skip(6) 	"if (t==d) return b+c;" _n /// 
					_skip(6) 	"if ((t/=d/2) < 1) return c/2 * Math.pow(2, 10 * (t - 1)) + b;" _n /// 
					_skip(6) 	"return c/2 * (-Math.pow(2, -10 * --t) + 2) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInCirc: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"return -c * (Math.sqrt(1 - (t/=d)*t) - 1) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeOutCirc: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"return c * Math.sqrt(1 - (t=t/d-1)*t) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInOutCirc: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"if ((t/=d/2) < 1) return -c/2 * (Math.sqrt(1 - t*t) - 1) + b;" _n /// 
					_skip(6) 	"return c/2 * (Math.sqrt(1 - (t-=2)*t) + 1) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInElastic: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"var s=1.70158;var p=0;var a=c;" _n /// 
					_skip(6) 	"if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;" _n /// 
					_skip(4) 	"if (a < Math.abs(c)) { a=c; var s=p/4; }" _n /// 
					_skip(4) 	"else var s = p/(2*Math.PI) * Math.asin (c/a);" _n /// 
					_skip(4) 	"return -(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeOutElastic: function (x, t, b, c, d) {" _n /// 
					_skip(6) 	"var s=1.70158;var p=0;var a=c;" _n /// 
					_skip(6) 	"if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;" _n /// 
					_skip(6) 	"if (a < Math.abs(c)) { a=c; var s=p/4; }" _n /// 
					_skip(4) 	"else var s = p/(2*Math.PI) * Math.asin (c/a);" _n /// 
					_skip(6) 	"return a*Math.pow(2,-10*t) * Math.sin( (t*d-s)*(2*Math.PI)/p ) + c + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInOutElastic: function (x, t, b, c, d) {" _n /// 
					_skip(6)	"var s=1.70158;var p=0;var a=c;" _n /// 
					_skip(6)	"if (t==0) return b;  if ((t/=d/2)==2) return b+c;  if (!p) p=d*(.3*1.5);" _n /// 
					_skip(6)	"if (a < Math.abs(c)) { a=c; var s=p/4; }" _n /// 
					_skip(6)	"else var s = p/(2*Math.PI) * Math.asin (c/a);" _n /// 
					_skip(6)	"if (t < 1) return -.5*(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;" _n /// 
					_skip(6)	"return a*Math.pow(2,-10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )*.5 + c + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInBack: function (x, t, b, c, d, s) {" _n /// 
					_skip(6)	"if (s == undefined) s = 1.70158;" _n /// 
					_skip(6)	"return c*(t/=d)*t*((s+1)*t - s) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeOutBack: function (x, t, b, c, d, s) {" _n /// 
					_skip(6)	"if (s == undefined) s = 1.70158;" _n /// 
					_skip(6)	"return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInOutBack: function (x, t, b, c, d, s) {" _n /// 
					_skip(6)	"if (s == undefined) s = 1.70158; " _n /// 
					_skip(6)	"if ((t/=d/2) < 1) return c/2*(t*t*(((s*=(1.525))+1)*t - s)) + b;" _n /// 
					_skip(6)	"return c/2*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInBounce: function (x, t, b, c, d) {" _n /// 
					_skip(6)	"return c - jQuery.easing.easeOutBounce (x, d-t, 0, c, d) + b;" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeOutBounce: function (x, t, b, c, d) {" _n /// 
					_skip(6)	"if ((t/=d) < (1/2.75)) {" _n /// 
					_skip(6)		"return c*(7.5625*t*t) + b;" _n /// 
					_skip(6)	"} else if (t < (2/2.75)) {" _n /// 
					_skip(6)		"return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;" _n /// 
					_skip(6)	"} else if (t < (2.5/2.75)) {" _n /// 
					_skip(6)		"return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;" _n /// 
					_skip(6)	"} else {" _n /// 
					_skip(6)		"return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;" _n /// 
					_skip(6)	"}" _n /// 
					_skip(4) "}," _n /// 
					_skip(4) "easeInOutBounce: function (x, t, b, c, d) {" _n /// 
					_skip(6)	"if (t < d/2) return jQuery.easing.easeInBounce (x, t*2, 0, c, d) * .5 + b;" _n /// 
					_skip(6)	"return jQuery.easing.easeOutBounce (x, t*2-d, 0, c, d) * .5 + c*.5 + b;" _n /// 
					_skip(2) "}"_n /// 
			"});" _n /// 
			"</script>" _n(2)




			********************************************************************
			* THE SMOOTH ZOOM JAVASCRIPT
			*
			* Smoothzoom
			* http://kthornbloom.com/smoothzoom
			*
			* Copyright 2014, Kevin Thornbloom
			* Free to use and modify under the MIT license.
			* http://www.opensource.org/licenses/mit-license.php
			********************************************************************
			file write `canvas' "<script>" _n 									///
			"(function($) {" _n 												///
			"$.fn.extend({" _n 													///
			_skip(4)"smoothZoom: function(options) {" _n 						///
																				///
			_skip(6)"var defaults = {" _n 										///
			_skip(8)"zoominSpeed: 800," _n 										///
			_skip(8)"zoomoutSpeed: 400," _n 									///
			_skip(8)"resizeDelay: 400," _n 										///
			_skip(8)"zoominEasing: 'easeOutExpo'," _n 							///
			_skip(8)"zoomoutEasing: 'easeOutExpo'" _n 							///
			_skip(6)"}" _n 														///
																				///
			_skip(6)"var options = $.extend(defaults, options);" _n 			///
																				///
																				/// 
																				///
			_skip(6)"$('img[rel=" `"""'"zoom"`"""' "]')."						///
			"click(function(event) {" _n 										///
																				///
			_skip(8)"var link = $(this).attr('src')," _n 						///
			_skip(10)"largeImg = $(this).parent().attr('href')," _n		 		///
			_skip(10)"target = $(this).parent().attr('target')," _n 			///
			_skip(10)"offset = $(this).offset()," _n 							///
			_skip(10)"width = $(this).width()," _n 								///
			_skip(10)"height = $(this).height()," _n 							///
			_skip(10)"amountScrolled = $(window).scrollTop()," _n 				///
			_skip(10)"viewportWidth = $(window).width()," _n 					///
			_skip(10)"viewportHeight = $(window).height();" _n 					///
			/// IF THERE IS NO ANCHOR WRAP
			_skip(8)"if ((!largeImg) || (largeImg == " `"""'"#"`"""'")) {" _n 	///
																				///
			_skip(6)"$('body').append(" `"""'"<div id='lightwrap'><img "		///
			"src="`"""'" + link + "`"""'"></div><div id='lightbg'></div>"		///
			"<img id='off-screen' src="`"""'" + link + "`"""'">"`"""'");" _n 	///
			_skip(6) "$("`"""'"#off-screen"`"""'").load(function() {" _n 		///
			_skip(8)"$('#lightwrap img').css({" _n 								///
			_skip(10)"width: width," _n 										///
			_skip(10)"height: height," _n 										///
			_skip(10)"top: (offset.top - amountScrolled)," _n 					///
			_skip(10)"left: offset.left" _n		 								///
			_skip(8)"});" _n 													///
			_skip(8)"fitWidth();" _n 											///
			_skip(8)"$('#lightbg').fadeIn();" _n								///
			_skip(6)"});" _n 													///
			_skip(6)"$(this).attr('id', 'lightzoomed');" _n 					///
																				///
			/// IF THERE IS AN ANCHOR, AND IT'S AN IMAGE
			_skip(6) "} else if (largeImg.match("`"""'"jpg$"`"""'")) {" _n 		///
			"$('body').append("`"""'"<div id='lightwrap'><img src="`"""'" + "	///
			"largeImg + " 														///
			`"""'"></div><div id='lightbg'></div><img id='off-screen' src=" 	///
			`"""'" + largeImg + "`"""'">"`"""'");" _n 							///
			_skip(8)"$("`"""'"#off-screen"`"""'").load(function() {" _n 		///
			_skip(10)"$('#lightwrap img').css({" _n 							///
			_skip(10)"width: width," _n 										///
			_skip(10)"height: height," _n 										///
			_skip(10)"top: (offset.top - amountScrolled)," _n 					///
			_skip(10)"left: offset.left" _n 									///
			_skip(10)"});" _n 													///
			_skip(8)"fitWidth();" _n 											///
			_skip(8)"$('#lightbg').fadeIn();" _n 								///
			_skip(6)"});" _n 													///
			_skip(6)"$(this).attr('id', 'lightzoomed');" _n 					///
																				///	
			/// IF THERE IS AN ANCHOR, BUT NOT AN IMAGE
			_skip(4)"} else {" _n 												///
			/// SHOULD IT OPEN IN A NEW WINDOW?
			_skip(4)"if (target = '_blank') {" _n 								///
			_skip(4)"window.open(largeImg, '_blank');" _n 						///
			_skip(4)"} else {" _n 												///
			_skip(4)"window.location = largeImg;" _n 							///
			_skip(4)"}" _n 														///
			_skip(4)"}" _n 														///
			_skip(4)"event.preventDefault();" _n 								///
			_skip(4)"});" _n 													///
																				///	
			/// CLOSE MODAL
																				///
						_skip(4)"$(document.body).on("`"""'"click"`"""'", " ///
						`"""'"#lightwrap, #lightbg"`"""'", function(event) {" _n ///
							_skip(6)"var offset = $("`"""'"#lightzoomed"`"""'").offset()," _n ///
							_skip(6)"originalWidth = $("`"""'"#lightzoomed"`"""'").width()," _n ///
							_skip(6)"originalHeight = $("`"""'"#lightzoomed"`"""'").height()," _n ///
							_skip(6)"amountScrolled = $(window).scrollTop();" _n ///
							_skip(6)"$('#lightbg').fadeOut(500);" _n ///
							_skip(6)"$('#lightwrap img').animate({" _n ///
							_skip(6)"height: originalHeight," _n ///
							_skip(6)"width: originalWidth," _n ///
							_skip(6)"top: (offset.top - amountScrolled)," _n ///
							_skip(6)"left: offset.left," _n ///
							_skip(6)"marginTop: '0'," _n ///
							_skip(6)"marginLeft: '0'" _n ///
							_skip(6)"}, options.zoomoutSpeed, options.zoomoutEasing, function() {" _n ///
							_skip(6)"$('#lightwrap, #lightbg, #off-screen').remove();" _n ///
							_skip(6)"$('#lightzoomed').removeAttr('id');" _n 	///
																				///
							_skip(6)"});" _n 									///
						_skip(6)"});" _n 										///
						///
						/// DELAY FUNCTION FOR WINDOW RESIZE
						_skip(6)"var delay = (function() {" _n ///
							_skip(6)"var timer = 0;" _n ///
							_skip(6)"return function(callback, ms) {" _n ///
								_skip(6)"clearTimeout(timer);" _n ///
								_skip(6)"timer = setTimeout(callback, ms);" _n ///
							_skip(6)"};" _n ///
						_skip(6)"})();" _n ///
						///
						/// CHECK WINDOW SIZE EVERY _ MS
						_skip(6)"$(window).resize(function() {" _n ///
							_skip(6)"delay(function() {" _n ///
								_skip(6)"fitWidth();" _n ///
							_skip(6)"}, options.resizeDelay);" _n ///
						_skip(4)"});" _n ///
						///
						/// FIT IMAGE BASED ON HEIGHT
						_skip(4)"function fitHeight() {" _n ///
						///
							_skip(6)"var viewportHeight = $(window).height()," _n ///
								_skip(6)"viewportWidth = $(window).width()," _n ///
								_skip(6)"naturalWidth = $('#off-screen').width()," _n ///
								_skip(6) "naturalHeight = $('#off-screen').height()," _n ///
								_skip(6)"newHeight = (viewportHeight * 0.95)," _n ///
								_skip(6)"ratio = (newHeight / naturalHeight)," _n ///
								_skip(6)"newWidth = (naturalWidth * ratio);" _n ///
							_skip(6)"$('#lightwrap img').show();" _n ///
							_skip(6)"if (newHeight > naturalHeight) {" _n ///
								_skip(6)"$('#lightwrap img').animate({" _n ///
									_skip(6)"height: naturalHeight," _n ///
									_skip(6)"width: naturalWidth," _n ///
									_skip(6)"left: '50%'," _n ///
									_skip(6)"top: '50%'," _n ///
									_skip(6)"marginTop: -(naturalHeight / 2)," _n ///
									_skip(6)"marginLeft: -(naturalWidth / 2)" _n ///
								_skip(6)"}, options.zoominSpeed, options.zoominEasing);" _n ///
							_skip(6)"} else {" _n ///
								_skip(6)"if (newWidth > viewportWidth) {" _n ///
									_skip(6)"fitWidth();" _n ///
								_skip(6)"} else {" _n ///
									_skip(6)"$('#lightwrap img').animate({" _n ///
										_skip(6)"height: newHeight," _n ///
										_skip(6)"width: newWidth," _n ///
										_skip(6)"left: '50%'," _n ///
										_skip(6)"top: '2.5%'," _n ///
										_skip(6)"marginTop: '0'," _n ///
										_skip(6)"marginLeft: -(newWidth / 2)" _n ///
									_skip(6)"}, options.zoominSpeed, options.zoominEasing);" _n ///
								_skip(6)"}" _n ///
							_skip(6)"}" _n ///
						_skip(4)"}" _n ///
						///
						/// FIT IMAGE BASED ON WIDTH
						_skip(4)"function fitWidth() {" _n ///
							_skip(6)"var naturalWidth = $('#off-screen').width()," _n ///
								_skip(6)"naturalHeight = $('#off-screen').height()," _n ///
								_skip(6)"viewportWidth = $(window).width()," _n ///
								_skip(6)"viewportHeight = $(window).height()," _n ///
								_skip(6)"newWidth = (viewportWidth * 0.95)," _n ///
								_skip(6)"ratio = (newWidth / naturalWidth)," _n ///
								_skip(6)"newHeight = (naturalHeight * ratio);" _n ///
							_skip(6)"$('#lightwrap img').show();" _n ///
							_skip(6)"if (newHeight > naturalHeight) {" _n ///
								_skip(6)"if (naturalHeight > viewportHeight) {" _n ///
			_skip(6)"fitHeight();" _n 											///
			_skip(6)"} else {" _n 												///
			_skip(6)"$('#lightwrap img').animate({" _n 							///
			_skip(6)"height: naturalHeight," _n 								///
			_skip(6)"width: naturalWidth," _n 									///
			_skip(6)"top: '50%'," _n 											///
			_skip(6)"left: '50%'," _n 											///
			_skip(6)"marginTop: -(naturalHeight / 2)," _n 						///
			_skip(6)"marginLeft: -(naturalWidth / 2)" _n 						///
			_skip(6)"}, options.zoominSpeed, options.zoominEasing);" _n 		///
			_skip(6)"}" _n 														///
			_skip(6)"} else {" _n 												///
			_skip(6)"if (newHeight > viewportHeight) {" _n 						///
			_skip(6)"fitHeight();" _n 											///
			_skip(6)"} else {" _n 												///
			_skip(6)"$('#lightwrap img').animate({" _n 							///
			_skip(6)"height: newHeight," _n 									///
			_skip(6)"width: newWidth," _n 										///
			_skip(6)"top: '50%'," _n 											///
			_skip(6)"left: '2.5%'," _n 											///
			_skip(6)"marginTop: -(newHeight / 2)," _n 							///
			_skip(6)"marginLeft: '0'" _n 										///
			_skip(6)"}, options.zoominSpeed, options.zoominEasing);" _n 		///
			_skip(4)"}" _n 														///
			_skip(4)"}" _n 														///
			_skip(4)"}" _n 														///
																				///
																				///
			_skip(2)"}" _n 														///
			_skip(2)"});" _n 													///
			"})(jQuery);" _n 													///
			"</script>" _n(4)


			// ADDING THE SMOOTH ZOOM SCRIPT 
			// =============================
			//file write `canvas' "<script type=" `" "text/javascript">"' 		///
			//" $(window).load( function() {$('img').smoothZoom({ " 			///
			//"});});</script> " _n
	
	
	
	file close `canvas'
end
	
	
	
	

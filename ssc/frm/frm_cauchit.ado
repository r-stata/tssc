*! Version 1.1.2 - 27 May 2014
*! By Joaquim J.S. Ramalho
* Please email jsr@uevora.pt for help and support

* The software is provided as is, without warranty of any kind, express or implied, including 
* but not limited to the warranties of merchantability, fitness for a particular purpose and 
* noninfringement. In no event shall the authors be liable for any claim, damages or other 
* liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
* connection with the software or the use or other dealings in the software.

program define frm_cauchit
	version 7
	args todo eta mu return

	if `todo' == -1 {
		global SGLM_lt "Cauchit"
		global SGLM_lf "tan(pi*(u-0.5))"

		exit
	}

	if `todo' == 0 {
		gen double `eta' = tan(_pi*(`mu'-0.5))
		exit
	}

	if `todo' == 1 {
		gen double `mu' = 0.5+(1/_pi)*atan(`eta')
		exit
	}

	if `todo' == 2 {
		gen double `return' = 1/(_pi*(`eta'^2+1))
		exit
	}

	if `todo' == 3 {
		gen double `return' = (-2*`eta')/(_pi*(`eta'^2+1)^2)
		exit
	}

	noi di as err "Unknown call to glm link function"
	exit 198
end

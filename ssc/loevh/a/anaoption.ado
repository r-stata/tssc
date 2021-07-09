*! version 1  27may2007
*! Jean-Benoit Hardouin
*
************************************************************************************************************
* Stata program : anaoption
*
* Historic
* Version 1 (2007-05-27): Jean-Benoit Hardouin
*
* Jean-benoit Hardouin, phD, Assistant Professor
* Team of Biostatistics, Clinical Research and Subjective Measures in Health Sciences
* University of Nantes - Faculty of Pharmaceutical Sciences
* France
* jean-benoit.hardouin@anaqol.org
*
* News about this program :http://www.anaqol.org
* FreeIRT Project website : http://www.freeirt.org
*
* Copyright 2007 Jean-Benoit Hardouin
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*
************************************************************************************************************

program define anaoption ,rclas
version 7.0
syntax [, DETails minvi(real .03) siglevel(real 0.05) minsize(real 0)]

return scalar minvi=`minvi'
return scalar siglevel=`siglevel'
return scalar minsize=`minsize'
return local details `details'


end


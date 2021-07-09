*! usesasdel Version 1.1 dan_blanchette@unc.edu 16Mar2009
*! the carolina population center, unc-ch
** Center for Entrepreneurship and Innovation Duke University's Fuqua School of Business
** usesasdel Version 1.1 dan_blanchette@unc.edu  01Feb2008
** - made the string comparison work for very long strings
** research computing, unc-ch
** usesasdel Version 1.0 dan_blanchette@unc.edu  09Nov2005
** the carolina population center, unc-ch

// can only delete files with no spaces in their names 
//  but can handle directory names with spaces in their names
program define usesasdel
version 8
  args dir basefilename 
       local files :  dir `"`dir'"' files `"`basefilename'*"' , nofail
       foreach f in `files' {
         local dirf `"`dir'/`f'"'
         if `: list local(dir) == local(dirf)' == 0 {
             erase  `"`dir'/`f'"'
         }
       }
 end

exit



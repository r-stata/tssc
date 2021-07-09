*! excelcol 1.0.0 19jul2014
*! by Sergiy Radyakin
*! 0c1941df-aa73-48d8-a39e-0e02f55445df

program define excelcol, rclass
   version 9.2
   syntax anything
   confirm number `anything'
   
   mata st_local("result", ExcelColumn(`anything'))
   return local column `"`result'"'
end


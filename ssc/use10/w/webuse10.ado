program webuse10, rclass
   /*   By Sergiy RADYAKIN, 10Oct2008   */
   version 9.2
   capture syntax [anything], [*]
   tempfile webfile
   copy `"`anything'"' `"`webfile'"'
   use10 `"`webfile'"', `options'
end
//END OF FILE

putdocx clear
putdocx begin
putdocx paragraph, style(Heading1)
This is the title for this document

This for text inside of the document. It can go on and on. After all, most documents are mostly text.
It can have new paragraphs without a bunch of extra commands.
The important part is that it is halfway possible to read what is being done here.

This is now a second paragraph, which is starting with two linebreaks in a row. The two line breaks are just the equivalent of a simple putdocx paragraph, with no options.

If you wanted to be fancy, and have the putdocx command above show up like code in the docx document, you still do standard putdocx work
The blank lines are equivalent of a simple 
putdocx text ("putdocx paragraph"), font("Courier New",10)
 with no options. 

Now we can put in some Stata code... which will not appear in the document.
* Star-comments can be used to make things readable
* The indentation of the code is not not special... it is for readability
putdocx pause
  sysuse auto, clear
  gen gp100m = 100/mpg
  graph matrix gp100m weight length turn
  graph export gphmat.png, replace
  regress gp100m weight length turn i.foreign
** end of Stata code
putdocx resume
 Now some results from our analysis. First a picture of the results
putdocx image gphmat.png, width(4)

Now the result of the regression:
putdocx table reg = etable

* tables require a new paragraph to flush the table, hence the blank line
There we go... some analysis and some text in one document.
This still has some programmerish stuff in it, but it can be typed and read a bit more quickly.
putdocx save example, replace

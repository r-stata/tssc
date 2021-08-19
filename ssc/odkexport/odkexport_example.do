**********************************************************
*** Example do-file for the commands odk2doc & odk2xls ***
**********************************************************


/*
Commands written by Anna Reuter

To create the example output files, you need the example spread sheet "Example_xlsForm".
Please note that the final formatting options differ between odk2doc and odk2xls.
*/



*** odk2doc ***

* 1 *
// Create a plain docx questionnaire from the xlsForm "Example_xlsForm"
odk2doc using "Example_xlsForm", to("Example_converted.docx")

* 2 *
// Keep the columns "relevant", "constraint_message::English (en)" and "constraint_message::Deutsch (de)"
// Drop the question named "comments"
// Replace the existing file
odk2doc using "Example_xlsForm", to("Example_converted.docx") keep(relevant constraint_m) dropv(comments) replace

* 3 *
// Display required output below open-ended questions
// Delete the words "Introduction" and "Vorstellung" from every question and answer
// Clean the mark-up language and mark multiple-select questions
odk2doc using "Example_xlsForm", to("Example_converted.docx") keep(relevant constraint_m) dropv(comments) fill del("Introduction" "Vorstellung") clean mark(multiple) replace

* 4 * 
// Create a fully formatted questionnaire using the formatting options provided by the putdocx command
odk2doc using "Example_xlsForm", to("Example_converted.docx") keep(relevant constraint_m) dropv(comments) fill del("Introduction" "Vorstellung") clean mark(multiple) doc(land) fmt(border(all,nil)) tfmt(border(top,single) border(bottom,single) bold) qfmt(shading(lightsteelblue)) afmt(italic) replace



*** odk2xls ***

* 1 *
// Create a plain docx questionnaire from the xlsForm "Example_xlsForm"
odk2xls using "Example_xlsForm", to("Example_converted.xlsx")

* 2 *
// Keep the columns "relevant", "constraint_message::English (en)" and "constraint_message::Deutsch (de)"
// Drop the question named "comments"
// Replace the existing file
odk2xls using "Example_xlsForm", to("Example_converted.xlsx") keep(relevant constraint_m) dropv(comments) replace

* 3 *
// Display required output below open-ended questions
// Delete the words "Introduction" and "Vorstellung" from every question and answer
// Clean the mark-up language and mark multiple-select questions
odk2xls using "Example_xlsForm", to("Example_converted.xlsx") keep(relevant constraint_m) dropv(comments) fill del("Introduction" "Vorstellung") clean mark(multiple) replace

* 4 * 
// Create a fully formatted questionnaire using the formatting options provided by the putexcel command
odk2xls using "Example_xlsForm", to("Example_converted.xlsx") keep(relevant constraint_m) dropv(comments) fill del("Introduction" "Vorstellung") clean mark(multiple) tfmt(border(top) bold) qfmt(fpattern(solid,lightsteelblue)) afmt(italic) replace


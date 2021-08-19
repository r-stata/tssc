//Example 1

//Load in the immigration conjoint experiment dataset (Hainmueller et al., 2013) 
//as analysed in Hainmueller et al., (2014), and using the two main R conjoint 
//packages, cjoint (Barari et al., 2018) and cregg (Leeper and Barnfield, 2020):
use immigration_conjoint

//Estimate AMCEs using all attributes in the design with the standard errors 
//adjusted for clustering (model 1):
conjoint Chosen_Immigrant Gender Education Language_Skills Country_of_Origin ///
Job Job_Experience Job_Plans Reason_for_Application Prior_Entry, est(amce) id(CaseID)

//Run same model can be run but incorporate profile constraints as per would be 
//estimated using cjoint on page 5 of Barari et al., (2018) (model 2):
conjoint Chosen_Immigrant Gender Education Language_Skills Country_of_Origin ///
Job Job_Experience Job_Plans Reason_for_Application Prior_Entry, est(amce) ///
id(CaseID) constraint(Country_of_Origin#Reason_for_Application Education#Job)

//Run the same model but change the baselevel for language skills (the third 
//attribute) (model 3):
conjoint Chosen_Immigrant Gender Education Language_Skills Country_of_Origin ///
Job Job_Experience Job_Plans Reason_for_Application Prior_Entry, est(amce) ///
id(CaseID) constraint(Country_of_Origin#Reason_for_Application Education#Job) ///
base(1 1 4 1 1 1 1 1 1)

//Run model 2 but estimate MMs as per would be estimated using cregg on page 9 
//of Leeper and Barnfield (2020):
conjoint Chosen_Immigrant Gender Education Language_Skills Country_of_Origin ///
Job Job_Experience Job_Plans Reason_for_Application Prior_Entry, est(mm) id(CaseID)
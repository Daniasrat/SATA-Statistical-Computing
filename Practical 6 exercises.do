* -------------------------------------
* Stats Computing: Stata
* -------------------------------------
* Exercise 5: Advanced Data Management
* -------------------------------------

clear
cd "H:\Stats Computing\Stata\Data"

* -------------------------
* 5.1 Loops and Strings
* -------------------------

use fup_meds, clear

* Change values to lower case

forvalues i = 1/10 {
	replace fumed`i' = lower(fumed`i')
}

* Create indicator variable for beta-blocker use

gen bb = 0
lab var bb "Beta-blocker"

foreach V of varlist fumed1-fumed10 {
	recode bb 0 = 1 if `V'=="beta blockers"
}

tab bb

gen ace = 0
lab var ace "Ace inhibitor"

foreach V of varlist fumed1-fumed10 {
	recode ace 0 = 1 if `V'=="ace"
}

tab ace

tab ace bb

save fup_meds_recode , replace



use bl_meds_all , clear

* -----------------------------------------------------------------
* need to run the next section together
* -----------------------------------------------------------------

* create local macro called drgname containing list of lipid lowering drug names
local drgname caduet crestor juvisync lescol lipitor livalo /// 
	mevacor pravachol simcor vytorin zocor statin niacin ezetimibe

gen liplow = 0
lab var liplow "Lipid lowering drug"

* Loop through each of the variables med1 to med10 and through each of the 
* names in the local macro drgname

foreach V of varlist med1-med10 {     					// start of loop 1
	replace `V' = lower(`V')
	foreach D of local drgname {		  				// start of loop 2
		recode liplow 0 = 1 if strpos(`V', "`D'")>0
	}													// end of loop 2
}														// end of loop 1

* -----------------------------------------------------------------
tab liplow

save bl_meds_recode , replace


* -------------------------
* 5.2 Elapsed Dates
* -------------------------

use bl_combined_v2, clear

list birthdt indx_day indx_mon indx_year cons_dt randdt in 1/5

* Birthdate to elapsed date (single string variable day/month/year)
gen birthdt2 = date(birthdt, "DMY") 
format birthdt2 %td
list birthdt birthdt2 in 1/5
drop birthdt
rename birthdt2 birthdt 

* Index event date (3 variables)
gen indx_dt = mdy(indx_mon, indx_day, indx_year)
format indx_dt %td
list indx* in 1/5
drop indx_mon indx_day indx_year

* Consent date (single variable month-day-year (no century))
gen cons_dt2 = date(cons_dt, "MD20Y")
format cons_dt2 %td
list cons* in 1/5
drop cons_dt
rename cons_dt2 cons_dt

* Randomisation date (stored as number but not elapsed date format)
* e.g. 20141231 = 31st December 2014
tostring randdt, replace
gen randdt2 = date(randdt, "YMD")
format randdt2 %td
list rand* in 1/5
drop randdt
rename randdt2 randdt 

* Use dates to create age at randomisation
gen age_rand = (randdt - birthdt) / 365.25
lab var age_rand "Age at randomisation"

summ age_rand
hist age_rand
list age age_rand in 1/10

list hfhospdt in 1/20 

* One potential solution
tostring hfhospdt, replace
list hfhospdt in 1/20 

* Where length of hfhospdt is 8 characters date is complete
* and can use mdy function
gen hfhosp_dt = mdy(real(substr(hfhospdt, 5, 2)),  ///	
				  real(substr(hfhospdt, 7, 2)),  ///
				  real(substr(hfhospdt, 1, 4))) if length(hfhospdt)==8

* Where length of hfhospdt is 6 characters then just day missing
* Assume day to be middle of month e.g. 15
replace hfhosp_dt = mdy(real(substr(hfhospdt, 5, 2)),  ///	
				  15,  ///
				  real(substr(hfhospdt, 1, 4))) if length(hfhospdt)==6

* Where length of hfhospdt is 4 characters then day and month missing
* An assume date to be middle of year 1st July
replace hfhosp_dt=mdy(7,  ///	
				  1,  ///
				  real(substr(hfhospdt, 1, 4))) if length(hfhospdt)==4


format hfhosp_dt %td
list hf*dt in 1/20

save bl_combined_v2_edit , replace


* End of file
* =========================================================================
* Stats Computing: Stata
* -------------------------------------------------------------------------
* Exercise 5: Essential Data Processing (cont.) and Descriptive Statistics  
* =========================================================================

cd "H:\Stats Computing\Stata\Data"


* ====================================================
* Essential Data Processing (cont.)
* ====================================================

use bl_combined_label, clear

* ----------------------------------------------------
* 5.1: egen
* ----------------------------------------------------

* Creating categorical variables with the cut function
egen bmi5 = cut(bmi), group(5) label
lab var bmi5 "BMI category (fifths)"
tab bmi5

egen bmicat = cut(bmi), at(12, 22, 25, 30, 60) label 
lab var bmicat "BMI categories"
tab bmicat


* Creating a row summary variable
tab1 strisch strhem stremb stroth
tab1 strisch strhem stremb stroth, nol
egen stroke = rowmax(strisch strhem stremb stroth)
tab stroke

tab1 strisch strhem stremb stroth, missing
egen strokemiss = rowmiss(strisch strhem stremb stroth)
tab strokemiss
tab strokemiss stroke
tab strokemiss stroke, missing

tab1 diur asp arb bblock digox
egen numdrugs = rowtotal(diur asp arb bblock digox)
tab numdrugs


* ----------------------------------------------------
* 5.2: Missing values
* ----------------------------------------------------

tab1 bl_creat bl_pot bl_totbil
**bl_creat has missing values coded as .a & .b, from step 4.7
mvdecode bl_pot bl_totbil, mv(8888=.a \ 9999=.b) 
tab1 bl_creat-bl_totbil
tab1 bl_creat-bl_totbil, missing

misstable summarize bl_creat-bl_totbil

misstable patterns bl_creat-bl_totbil

save bl_combined_recode, replace



* ====================================================
* Descriptive Statistics 
* ====================================================

use bl_combined_v2, clear

* ---------------------------------------
* 5.3 Summarising Continuous variables
* ---------------------------------------

summ bmi egfr lvef bl_creat, d

hist bmi, normal name(h_bmi, replace)
hist egfr, normal name(h_egfr, replace)
hist lvef, normal name(h_lvef, replace)
hist bl_creat, normal name(h_bl_creat, replace)

graph box bmi, name(b_bmi, replace)
graph box egfr, name(b_egfr, replace)
graph box lvef, name(b_lvef, replace)
graph box bl_creat, name(b_bl_creat, replace)

* BMI, EGFR and CREAT - appear reasonably normal
* LVEF not normal 


* ---------------------------------------
* 5.4 Association between continuous vars
* ---------------------------------------

pwcorr bmi sbp egfr lvef bl_creat 

graph matrix bmi sbp egfr lvef bl_creat, ms(oh) half

scatter egfr bl_creat, ms(oh) name(s_1, replace)
scatter sbp bmi, ms(oh) name(s_2, replace)


* ---------------------------------------
* 5.5 Association between a continuous & 
* categorical variable
* ---------------------------------------

* bmicat (categorical) and sbp (continuous)

table bmicat, statistic(count sbp) statistic(mean sbp) statistic(sd sbp) nformat(%3.1f  mean sd) 

tabstat sbp, by(bmicat) stats(count mean sd)
graph box sbp, over(bmicat) marker(1, ms(oh)) name(sbp_bmicat, replace)

* diab (categorical/binary) and bmi (continuous)
table diab, statistic(count bmi) statistic(mean bmi) statistic(sd bmi) nformat(%3.1f  mean sd) 
tabstat bmi, by(diab) stats(count mean sd)
graph box bmi, over(diab) marker(1, ms(oh)) name(bmi_diab, replace)

* Two-sample t-test
ttest sbp, by(overwt)


* ---------------------------------------
* 5.6 Association between 2 categorical vars
* ---------------------------------------

* agegroup and pep
tabulate agegroup pep, row chi 
* percentage of patients with pep increases with age
* though lowest two categories very similar

* bmicat and pep
tabulate bmicat pep, row chi
* lower pep in higher bmi category

**missing values
tabulate bmicat pep, row miss

**odds of PEP in each BMI group
tabodds pep bmicat

**ORs comparing higher BMI categories to the reference (BMI<22) 
**odds of PEP is lower in BMI 25+ and BMI 30+, compared with BMI<22
tabodds pep bmicat, or

tabodds pep bmicat, graph ci yscale(log)


* ===========================================
* Optional exercise Overlaid Two-way Graphs
* ===========================================

use meanpot, clear
desc
list

gen low = mean_pot - 1.96 * sem_pot
gen up = mean_pot + 1.96 * sem_pot
list

gen visit2 = (visit - 0.1) * (trt==1) + (visit + 0.1) * (trt==2)
label values visit2 visit
list

#delimit ;
twoway (rspike low up visit2 if trt==1, lcolor(gs1)) 
	(rspike low up visit2 if trt==2, lcolor(gs8))
	(connected mean_pot visit2 if trt==1, mcolor(gs1) lcolor(gs1) 
		msymbol(square))
	(connected mean_pot visit2 if trt==2, mcolor(gs8) lcolor(gs8)
		msymbol(square)), 
	ytitle("Mean (95% CI) Potassium (mmol/L)") 
	xtitle("Visit", m(t+1))
	xscale(range(0.5 11.5))
	xlabel(1 3(1)10, labsize(*0.6) valuelabel) 
	ylabel(4.2(0.1)4.6, labsize(*0.7) angle(hori) format(%2.1f))
	legend(off)
	text(4.5 10.5 "Group A" , col(gs1) size(*0.7))
	text(4.4 10.7 "Group B" , col(gs8) size(*0.7))
	name(meanpot2, replace)
;
#delimit cr

	
* End of file
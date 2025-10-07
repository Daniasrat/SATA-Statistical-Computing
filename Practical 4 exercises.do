* =================================================================
* Stats Computing: Stata
* -----------------------------------------------------------------
* Exercise 4: Housekeeping and Essential Data Processing 
* =================================================================

cd "H:\Stats Computing\Stata\Data"


use bl_combined_label, clear

* ====================================================
* HOUSEKEEPING
* ====================================================

use bl_combined_all, clear

describe

* ====================================================
* 4.1 Renaming Variables
* ====================================================

rename wt wt_kg
rename ht ht_cm
rename (creat pot totbil) (bl_creat bl_pot bl_totbil)
rename _all, lower


* ====================================================
* 4.2 Labelling Variables
* ====================================================
lab var sbp "Systolic blood pressure (mmHg)"
lab var dbp "Diastolic blood pressure (mmHg)"


* ====================================================
* 4.3 Labelling Values
* ====================================================
label define hfdiag_lab 1 "Ischaemic" 2 "Non-ischaemic"
tab hfdiag
lab val hfdiag hfdiag_lab
tab hfdiag


lab define noyes_lab 0 "No" 1 "Yes"

tab1 strisch strhem stremb stroth hyptn
foreach var of varlist strisch-stroth hyptn  {
	lab val `var' noyes_lab
}
tab1 strisch-stroth hyptn 

**another way to attach the value lables
lab val (strisch-stroth hyptn ) noyes_lab


* ====================================================
* 4.4 Viewing Value Labels
* ====================================================
desc
label list
label list hfdiag_lab

save bl_combined_label, replace

* ====================================================
* ESSENTIAL DATA PROCESSING
* ====================================================

* ====================================================
* 4.5 Creating new variables using generate and replace
* ====================================================

use bl_combined_label, clear

* Body Mass Index
sum wt ht
gen bmi = wt/(ht/100)^2 
* some missing values created because some wt and ht are missing
lab var bmi "Body Mass Index"
sum bmi 
hist bmi 

* Waist circumference
* Variable wc is measured in mix of cm and m
* create new variable which is all in cm
sum wc, det
hist wc
tab wc_unit
gen wc_cm = wc // create copy of wc
replace wc_cm = wc_cm*100 if wc_unit=="M"  // change values where measured in m
lab var wc_cm "Waist circumference (cm)"
sum wc_cm, det
hist wc_cm

* Create binary indicator variable for BMI>=30

* Using true/false condition to create a 1/0 variable
* Need to take care using > or < when there are missing values

list ptid bmi if bmi>50   // missing values treated as being >50

gen obese = (bmi>=30) if !missing(bmi)
lab define oblab 0 "BMI<30"1 "BMI 30+"
lab val obese oblab
lab variable obese "BMI 30+"
tab obese


*binary indicator for hypertension
sum sbp dbp
bro ptid sbp dbp if sbp>140 | dbp>90
gen hyper = (sbp>140 | dbp>90) if !missing(sbp, dbp)
lab var hyper "SBP >140 or DBP>90"
tab hyper

* Log transformations
sum egfr
gen log_egfr = log(egfr)
sum log_egfr
hist egfr, name(egfr, replace)
hist log_egfr, name(log_egfr, replace)

sum bl_totb
gen log_bl_totbil = log(bl_totb) if bl_totb<8888
sum log_bl_totb
hist bl_totb if bl_totb<8888, name(tb, replace)
hist log_bl_totb, name(log_tb, replace)


* ====================================================
* 4.6 destring or encode
* -------------------------------
* Converting variables from 
* string to numeric
* ====================================================

* Sex
codebook sex
* Sex is a categorical string variable - use encode
encode sex, gen(sex2)
list sex sex2 in 1/10 
list sex sex2 in 1/10, nolab
tab sex sex2, nol
drop sex
rename sex2 sex

* LVEF
codebook lvef
tab lvef
* lvef is a string variable; It mostly consists 
* of numeric characters but missing values are "NA"
destring lvef, replace ignore("NA") 
tab lvef

* Race
codebook race
tab race
* ethnicity is a categorical string variable - use encode
* but don't want to use alphabetical order for new values

* Step 1: define value label
label define race_lab 1 "White" 2 "Asian" 3 "Black" 4 "Other"

* Step 2: use encode command with the label option
encode race, gen(race2) label(race_lab)
tab race race2 
drop race
rename race2 race


* ====================================================
* 4.7: recode
* ====================================================

* Recoding "numeric missing" values to Stata system missing 
tab bl_creat // values 8888 and 9999 treated as real values
recode bl_creat (8888=.a) (9999=.b)
tab bl_creat, missing
hist bl_creat 

* Recoding a metric variable to create a categorical variable
* (note can also be done with egen and cut)
* Here we add value labels at same time
recode sbp (min/129.9 = 0 "<130 mmHg") (130/139.9 = 1 "130-139 mmHg") ///
	(140/149.9 = 2 "140-149 mmHg") (150/max = 3 "150+ mmHg"), gen(sbpcat)
lab var sbpcat "SBP category"
tab sbpcat // check distribution

tabstat sbp, by(sbpcat) stat(min max) // check against sbp values


* Recode 2->1 and 1->0 for baseline medication variables
tab1 diur asp arb bblock digox
foreach V of varlist diur asp arb bblock digox {
	recode `V' 2=1 1=0 
}
tab1 diur asp arb bblock digox

save bl_combined_label, replace

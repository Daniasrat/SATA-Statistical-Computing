* -------------------------------------
* Stats Computing: Stata
* -------------------------------------
* Exercise 6: Advanced Data Management
* -------------------------------------

clear
cd "H:\Stats Computing\Stata\Data"


*------------------------------------
* 6.1 Repeated Measurements
*------------------------------------

use fup_sbp, clear

sort ptid visit
list in 1/9

bysort ptid (visit): gen n=_n
bysort ptid (visit): gen N=_N

* Distribution of the number of visits per patient
tab N if n==1

* Last visit per person
tab visit if n==N

* Change from week 1
bysort ptid (visit): gen sbp_chbl = sbp - sbp[1]
list ptid visit sbp* in 1/19, clean

table visit trt, statistic(count sbp_chbl) statistic(mean sbp_chbl) nformat(%3.2f  mean) 


* indicator for whether SBP > 140 at anytime during the study
* be careful of missing values

gen sbp140a = (sbp>140) if !missing(sbp)
bysort ptid: egen sbp140 = max(sbp140a) 
drop sbp140a

* 1 missing value for patient without any sbp measurement
list ptid visit sbp if sbp140==.

save fup_sbp_edit, replace


* -----------------------------------
* 6.2 Creating Summary Datasets
* -----------------------------------

use fup_pot_long_trt, clear

list in 1/20   // data in long format

collapse (mean) m_pot = potval (sem) sem_pot = potval, by(visit trt)

list

gen lci_pot = m_pot - 1.96 * sem_pot
gen uci_pot = m_pot + 1.96 * sem_pot

save fup_meanpot, replace


* -----------------------------------
* 6.3 Reshaping Data
* -----------------------------------

* Reshape from long to wide
use fup_hrate, clear

list in 1/18, sep(9)   // data in long format

reshape wide hrate visdate, i(ptid) j(visit)

list ptid hrate3 visdate3 hrate4 visdate4 in 1/10 

pwcorr hrate* 

save fup_hrate_wide, replace

* Reshape from wide to long
use fup_anthrop, clear

list ptid age sex trt wt3 wc3 visdate3 wt4 wc4 visdate4 in 1/5

pwcorr wt*
pwcorr wc*  // something strange about wc4 - lower correlations
summ wc4, d   // value of 970 clearly wrong
recode wc4 970 = .a
pwcorr wc* 

reshape long wt wc visdate, i(ptid) j(visit) 

bysort ptid (visit): gen double wt_chbl = wt - wt[1]

save fup_anthrop_long, replace


* End of file
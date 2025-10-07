* ==========================================
* Ex 3: Creating and Combining Datasets
* ==========================================

* Change Working Directory
cd "H:\Stats Computing\Stata\Data"

* ==========================================
* 3.1 Importing Data From Excel
* ==========================================

* Import worksheet called bl_medhis1 from bl_medhis.xlx
import excel using bl_medhis.xls, sheet(bl_medhis1) firstrow clear
* Save to current directory as a Stata dataset
save bl_medhis1, replace 

* Repeat for second worksheet
import excel using bl_medhis.xls, sheet(bl_medhis2) firstrow clear
save bl_medhis2, replace


* ==========================================
* 3.2 Importing Delimited Text Files
* ==========================================

* ----------------------------------
* A. Tab-delimited text file 
* with variable names in first row
* ----------------------------------

* View data in first 5 lines
type bl_labs1.txt, lines(5)
type bl_labs1.txt, lines(5) showtabs

import delimited bl_labs1.txt, clear varnames(1)
save bl_labs1, replace

* Can use loop to save time
forvalues i = 2/3 {
	import delimited using bl_labs`i'.txt, clear varnames(1)
	save bl_labs`i', replace
}

* ------------------------------------
* B Comma-delimited text file 
* with variable names in first row
* ------------------------------------
type bl_rand.txt, lines(5) showtabs

import delimited bl_rand.txt, clear varnames(1) delimiter(",")
save bl_rand, replace 


* ==========================================
* 3.3 Importing Free Format Text Files
* ==========================================

* bl_meds.txt

type bl_meds.txt, lines(20) showtabs

* No variable names. 11 variables - single records go over >1 line.
* All variables are strings. Ptid is 9 characters but not obvious 
* what maximum length of other 10 variables is. Will use 100 and then 
* check if any have been truncated.

infile str9 ptid str100(med1 med2 med3 med4 med5 med6 med7 med8 med9 med10) ///
	using bl_meds.txt, clear

* Look at data
browse

* Compress to check for any truncation of strings
compress
* All ok as all vars have been compressed to <100

save bl_meds, replace


* ==========================================
* 3.4 Importing Fixed Format Text Files
* ==========================================

* trt_codes.txt

type trtcodes.txt, lines(5) showtabs

* Fixed format - no variable names.
* First 4 characters randomisation code
* Final character treatment group

infix rcode 1-4 str8 randdt 5-12 trt 13 using trtcodes.txt, clear

save trtcodes, replace


* ==========================================
* COMBINING DATASETS
* ==========================================

* ==========================================
* 3.5 APPENDING DATASETS
* ==========================================

* Append bl_labs1-4.txt
clear
append using bl_labs1 bl_labs2 bl_labs3 
describe
tab regid
save bl_labs_append, replace // save combined dataset


* ==========================================
* 3.6 MERGING DATASETS
* ==========================================

* Step 1: load master data set
use bl_demog, clear
desc

* Step 2: merge on the using dataset bl_medhis1 
merge 1:1 ptid using bl_medhis1, gen(m_medhis1)
desc

* Step 3-5
merge 1:1 ptid using bl_medhis2, gen(m_medhis2)
merge 1:1 ptid using bl_labs_append, gen(m_labs)
merge 1:1 ptid using bl_rand, gen(m_rand)
**note that the unique identifier here is 'rcode'
merge 1:1 rcode using trtcodes, gen(m_trt) force

save bl_merge , replace


* ---------------------------
* Merging part of a dataset
* ---------------------------
use fup_endpoints, clear
desc

merge 1:1 ptid using bl_merge, gen(m_baseline) keepusing(sex age trt) 
desc

save fup_endpoints_demog, replace

* ---------------------------
* Many to one merges
* ---------------------------

* first look at structure of each dataset by listing a few lines
use fup_pot_long, clear
desc
list in 1/10

use bl_merge, clear
desc
sort ptid
list ptid age sex trt in 1/2

* now merge using a 'many to one' (m:1) merge
use fup_pot_long, clear
merge m:1 ptid using bl_merge, keepusing(age sex trt) gen(m_baseline)

* Note: 3 records do not match.
* Where are they from?
* All 3 from using dataset i.e. bl_merge

list in 1/10
**can also restrict to those that are from bl_merge
list if m_baseline==2


* ------------------------------
* Merging with >1 key variable
* ------------------------------

* Here we need to use two key identifying variables
* both patient id and visit id are needed

merge 1:1 ptid visit using lab_dates, gen(m_dates) keepusing(visdate) 

save fup_pot_long_dates, replace



* END *


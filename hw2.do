*** Table 1 ***

*Specify below the path where Detroit.csv is located before running the file
local PATH "C:/.../"
cd "`PATH'"



drop _all
timer clear

import delimited detroit.csv
gen logflows = log(flows)
gen logdist1 = log(distance_google_miles)
gen logdist2 = log(duration_minutes)

qui tab work_id, gen(work_id_dum)
qui tab home_id, gen(home_id_dum)

set matsize 3000

** Using Distance

* 1: reg
timer on 1
qui reg logflows logdist1 i.work_id i.home_id
estimates store gravity_reg1
timer off 1


* 2: xtreg
timer on 2
xtset work_id home_id
qui xtreg logflows logdist1, fe
xtset, clear
estimates store gravity_xtreg1
timer off 2

* 3: areg
timer on 3
qui areg logflows logdist1 i.home_id, absorb(work_id)
estimates store gravity_areg1
timer off 3


* 4: reghdfe
timer on 4
qui reghdfe logflows logdist1, absorb(work_id home_id)
estimates store gravity_reghdfe1
timer off 4

*5: glm. Takes too long	
*glm flows logdist1 i.home_id i.work_id, family(poisson)
*estimates store gravity_glm_poisson1


* 6: ppml. Takes too long
*qui ppml flows logdist1 work_id home_id work_id_dum* home_id_dum*
*estimates store gravity_ppml1

* 7: poi2hdfe
timer on 7
qui poi2hdfe flows logdist1, id1(work_id) id2(home_id)
estimates store gravity_poi2hdfe1
timer off 7

* 8: ppmlhdfe
timer on 8
qui ppmlhdfe flows logdist1, absorb(i.work_id i.home_id)
estimates store gravity_ppmlhdfe1
timer off 8










** Using Time


* 9: reg
timer on 9
qui reg logflows logdist2 i.work_id i.home_id
estimates store gravity_reg2
timer off 9


* 10: xtreg: too long
*timer on 10
*xtset work_id home_id
*qui xtreg logflows logdist2, fe
*xtset, clear
*estimates store gravity_xtreg2
*timer off 10

* 11: areg
timer on 11
qui areg logflows logdist2 i.home_id, absorb(work_id)
estimates store gravity_areg2
timer off 11


* 12: reghdfe
timer on 12
qui reghdfe logflows logdist2, absorb(work_id home_id)
estimates store gravity_reghdfe2
timer off 12

*13: glm. Takes too long	
*glm flows logdist2 i.home_id i.work_id, family(poisson)
*estimates store gravity_glm_poisson2


* 14: ppml. Takes too long
*qui ppml flows logdist2 work_id home_id work_id_dum* home_id_dum*
*estimates store gravity_ppml2

* 15: poi2hdfe
timer on 15
qui poi2hdfe flows logdist2, id1(work_id) id2(home_id)
estimates store gravity_poi2hdfe2
timer off 15

* 16: ppmlhdfe
timer on 16
qui ppmlhdfe flows logdist2, absorb(i.work_id i.home_id)
estimates store gravity_ppmlhdfe2
timer off 16


esttab gravity_reg1 gravity_xtreg1 gravity_areg1 gravity_reghdfe1 gravity_reg2 gravity_xtreg2 gravity_areg2 gravity_reghdfe2 ///
	using table1.tex, ///
	replace ///
	keep(logdist1 logdist2) se ar2 label ///
	title(Gravity Estimation: Log-Linear) ///
	nonumbers mtitles("reg" "xtreg" "areg" "reghdfe" "reg" "xtreg" "areg" "reghdfe")

timer list


esttab gravity_poi2hdfe1 gravity_ppmlhdfe1 gravity_poi2hdfe2 gravity_ppmlhdfe2 ///
	using table2.tex, ///
	replace ///
	keep(logdist1 logdist2) se ar2 label ///
	title(Gravity Estimation: Poisson) ///
	nonumbers mtitles("poi2_hdfe" "ppmlhdfe" "poi2_hdfe" "ppmlhdfe")

timer list




*** Table 2 ***
timer clear
keep work_id home_id flows distance_straight_miles distance_google_miles duration_minutes logflows logdist1 logdist2


* 1: A log-linear regression that omits observations in which flow equals zero.
timer on 1
qui reghdfe logflows logdist1, absorb(work_id home_id)
estimates store reg_1
timer off 1

* 2: A log-linear regression that omits observations in which flow equals zero. 
* In addition, set the dependent variable to log of flow plus one
gen logflows_nozeros_plus1 = log(flows+1) if flows != 0
timer on 2
qui reghdfe logflows_nozeros_plus1 logdist1, absorb(work_id home_id)
estimates store reg_2
timer off 2

* 3: A log-linear regression in which the dependent variable is log of flow plus one.
gen logflows_plus1 = log(flows+1)
timer on 3
qui reghdfe logflows_plus1 logdist1, absorb(work_id home_id)
estimates store reg_3
timer off 3

* 4: A log-linear regression in which the dependent variable is log of flow plus 0.01.
gen logflows_plus001 = log(flows+0.01)
timer on 4
qui reghdfe logflows_plus001 logdist1, absorb(work_id home_id)
estimates store reg_4
timer off 4

* 5: A log-linear regression in which the dependent variable is log flow, 
* but flows Xij that are zero in the data are replaced by the value 
* log(10^-12 times Xjj) as the dependent variable.

gen flows_jj = (work_id==home_id)*flows
replace flows_jj = . if (flows_jj == 0 & (work_id!=home_id))
putmata flows_jj, omitmissing replace
mata
vect1 = J(length(flows_jj), 1, 1)
x = flows_jj#vect1
end
getmata (flowsjjl)=x

gen logflows5 = log(flows)
replace logflows5 = log((10^(-12))*flowsjjl) if flows==0

timer on 5
qui reghdfe logflows5 logdist1, absorb(work_id home_id)
estimates store reg_5
timer off 5

* 6: An estimate of the same constant-elasticity specification that uses the poi2hdfe

timer on 6
qui poi2hdfe flows logdist1, id1(work_id) id2(home_id)
estimates store reg_6
timer off 6

* 7: An estimate of the same constant-elasticity specification that uses the ppmlhdfe
timer on 7
qui ppmlhdfe flows logdist1, absorb(work_id home_id)
estimates store reg_7
timer off 7

* An estimate of the constant-elasticity specification that uses the ppmlhdfe no zeros
timer on 8
qui ppmlhdfe flows logdist1 if flows != 0, absorb(work_id home_id)
estimates store reg_8
timer off 8


esttab reg_1 reg_2 reg_3 reg_4 reg_5 reg_6 reg_7 reg_8 ///
	using table3.tex, ///
	replace ///
	keep(logdist1) se ar2 label ///
	title(Loglinear Gravity Estimation: Tests on 0) ///
	nonumbers mtitles("no zeros" "no zeros, +1" "+1" "+0.01" "10^(-12)" "poi2_hdfe" "ppmlhdfe" "ppmlhdfe no zeros")

timer list


** Residuals **

qui reg logflows logdist1 i.work_id i.home_id
estat hettest
rvfplot, yline(0)


** Robust timing **
timer on 9
reghdfe logflows logdist1, absorb(work_id home_id) vce(robust)
timer off 9



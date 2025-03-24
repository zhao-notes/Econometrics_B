/*---
title: Econometrics Project.do file
date: 8 March 2025
---*/
*------------Industrial & Services.csv-----------
clear all
cd "/Users/mac/Desktop/project"
import delimited using "Industrial & Services.csv", clear

cap log close
log using econemetrics.log, replace

* 1. Data Cleaning *
rename dirdiversityscore DI
rename dirinclusionscore IN
rename employeesprdprdavgfy Labour
rename executivemembersgenderdiversityp EGDI
rename executivesculturaldiversityscore ECDI
rename boardculturaldiversitypercent BCDI
rename boardgenderdiversitypercentscore BGDI
rename traininghourstotal TRtotal

* ⁠Generate interaction terms
gen BDI_G = BGDI * DI
gen BDI_C = BCDI * DI
gen EDI_G = EGDI * DI
gen EDI_C = ECDI * DI

* ⁠Sort the data by identifier and year
sort identifier year 

* ⁠Generate log-transformed variables
ds, not(type string int)
local all_vars `r(varlist)' 

foreach var of local all_vars {
   gen ln_`var' = ln(`var' + 1)  // Add 1 to avoid log(0)
}

* ⁠Estimate Cobb-Douglas production function to compute TFP
regress ln_ebitda ln_totalcapital ln_Labour
gen ln_TFP = ln_ebitda - _b[ln_totalcapital] * ln_totalcapital - _b[ln_Labour] * ln_Labour

* ⁠Panel Data Specification
encode identifier, gen(numeric_identifier)
xtset numeric_identifier year

* Generate lagged TFP
gen TFP = exp(ln_TFP)
gen TFP_lag1 = L.TFP
gen ln_TFP_lag1 = ln(TFP_lag1)

* ⁠Describe the panel structure
xtdes
summarize(year ebitda totalcapital Labour DI IN BCDI BGDI EGDI ECDI TRtotal)

* 2. Assumptions *
* ⁠Step 1: Visual inspection - sample plotting
twoway scatter ln_TFP ln_TFP_lag1, title("Scatter Plot of ln_TFP and Lagged ln_TFP")

* Step 2: Correlation analysis
corr ln_TFP ln_TFP_lag1

* Step 3: Test for autocorrelation
xtserial ln_TFP

* 3. Model Building *

* 1. Static Model (Fixed Effects)
xtreg ln_TFP ln_TFP_lag1 ln_DI ln_IN ln_BGDI ln_BCDI ln_EGDI ln_ECDI ln_TRtotal, fe
estimates store static

* ⁠2. Dynamic Panel Data Model - Arellano-Bond Estimator
xtreg ln_TFP ln_TFP_lag1, fe
xtreg ln_DI ln_TFP_lag1, fe
xtreg ln_IN ln_TFP_lag1, fe
xtreg ln_BDI_G ln_TFP_lag1, fe
xtreg ln_BDI_C ln_TFP_lag1, fe
xtreg ln_EDI_G ln_TFP_lag1, fe
xtreg ln_EDI_C ln_TFP_lag1, fe
xtreg ln_TRtotal ln_TFP_lag1, fe

xtabond2 ln_TFP ln_TFP_lag1 ln_DI ln_IN ln_BDI_G ln_BDI_C ln_EDI_G ln_EDI_C ln_TRtotal, ///
  gmm(ln_TFP_lag1, lag(2 4) collapse) ///
  gmm(ln_DI ln_IN ln_BDI_G ln_EDI_G, lag(2 3) collapse) ///
  ivstyle(ln_TRtotal) /// 
  twostep robust ///
  h(2) artests(2)
estimates store dynamic
  
  
* ⁠Compare results of the two models
hausman dynamic static

* Check the validity of instruments
* estat sargan

* Check for multicollinearity
* collin ln_DI ln_IN ln_BDI_G ln_BDI_C ln_EDI_G ln_EDI_C ln_TRtotal

  
*------------Technology & Consumer Goods.csv-------------
import delimited using "Technology & Consumer Goods.csv", clear

* 1. Data Cleaning *
rename dirdiversityscore DI
rename dirinclusionscore IN
rename employeesprdprdavgfy Labour
rename executivemembersgenderdiversityp EGDI
rename executivesculturaldiversityscore ECDI
rename boardculturaldiversitypercent BCDI
rename boardgenderdiversitypercentscore BGDI
rename traininghourstotal TRtotal

* ⁠Generate interaction terms
gen BDI_G = BGDI * DI
gen BDI_C = BCDI * DI
gen EDI_G = EGDI * DI
gen EDI_C = ECDI * DI

* ⁠Sort the data by identifier and year
sort identifier year 

* ⁠Generate log-transformed variables
ds, not(type string int)
local all_vars `r(varlist)' 

foreach var of local all_vars {
   gen ln_`var' = ln(`var' + 1)  // Add 1 to avoid log(0)
}

* ⁠Estimate Cobb-Douglas production function to compute TFP
regress ln_ebitda ln_totalcapital ln_Labour
gen ln_TFP = ln_ebitda - _b[ln_totalcapital] * ln_totalcapital - _b[ln_Labour] * ln_Labour

* ⁠Panel Data Specification
encode identifier, gen(numeric_identifier)
xtset numeric_identifier year

* Generate lagged TFP
gen TFP = exp(ln_TFP)
gen TFP_lag1 = L.TFP
gen ln_TFP_lag1 = ln(TFP_lag1)

* ⁠Describe the panel structure
xtdes
summarize(year ebitda totalcapital Labour DI IN BCDI BGDI EGDI ECDI TRtotal)

* 2. Assumptions *
* ⁠Step 1: Visual inspection - sample plotting
twoway scatter ln_TFP ln_TFP_lag1, title("Scatter Plot of ln_TFP and Lagged ln_TFP")

* Step 2: Correlation analysis
corr ln_TFP ln_TFP_lag1

* Step 3: Test for autocorrelation
xtserial ln_TFP

* 3. Model Building *

* 1. Static Model (Fixed Effects)
xtreg ln_TFP ln_TFP_lag1 ln_DI ln_IN ln_BGDI ln_BCDI ln_EGDI ln_ECDI ln_TRtotal, fe
estimates store static

* ⁠2. Dynamic Panel Data Model - Arellano-Bond Estimator
xtreg ln_TFP ln_TFP_lag1, fe
xtreg ln_DI ln_TFP_lag1, fe
xtreg ln_IN ln_TFP_lag1, fe
xtreg ln_BDI_G ln_TFP_lag1, fe
xtreg ln_BDI_C ln_TFP_lag1, fe
xtreg ln_EDI_G ln_TFP_lag1, fe
xtreg ln_EDI_C ln_TFP_lag1, fe
xtreg ln_TRtotal ln_TFP_lag1, fe

xtabond2 ln_TFP ln_TFP_lag1 ln_DI ln_IN ln_BDI_G ln_BDI_C ln_EDI_G ln_EDI_C ln_TRtotal, ///
  gmm(ln_TFP_lag1, lag(2 4) collapse) ///
  gmm(ln_DI ln_IN ln_BDI_C, lag(2 4) collapse) ///
  ivstyle(ln_TRtotal) ///
  twostep robust ///
  h(2) artests(2)
estimates store dynamic

* ⁠Compare results of the two models
hausman dynamic static

* Check the validity of instruments
* estat sargan

* Check for multicollinearity
* collin ln_DI ln_IN ln_BDI_G ln_BDI_C ln_EDI_G ln_EDI_C ln_TRtotal



*------------panel_data_1.csv-------------
import delimited using "panel_data_1.csv", clear

* 1. Data Cleaning *
rename dirdiversityscore DI
rename dirinclusionscore IN
rename employeesprdprdavgfy Labour
rename executivemembersgenderdiversityp EGDI
rename executivesculturaldiversityscore ECDI
rename boardculturaldiversitypercent BCDI
rename boardgenderdiversitypercentscore BGDI
rename traininghourstotal TRtotal

* ⁠Generate interaction terms
gen BDI_G = BGDI * DI
gen BDI_C = BCDI * DI
gen EDI_G = EGDI * DI
gen EDI_C = ECDI * DI

* ⁠Sort the data by identifier and year
sort identifier year 

* ⁠Generate log-transformed variables
ds, not(type string int)
local all_vars `r(varlist)' 

foreach var of local all_vars {
   gen ln_`var' = ln(`var' + 1)  // Add 1 to avoid log(0)
}

* ⁠Estimate Cobb-Douglas production function to compute TFP
regress ln_ebitda ln_totalcapital ln_Labour
gen ln_TFP = ln_ebitda - _b[ln_totalcapital] * ln_totalcapital - _b[ln_Labour] * ln_Labour

* ⁠Panel Data Specification
encode identifier, gen(numeric_identifier)
xtset numeric_identifier year

* Generate lagged TFP
gen TFP = exp(ln_TFP)
gen TFP_lag1 = L.TFP
gen ln_TFP_lag1 = ln(TFP_lag1)

* ⁠Describe the panel structure
xtdes
summarize(year ebitda totalcapital Labour DI IN BCDI BGDI EGDI ECDI TRtotal)

* 2. Assumptions *
* ⁠Step 1: Visual inspection - sample plotting
twoway scatter ln_TFP ln_TFP_lag1, title("Scatter Plot of ln_TFP and Lagged ln_TFP")

* Step 2: Correlation analysis
corr ln_TFP ln_TFP_lag1

* Step 3: Test for autocorrelation
xtserial ln_TFP

* 3. Model Building *

* 1. Static Model (Fixed Effects)
xtreg ln_TFP ln_TFP_lag1 ln_DI ln_IN ln_BGDI ln_BCDI ln_EGDI ln_ECDI ln_TRtotal, fe
estimates store static

* ⁠2. Dynamic Panel Data Model - Arellano-Bond Estimator
xtreg ln_TFP ln_TFP_lag1, fe
xtreg ln_DI ln_TFP_lag1, fe
xtreg ln_IN ln_TFP_lag1, fe
xtreg ln_BDI_G ln_TFP_lag1, fe
xtreg ln_BDI_C ln_TFP_lag1, fe
xtreg ln_EDI_G ln_TFP_lag1, fe
xtreg ln_EDI_C ln_TFP_lag1, fe
xtreg ln_TRtotal ln_TFP_lag1, fe
  
xtabond2 ln_TFP ln_TFP_lag1 ln_DI ln_IN ln_BDI_G ln_BDI_C ln_EDI_G ln_EDI_C ln_TRtotal, ///
  gmm(ln_TFP_lag1, lag(2 3) collapse) ///
  gmm(ln_DI ln_IN ln_BDI_G ln_BDI_C ln_EDI_G, lag(2 4) collapse) ///
  ivstyle(ln_TRtotal) ///
  twostep robust ///
  h(2) artests(2)
estimates store dynamic

* ⁠Compare results of the two models
hausman dynamic static

* Check the validity of instruments
* estat sargan

* Check for multicollinearity
* collin ln_DI ln_IN ln_BDI_G ln_BDI_C ln_EDI_G ln_EDI_C ln_TRtotal




log close





/*---
title: Econometrics Project.do file
date: 8 March 2025
---*/

clear all

**# 0. Preambles
// Set the global for file paths
global mainpath "/Users/mac/Desktop/econometrics 2/project"
global datain "$mainpath/datain"
global graph "$mainpath/graph"

// Start the log of the Stata project
cap log close
log using econometrics.log, replace

**# 1. Data Processing
**## Merging Datasets
// import and save Industrial & Services
import delimited using "$datain/Industrial & Services.csv", clear
rename identifierric identifier
save "$datain/Industrial & Services.dta", replace

// import and save Technology & Consumer Goods
import delimited using "$datain/Technology & Consumer Goods.csv", clear
rename identifierric identifier
save "$datain/Technology & Consumer Goods.dta", replace

// combine Industrial & Services and Technology & Consumer Goods
append using "$datain/Industrial & Services.dta"
save "$datain/2industry.dta", replace

// import and save panel_data_1 (full dataset)
import delimited using "$datain/panel_data_1.csv", clear
save "$datain/panel_data_1.dta", replace

// add industry group to full dataset
merge m:m identifier using "$datain/2industry.dta", keepusing(industrygroup)
tab _merge
replace industrygroup = "Other" if _merge == 1
drop _merge
save "$datain/all_firms.dta", replace

**## Generating Variables
// rename variables
rename dirdiversityscore DI
rename dirinclusionscore IN
rename employeesprdprdavgfy Labour
rename executivemembersgenderdiversityp EGDI
rename executivesculturaldiversityscore ECDI
rename boardculturaldiversitypercent BCDI
rename boardgenderdiversitypercentscore BGDI
rename traininghourstotal TRtotal

// generate interaction terms
gen BDI_G = BGDI * DI
gen BDI_C = BCDI * DI
gen EDI_G = EGDI * DI
gen EDI_C = ECDI * DI

// sort the data by identifier and year
sort identifier year 

// ⁠generate log-transformed variables
ds, not(type string int)
local all_vars `r(varlist)' 

foreach var of local all_vars {
   gen ln_`var' = ln(`var' + 1)  // Add 1 to avoid log(0)
}

// estimate Cobb-Douglas production function to compute TFP
regress ln_ebitda ln_totalcapital ln_Labour
gen ln_TFP = ln_ebitda - _b[ln_totalcapital] * ln_totalcapital - _b[ln_Labour] * ln_Labour

// panel data specification
encode identifier, gen(numeric_identifier)
xtset numeric_identifier year

// generate lagged TFP
gen TFP = exp(ln_TFP)
gen TFP_lag1 = L.TFP
gen ln_TFP_lag1 = ln(TFP_lag1)

// describe the panel structure
xtdes
summarize(year ebitda totalcapital Labour DI IN BCDI BGDI EGDI ECDI TRtotal)

**# 2. Visualisation and Assumptions
**## All Firms
// scatter plot of ln_TFP and its first lag
twoway scatter ln_TFP ln_TFP_lag1, title("ln_TFP and its first lag of all firms")
graph export "$graph/all_firms.jpg", replace

// correlation analysis
corr ln_TFP ln_TFP_lag1

// test for autocorrelation
xtserial ln_TFP

**## Industrial & Services
preserve
keep if industrygroup == "Industrial & Services"

// scatter plot of ln_TFP and its first lag
twoway scatter ln_TFP ln_TFP_lag1, title("ln_TFP and its first lag of Industrial & Services firms")
graph export "$graph/Industrial & Services.jpg", replace

// correlation analysis
corr ln_TFP ln_TFP_lag1

// test for autocorrelation
xtserial ln_TFP
restore

**## Technology & Consumer Goods
preserve
keep if industrygroup == "Technology & Consumer Goods"

// scatter plot of ln_TFP and its first lag
twoway scatter ln_TFP ln_TFP_lag1, title("ln_TFP and its first lag of Technology & Consumer Goods firms")
graph export "$graph/Technology & Consumer Goods.jpg", replace

// correlation analysis
corr ln_TFP ln_TFP_lag1

// test for autocorrelation
xtserial ln_TFP
restore

**# 3. Regression Models
**## All Firms
**### Static Model (Fixed Effects)
xtreg ln_TFP ln_TFP_lag1 ln_DI ln_IN ln_BGDI ln_BCDI ln_EGDI ln_ECDI ln_TRtotal, fe
estimates store static

**### Dynamic Panel Data Model - Arellano-Bond Estimator
// checking reverse causality
xtreg ln_TFP ln_TFP_lag1, fe
xtreg ln_DI ln_TFP_lag1, fe
xtreg ln_IN ln_TFP_lag1, fe
xtreg ln_BDI_G ln_TFP_lag1, fe
xtreg ln_BDI_C ln_TFP_lag1, fe
xtreg ln_EDI_G ln_TFP_lag1, fe
xtreg ln_EDI_C ln_TFP_lag1, fe
xtreg ln_TRtotal ln_TFP_lag1, fe

// Arellano-Bond Estimator
xtabond2 ln_TFP ln_TFP_lag1 ln_DI ln_IN ln_BDI_G ln_BDI_C ln_EDI_G ln_EDI_C ln_TRtotal, ///
    gmm(ln_TFP_lag1, lag(2 3) collapse) ///
	gmm(ln_DI ln_IN ln_BDI_G ln_BDI_C ln_EDI_G, lag(2 4) collapse) ///
    ivstyle(ln_TRtotal) ///
    twostep robust ///
    h(2) artests(2)
estimates store dynamic

// ⁠Compare results of the two models
hausman dynamic static

// Check the validity of instruments
// estat sargan

// Check for multicollinearity
// collin ln_DI ln_IN ln_BDI_G ln_BDI_C ln_EDI_G ln_EDI_C ln_TRtotal


**## Industrial & Services
preserve
keep if industrygroup == "Industrial & Services"

**### Static Model (Fixed Effects)
xtreg ln_TFP ln_TFP_lag1 ln_DI ln_IN ln_BGDI ln_BCDI ln_EGDI ln_ECDI ln_TRtotal, fe
estimates store static

**### Dynamic Panel Data Model - Arellano-Bond Estimator
// checking reverse causality
xtreg ln_TFP ln_TFP_lag1, fe
xtreg ln_DI ln_TFP_lag1, fe
xtreg ln_IN ln_TFP_lag1, fe
xtreg ln_BDI_G ln_TFP_lag1, fe
xtreg ln_BDI_C ln_TFP_lag1, fe
xtreg ln_EDI_G ln_TFP_lag1, fe
xtreg ln_EDI_C ln_TFP_lag1, fe
xtreg ln_TRtotal ln_TFP_lag1, fe

// Arellano-Bond Estimator
xtabond2 ln_TFP ln_TFP_lag1 ln_DI ln_IN ln_BDI_G ln_BDI_C ln_EDI_G ln_EDI_C ln_TRtotal, ///
    gmm(ln_TFP_lag1, lag(2 4) collapse) ///
    gmm(ln_DI ln_IN ln_BDI_G ln_EDI_G, lag(2 3) collapse) ///
    ivstyle(ln_TRtotal) /// 
    twostep robust ///
    h(2) artests(2)
estimates store dynamic
  
// ⁠Compare results of the two models
hausman dynamic static

// Check the validity of instruments
// estat sargan

// Check for multicollinearity
// collin ln_DI ln_IN ln_BDI_G ln_BDI_C ln_EDI_G ln_EDI_C ln_TRtotal

restore

**## Technology & Consumer Goods
preserve
keep if industrygroup == "Technology & Consumer Goods"

**### Static Model (Fixed Effects)
xtreg ln_TFP ln_TFP_lag1 ln_DI ln_IN ln_BGDI ln_BCDI ln_EGDI ln_ECDI ln_TRtotal, fe
estimates store static

**### Dynamic Panel Data Model - Arellano-Bond Estimator
// checking reverse causality
xtreg ln_TFP ln_TFP_lag1, fe
xtreg ln_DI ln_TFP_lag1, fe
xtreg ln_IN ln_TFP_lag1, fe
xtreg ln_BDI_G ln_TFP_lag1, fe
xtreg ln_BDI_C ln_TFP_lag1, fe
xtreg ln_EDI_G ln_TFP_lag1, fe
xtreg ln_EDI_C ln_TFP_lag1, fe
xtreg ln_TRtotal ln_TFP_lag1, fe

// Arellano-Bond Estimator
xtabond2 ln_TFP ln_TFP_lag1 ln_DI ln_IN ln_BDI_G ln_BDI_C ln_EDI_G ln_EDI_C ln_TRtotal, ///
    gmm(ln_TFP_lag1, lag(2 4) collapse) ///
    gmm(ln_DI ln_IN ln_BDI_C, lag(2 4) collapse) ///
    ivstyle(ln_TRtotal) ///
    twostep robust ///
    h(2) artests(2)
estimates store dynamic
  
// ⁠Compare results of the two models
hausman dynamic static

// Check the validity of instruments
// estat sargan

// Check for multicollinearity
// collin ln_DI ln_IN ln_BDI_G ln_BDI_C ln_EDI_G ln_EDI_C ln_TRtotal

restore


log close





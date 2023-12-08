* Do-File for Empirical Project 2
* Author: Helen (Yingying) Huang
* Date: 11/19/2023
* Purpose: This do-file conducts a regression discontinuity analysis to assess the impact of class size on school performance. It generates visualizations and regression outputs for the analysis, using the 'binscatter' package for graphical representation.
* Dataset: grade5.dta
* Stata Version: 17
version 17

* Change directory to 'project2'
cd "../project2"

* Set relative paths for the data and log files
local datapath "./"
local dataset "grade5.dta"
global log "empiricalproject2_helen.log"

* Start log file to record session
log using "`datapath'`logfile'", replace

* Check if 'binscatter' package is installed and install if not present
cap which binscatter
if _rc ssc install binscatter, replace version(1.0)

* Load the dataset
use "`datapath'`dataset'", clear

* Error checking after loading data to ensure the file exists and is not empty
if _rc {
    di "Error: Dataset could not be loaded. Please check the file path."
    exit 1
}

* Question 4: Graphical Regression Discontinuity Analysis
* -----------------------------------

* a. Assess the linear relationship between school enrollment and class size
binscatter classize school_enrollment if inrange(school_enrollment,20,60), rd(40.5) discrete line(lfit)
graph export "`datapath'figures_helen/figure1linear.png", replace

* b. Explore quadratic relationships between school enrollment and performance scores
binscatter avgmath school_enrollment if inrange(school_enrollment,20,60), rd(40.5) discrete line(qfit)
graph export "`datapath'figures_helen/figure2quadratic.png", replace

binscatter avgverb school_enrollment if inrange(school_enrollment,20,60), rd(40.5) discrete line(qfit)
graph export "`datapath'figures_helen/figure3quadratic.png", replace

* c. Investigate how other school characteristics relate to enrollment
binscatter disadvantaged  school_enrollment if inrange(school_enrollment,20,60), rd(40.5) discrete line(qfit)
graph export "`datapath'figures_helen/figure4quadratic.png", replace

binscatter religious  school_enrollment if inrange(school_enrollment,20,60), rd(40.5) discrete line(qfit)
graph export "`datapath'figures_helen/figure5quadratic.png", replace

binscatter female school_enrollment if inrange(school_enrollment,20,60), rd(40.5) discrete line(qfit)
graph export "`datapath'figures_helen/figure6quadratic.png", replace

* d. Distribution of school enrollment - Histogram
collapse (mean) school_enrollment, by(schlcode)
twoway (histogram school_enrollment if inrange(school_enrollment,20,60), discrete frequency), xline(40.5)
graph export "`datapath'figures_helen/figure7schoolcounts.png", replace

* Question 5: Regression Analysis
* -----------------------------------

* Re-load the full dataset for regression analysis
use "`datapath'`dataset'", clear

*Generate new variables for regression discontinuity design
* 'above40' indicates whether the enrollment is above the cutoff of 40
* 'x' is the running variable - the distance from the cutoff
* 'x_above40' is an interaction term to allow for slope change at the cutoff
gen above40 = 0
replace above40 = 1 if school_enrollment > 40
gen x = school_enrollment - 40
gen x_above40 = x*above40

*Run regression 
reg classize above40 x x_above40 if inrange(school_enrollment,0,80), cluster(schlcode)
reg avgmath above40 x x_above40 if inrange(school_enrollment,0,80), cluster(schlcode)
reg avgverb above40 x x_above40 if inrange(school_enrollment,0,80), cluster(schlcode)

* Cleanup and close
* -----------------------------------

log close
clear all

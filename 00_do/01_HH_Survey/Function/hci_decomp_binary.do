/****************************************************************************************
Program file:   hci_decomp_binary.do

Main program:   hci_decomp_binary

Purpose
-------
This program performs concentration index (CI) decomposition for a binary outcome
using a multivariate unfair ranking.

It is designed for outcomes such as:
    - ANC use
    - institutional delivery
    - postnatal care
    - newborn care
or any other binary 0/1 health outcome.

The program:
    1. Fits an initial regression model with all unfair variables
    2. Detects and removes omitted / collinear unfair variables
    3. Fits the final model using retained unfair variables
    4. Predicts fitted probabilities from the final model
    5. Converts fitted probabilities into a weighted fractional unfair rank
    6. Calculates the concentration index of the outcome
    7. Calculates marginal effects, elasticities, determinant-specific CI,
       contributions, and residual
    8. Produces both:
         a) formal signed decomposition outputs
         b) VERSE-style absolute normalized percentage outputs for display / plots


Available options
-----------------
Required:
    unfair(varlist)     : unfair determinant variables
    wvar(varname)       : weight variable

Optional:
    model(probit|logit)
        default = probit

    ocitype(relative|wagstaff|erreygers)
        default = relative

Meaning of ocitype()
--------------------
1. relative
   Standard relative concentration index:
       CI = 2 * Cov(y, rank) / mean(y)

2. wagstaff
   Wagstaff-normalized CI for bounded / binary outcomes:
       CI_w = CI / (1 - mean(y))

3. erreygers
   Erreygers-corrected CI:
       CI_E = CI * [4 * mean(y) / (max(y) - min(y))]

Important implementation note
-----------------------------
In this program:
- the selected CI type is applied to the OUTCOME CI
- the determinant-specific CI is kept as the standard relative CI

This keeps the workflow close to the standard decomposition framework while allowing
bounded-outcome correction for the outcome inequality measure.


Decomposition formulas
----------------------
Let:
    y       = binary outcome
    x_k     = unfair determinant k
    mu_y    = mean of outcome
    mu_xk   = mean of determinant x_k
    ME_k    = marginal effect of determinant x_k from final regression
    CI_k    = relative concentration index of determinant x_k
    CI_y    = concentration index of outcome under selected ocitype()

Elasticity:
    elasticity_k = (ME_k * mu_xk) / mu_y

Relative-scale contribution:
    contribution_rel_k = elasticity_k * CI_k

Outcome-scale contribution:
    contribution_k = contribution_rel_k * scale_y

where scale_y is:
    1                            if ocitype(relative)
    1 / (1 - mu_y)               if ocitype(wagstaff)
    4 * mu_y / (max(y)-min(y))   if ocitype(erreygers)

Signed percentage contribution:
    contribution_pct_k = 100 * contribution_k / CI_y

Residual:
    residual = CI_y - sum(contribution_k)

Signed residual percentage:
    residual_pct = 100 - sum(contribution_pct_k)


VERSE-style display outputs
---------------------------
To address cases where signed contributions sum to more than 100% in absolute terms,
the program also creates display variables following the VERSE-style logic:

    contribution_abs     = abs(contribution)
    contribution_pct_abs = 100 * abs(contribution / CI_y)

Residual display percentage:
    residual_pct_abs = 100 * abs(residual / CI_y)

Then all absolute percentages (including the residual row) are normalized to 100
if their sum exceeds 100:

    contribution_pct_abs_norm = contribution_pct_abs / total_abs_pct * 100

Interpretation guide
--------------------
Formal signed outputs:
    - contribution
    - contribution_pct
    - residual_contribution
    - residual_pct

These preserve direction (+ / -) and should be used for formal decomposition reporting.

VERSE-style display outputs:
    - contribution_abs
    - contribution_pct_abs
    - contribution_pct_abs_norm

These are useful for figures such as donut charts or simplified tables where the
goal is to show relative magnitude rather than signed direction.

Recommended use
---------------
For manuscript table:
    Use signed contribution + optionally absolute normalized percentage

For figure / donut plot:
    Use normalized absolute percentage

Requirements
------------
- Data must already be svyset if survey design is intended
- Outcome must be coded 0/1
- Unfair variables must be numeric
- Weight variable must be numeric

Example use
-----------
    global X_raw NationalScore_m0 logincome ///
                 wempo_index_m0 ///
                 hfc_distance_1 hfc_distance_2 hfc_distance_3 ///
                 stratum_1 ///
                 resp_highedu_2 resp_highedu_3 resp_highedu_4

    hci_decomp_binary anc_yn, ///
        unfair($X_raw) ///
        wvar(weight_var) ///
        model(probit) ///
        ocitype(relative)

    hci_decomp_binary anc_yn, ///
        unfair($X_raw) ///
        wvar(weight_var) ///
        model(probit) ///
        ocitype(wagstaff)

****************************************************************************************/


capture program drop _hci_wrank
program define _hci_wrank, sortpreserve
    version 17
    syntax varlist(min=2 max=2 numeric) [if] [in], Generate(name)

    marksample touse
    tokenize `varlist'
    local ineqvar `1'
    local wvar    `2'

    tempvar id cw tw
    gen long `id' = _n

    sort `touse' `ineqvar' `id'
    quietly gen double `cw' = sum(cond(`touse', `wvar', 0))
    quietly egen double `tw' = total(cond(`touse', `wvar', .))

    gen double `generate' = (`cw' - 0.5*`wvar') / `tw' if `touse'
    label var `generate' "Weighted fractional rank"
    sort `id'
end


capture program drop _hci_ci
program define _hci_ci, rclass
    version 17
    syntax varname(numeric) [if] [in], Rank(varname numeric) Wvar(varname numeric) ///
        [TYPE(string)]

    marksample touse
    if "`type'" == "" local type "relative"

    quietly summarize `varlist' [aw=`wvar'] if `touse', meanonly
    scalar __mu = r(mean)

    quietly summarize `varlist' if `touse', meanonly
    scalar __max = r(max)
    scalar __min = r(min)

    quietly corr `rank' `varlist' [aw=`wvar'] if `touse', covariance
    scalar __cov = r(cov_12)

    scalar __ci_rel = 2 * __cov / __mu

    scalar __scale = 1
    if "`type'" == "relative" {
        scalar __scale = 1
    }
    else if "`type'" == "wagstaff" {
        scalar __scale = 1 / (1 - __mu)
    }
    else if "`type'" == "erreygers" {
        scalar __scale = 4 * __mu / (__max - __min)
    }
    else {
        di as error "ocitype() must be relative, wagstaff, or erreygers"
        exit 198
    }

    scalar __ci = __ci_rel * __scale

    return scalar mu      = __mu
    return scalar min     = __min
    return scalar max     = __max
    return scalar cov     = __cov
    return scalar ci_rel  = __ci_rel
    return scalar scale   = __scale
    return scalar ci      = __ci
end


capture program drop hci_decomp_binary
program define hci_decomp_binary, rclass
    version 17
    syntax varname(numeric) [if] [in], ///
        Unfair(varlist numeric) ///
        Wvar(varname numeric) ///
        [MODEL(string) OCIType(string)]

    marksample touse
    if "`model'" == ""   local model   "probit"
    if "`ocitype'" == "" local ocitype "relative"

    preserve
        keep if `touse'
        quietly count
        if r(N) == 0 {
            di as error "No observations in estimation sample."
            exit 2000
        }

        tempvar esample phat rank
        local outcome `varlist'

        *-------------------------------------------------------------
        * 1. Initial model to detect omitted / collinear unfair terms
        *-------------------------------------------------------------
        if "`model'" == "logit" {
            quietly svy: logit `outcome' `unfair'
        }
        else if "`model'" == "probit" {
            quietly svy: probit `outcome' `unfair'
        }
        else {
            di as error "model() must be probit or logit"
            exit 198
        }

        matrix b = e(b)
        local terms : colnames b

        local X_keep
        foreach term of local terms {
            if "`term'" == "_cons" continue

            capture noisily _ms_parse_parts `term'
            if !_rc {
                if r(omit) == 1 continue
                if r(base) == 1 continue
            }

            local X_keep `X_keep' `term'
        }

        local X_drop
        foreach x of local unfair {
            local found = 0
            foreach k of local X_keep {
                if "`x'" == "`k'" local found = 1
            }
            if `found' == 0 local X_drop `X_drop' `x'
        }

        if "`X_keep'" == "" {
            di as error "No estimable unfair variables remained after omission checks."
            exit 498
        }

        *---------------------------------------
        * 2. Final model with retained variables
        *---------------------------------------
        if "`model'" == "logit" {
            quietly svy: logit `outcome' `X_keep'
            quietly predict double `phat' if e(sample), pr
        }
        else {
            quietly svy: probit `outcome' `X_keep'
            quietly predict double `phat' if e(sample), pr
        }

        gen byte `esample' = e(sample)

        *----------------------------------------------
        * 3. Build unfair weighted fractional rank
        *----------------------------------------------
        quietly _hci_wrank `phat' `wvar' if `esample', generate(`rank')

        *----------------------------------------------
        * 4. Outcome CI under relative and chosen type
        *----------------------------------------------
        quietly _hci_ci `outcome' if `esample', rank(`rank') wvar(`wvar') type(relative)
        scalar mu_y    = r(mu)
        scalar CIy_rel = r(ci_rel)

        quietly _hci_ci `outcome' if `esample', rank(`rank') wvar(`wvar') type(`ocitype')
        scalar CIy     = r(ci)
        scalar scale_y = r(scale)

        *----------------------------------------------
        * 5. Marginal effects from final model
        *----------------------------------------------
        quietly margins, dydx(`X_keep') post
        matrix ME = e(b)

        *----------------------------------------------
        * 6. Prepare results container
        *----------------------------------------------
        tempfile results
        tempname posth

        postfile `posth' ///
            str80 varname ///
            double mean_x ///
            double me ///
            double elasticity ///
            double var_ci_rel ///
            double contribution_rel ///
            double contribution ///
            double contribution_pct ///
            using `results', replace

        scalar contrib_rel_tot = 0
        scalar contrib_tot     = 0

        *----------------------------------------------
        * 7. Loop over retained unfair determinants
        *----------------------------------------------
        foreach x of local X_keep {

            local c = colnumb(ME, "`x'")
            if missing(`c') | `c' == 0 continue

            scalar me_x = el(ME, 1, `c')

            quietly summarize `x' [aw=`wvar'] if `esample', meanonly
            scalar mu_x = r(mean)

            * Elasticity:
            * elasticity_k = (ME_k * mean_xk) / mean_y
            scalar elas_x = (me_x * mu_x) / mu_y

            * Relative CI of determinant:
            * CI_k = 2 * Cov(x_k, rank) / mean_xk
            quietly _hci_ci `x' if `esample', rank(`rank') wvar(`wvar') type(relative)
            scalar CIx_rel = r(ci_rel)

            * Relative contribution:
            * contribution_rel_k = elasticity_k * CI_k
            scalar con_rel = elas_x * CIx_rel

            * Outcome-scale contribution:
            * contribution_k = contribution_rel_k * scale_y
            scalar con_adj = con_rel * scale_y

            * Signed percentage contribution:
            * contribution_pct_k = 100 * contribution_k / outcome_ci
            scalar pct_adj = 100 * con_adj / CIy

            scalar contrib_rel_tot = contrib_rel_tot + con_rel
            scalar contrib_tot     = contrib_tot + con_adj

            post `posth' ///
                ("`x'") ///
                (mu_x) ///
                (me_x) ///
                (elas_x) ///
                (CIx_rel) ///
                (con_rel) ///
                (con_adj) ///
                (pct_adj)
        }

        postclose `posth'
        use `results', clear

        *----------------------------------------------
        * 8. Formal signed residual
        *----------------------------------------------
        scalar residual_rel = CIy_rel - contrib_rel_tot
        scalar residual     = CIy - contrib_tot

        egen double contribution_pct_tot = total(contribution_pct)

        gen double outcome_mean              = mu_y
        gen double outcome_ci_rel            = CIy_rel
        gen double outcome_ci                = CIy
        gen double total_contribution_rel    = contrib_rel_tot
        gen double total_contribution        = contrib_tot
        gen double residual_contribution_rel = residual_rel
        gen double residual_contribution     = residual
        gen double residual_pct              = 100 - contribution_pct_tot

        *----------------------------------------------
        * 9. VERSE-style absolute display columns
        *----------------------------------------------
        gen double contribution_abs     = abs(contribution)
        gen double contribution_pct_abs = 100 * abs(contribution / outcome_ci)

        *----------------------------------------------
        * 10. Append residual row
        *----------------------------------------------
        set obs `=_N+1'
        replace varname = "Residual" in L

        replace contribution_rel            = residual_rel in L
        replace contribution                = residual in L
        replace contribution_pct            = 100 - contribution_pct_tot[1] in L

        replace contribution_abs            = abs(residual) in L
        replace contribution_pct_abs        = 100 * abs(residual / CIy) in L

        replace outcome_mean                = mu_y in L
        replace outcome_ci_rel              = CIy_rel in L
        replace outcome_ci                  = CIy in L
        replace total_contribution_rel      = contrib_rel_tot in L
        replace total_contribution          = contrib_tot in L
        replace residual_contribution_rel   = residual_rel in L
        replace residual_contribution       = residual in L
        replace residual_pct                = 100 - contribution_pct_tot[1] in L

        *----------------------------------------------
        * 11. Replace display missing values with zero
        *----------------------------------------------
        replace contribution_abs     = 0 if missing(contribution_abs)
        replace contribution_pct_abs = 0 if missing(contribution_pct_abs)

        *----------------------------------------------
        * 12. Normalize absolute percentages if total > 100
        *----------------------------------------------
        egen double contribution_pct_abs_tot = total(contribution_pct_abs)
        gen double contribution_pct_abs_norm = contribution_pct_abs

        quietly summarize contribution_pct_abs, meanonly
        if r(sum) > 100 {
            replace contribution_pct_abs_norm = contribution_pct_abs / r(sum) * 100
        }

        *----------------------------------------------
        * 13. Labels
        *----------------------------------------------
        label var varname                     "Unfair factor"
        label var mean_x                      "Mean of unfair factor"
        label var me                          "Marginal effect"
        label var elasticity                  "Elasticity"
        label var var_ci_rel                  "CI of unfair factor (relative)"
        label var contribution_rel            "Contribution (relative CI scale)"
        label var contribution                "Contribution (selected CI scale, signed)"
        label var contribution_pct            "Percentage contribution (signed)"
        label var contribution_abs            "Absolute contribution"
        label var contribution_pct_abs        "Absolute % contribution"
        label var contribution_pct_abs_tot    "Total absolute % contribution"
        label var contribution_pct_abs_norm   "Normalized absolute % contribution"
        label var outcome_mean                "Outcome mean"
        label var outcome_ci_rel              "Outcome CI (relative)"
        label var outcome_ci                  "Outcome CI (selected type)"
        label var total_contribution_rel      "Total contribution (relative)"
        label var total_contribution          "Total contribution (selected)"
        label var residual_contribution_rel   "Residual (relative)"
        label var residual_contribution       "Residual (selected)"
        label var residual_pct                "Residual percentage (signed)"

        order varname mean_x me elasticity var_ci_rel ///
              contribution_rel contribution contribution_pct ///
              contribution_abs contribution_pct_abs contribution_pct_abs_norm ///
              outcome_mean outcome_ci_rel outcome_ci ///
              total_contribution_rel total_contribution ///
              residual_contribution_rel residual_contribution residual_pct

        *----------------------------------------------
        * 14. Return useful results
        *----------------------------------------------
        return local outcome         "`outcome'"
        return local x_keep          "`X_keep'"
        return local x_drop          "`X_drop'"
        return scalar outcome_mu     = mu_y
        return scalar outcome_ci     = CIy
        return scalar outcome_ci_rel = CIy_rel
        return scalar total_contribution = contrib_tot
        return scalar residual       = residual

        tempfile outtemp
        save `outtemp', replace
    restore

    use `outtemp', clear
end
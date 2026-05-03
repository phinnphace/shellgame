# shellgame 0.1.0

## Initial release

* `audit_transformation()` — main function to audit a full ZCTA → ZIP → County
  transformation pipeline and quantify perturbation.
* `transform_zcta_to_zip()` — performs the first hop (ZCTA → ZIP) using
  equal-weight allocation across associated ZIPs.
* `transform_zip_to_county()` — performs the second hop (ZIP → County) using
  HUD TOT_RATIO allocation.
* `run_full_transformation()` — convenience wrapper executing both hops in sequence.
* `prep_zip_zcta()` — standardizes raw ZIP-ZCTA crosswalk files for use in audits.
* `prep_hud_crosswalk()` — standardizes raw HUD ZIP-County crosswalk files.
* `get_zcta_baseline()` — fetches ACS 5-year estimates at ZCTA level via the
  Census API (requires tidycensus and a Census API key).
* `extract_perturbed_population()` — extracts the redistribution of population
  across receiving counties produced by the transformation.
* `plot_transformation_perturbation()` — bar chart of baseline vs recovered
  values with perturbation magnitude in subtitle.
* `create_audit_report()` — generates all visualizations for an audit.
* S3 `print` and `summary` methods for `shellgame_audit` objects.
* Vignettes: Hennepin County worked example, data preparation guide,
  conceptual framework.

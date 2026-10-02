# Matched recovered coupled control: same seed history, predictor and dt as stages A-C.
[Debug]
  show_var_residual_norms = true
[]
[Executioner]
  end_time = 0.023875
  dtmin = 0.008
  nl_max_its = 50
[]
[Outputs]
  exodus = false
  csv = true
  file_base = /tmp/x65_diag_recovered_coupled
[]

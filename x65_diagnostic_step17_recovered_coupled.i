# Matched recovered coupled control: same seed history, predictor and dt as stages A-C.
[Debug]
  show_var_residual_norms = true
[]
[Executioner]
  end_time = 0.027125
  dtmin = 0.00025
  nl_max_its = 15
  petsc_options = '-snes_linesearch_monitor'
[]
[Outputs]
  exodus = false
  csv = true
  file_base = /tmp/x65_diag_step17_coupled
[]

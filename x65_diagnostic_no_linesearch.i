# Matched recovered coupled control: same seed history, predictor and dt as stages A-C.
[Debug]
  show_var_residual_norms = true
[]
[Executioner]
  end_time = 0.023875
  dtmin = 0.008
  nl_max_its = 50
  line_search = none
[]
[Outputs]
  exodus = false
  csv = true
  file_base = /tmp/x65_diag_no_linesearch
[]
[Postprocessors]
  [diag_C_nodal_min]
    type = NodalExtremeValue
    variable = C_L
    value_type = min
    execute_on = 'INITIAL NONLINEAR TIMESTEP_END'
  []
  [diag_C_nodal_max]
    type = NodalExtremeValue
    variable = C_L
    value_type = max
    execute_on = 'INITIAL NONLINEAR TIMESTEP_END'
  []
[]
[Outputs]
  [iteration_csv]
    type = CSV
    file_base = /tmp/x65_diag_no_linesearch_iterations
    execute_on = 'INITIAL NONLINEAR TIMESTEP_END'
  []
[]

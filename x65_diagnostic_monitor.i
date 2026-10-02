# Diagnostic overlay; original physical parameters and accepted-state history retained.
[Debug]
  show_var_residual_norms = true
[]
[Executioner]
  end_time = 0.027125
  dtmin = 0.000125
  nl_max_its = 15
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
  [diag_C_qp_min]
    type = ElementExtremeValue
    variable = C_L
    value_type = min
    execute_on = 'INITIAL NONLINEAR TIMESTEP_END'
  []
  [diag_C_qp_max]
    type = ElementExtremeValue
    variable = C_L
    value_type = max
    execute_on = 'INITIAL NONLINEAR TIMESTEP_END'
  []
[]
[Outputs]
  exodus = false
  csv = true
  file_base = /tmp/x65_diag_base
  [iteration_csv]
    type = CSV
    file_base = /tmp/x65_diag_iterations
    execute_on = 'INITIAL NONLINEAR TIMESTEP_END'
  []
  [history_checkpoint]
    type = Checkpoint
    file_base = /tmp/x65_diag_history
    time_step_interval = 1
    num_files = 2
    execute_on = TIMESTEP_END
  []
[]

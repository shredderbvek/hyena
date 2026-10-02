# Stage C: advance hydrogen with new mechanics and projected stress fixed.
# Recover the original checkpoint, preserving the old history for storage and plastic strain rate.
[Debug]
  show_var_residual_norms = true
[]
[Executioner]
  end_time = 0.027125
  dtmin = 0.00025
  nl_max_its = 50
[]
[UserObjects]
  [target_fields]
    type = SolutionUserObject
    mesh = /tmp/x65_diag_step17_projection.e
    system_variables = 'disp_x disp_y disp_z hydrostatic_stress'
    nodal_variable_order = SECOND
    timestep = LATEST
  []
[]
[Functions]
  [target_sigma]
    type = SolutionFunction
    solution = target_fields
    from_variable = hydrostatic_stress
  []
  [target_disp_x]
    type = SolutionFunction
    solution = target_fields
    from_variable = disp_x
  []
  [target_disp_y]
    type = SolutionFunction
    solution = target_fields
    from_variable = disp_y
  []
  [target_disp_z]
    type = SolutionFunction
    solution = target_fields
    from_variable = disp_z
  []
[]
[Kernels]
  inactive = hydrostatic_stress_projection
  [diag_sigma_coverage]
    type = Reaction
    variable = hydrostatic_stress
  []
[]
[BCs]
  inactive = 'fix_x fix_y fix_z pull'
  [diag_hold_sigma]
    type = FunctionDirichletBC
    variable = hydrostatic_stress
    boundary = RVE
    function = target_sigma
  []
  [diag_hold_disp_x]
    type = FunctionDirichletBC
    variable = disp_x
    boundary = RVE
    function = target_disp_x
  []
  [diag_hold_disp_y]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = RVE
    function = target_disp_y
  []
  [diag_hold_disp_z]
    type = FunctionDirichletBC
    variable = disp_z
    boundary = RVE
    function = target_disp_z
  []
[]
[Outputs]
  exodus = true
  csv = true
  file_base = /tmp/x65_diag_step17_hydrogen
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
    file_base = /tmp/x65_diag_step17_hydrogen_iterations
    execute_on = 'INITIAL NONLINEAR TIMESTEP_END'
  []
[]

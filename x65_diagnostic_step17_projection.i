# Stage B: recompute mechanics from the original committed history at fixed stage-A displacement,
# then solve the hydrostatic stress projection with old hydrogen held fixed.
[Debug]
  show_var_residual_norms = true
[]
[Executioner]
  end_time = 0.027125
  dtmin = 0.00025
  nl_max_its = 50
[]
[UserObjects]
  [seed_fields]
    type = SolutionUserObject
    mesh = /tmp/x65_diag_seed16_fields.e
    system_variables = C_L
    nodal_variable_order = SECOND
    timestep = LATEST
  []
  [target_fields]
    type = SolutionUserObject
    mesh = /tmp/x65_diag_step17_mechanics.e
    system_variables = 'disp_x disp_y disp_z'
    nodal_variable_order = SECOND
    timestep = LATEST
  []
[]
[Functions]
  [seed_C]
    type = SolutionFunction
    solution = seed_fields
    from_variable = C_L
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
  inactive = 'hydrogen_storage fick_ferrite fick_pearlite dislocation_trap_evolution stress_assisted_ferrite stress_assisted_pearlite'
  [diag_C_coverage]
    type = Reaction
    variable = C_L
  []
[]
[BCs]
  inactive = 'fix_x fix_y fix_z pull hydrogen_charge hydrogen_sink'
  [diag_hold_C]
    type = FunctionDirichletBC
    variable = C_L
    boundary = RVE
    function = seed_C
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
  file_base = /tmp/x65_diag_step17_projection
[]

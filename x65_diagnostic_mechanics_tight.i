# Stage A: solve mechanics at t=0.023875 from the committed t=0.015875 history.
# Hold C_L and projected stress at their checkpoint values; they do not feed mechanics.
[Debug]
  show_var_residual_norms = true
[]
[Executioner]
  end_time = 0.023875
  dtmin = 0.008
  nl_max_its = 50
[]
[UserObjects]
  [seed_fields]
    type = SolutionUserObject
    mesh = /tmp/x65_diag_seed7_fields.e
    system_variables = 'C_L hydrostatic_stress'
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
  [seed_sigma]
    type = SolutionFunction
    solution = seed_fields
    from_variable = hydrostatic_stress
  []
[]
[Kernels]
  inactive = 'hydrogen_storage fick_ferrite fick_pearlite dislocation_trap_evolution hydrostatic_stress_projection stress_assisted_ferrite stress_assisted_pearlite'
  [diag_C_coverage]
    type = Reaction
    variable = C_L
  []
  [diag_sigma_coverage]
    type = Reaction
    variable = hydrostatic_stress
  []
[]
[BCs]
  inactive = 'hydrogen_charge hydrogen_sink'
  [diag_hold_C]
    type = FunctionDirichletBC
    variable = C_L
    boundary = RVE
    function = seed_C
  []
  [diag_hold_sigma]
    type = FunctionDirichletBC
    variable = hydrostatic_stress
    boundary = RVE
    function = seed_sigma
  []
[]
[Outputs]
  exodus = true
  csv = true
  file_base = /tmp/x65_diag_mechanics_tight
[]
# CP constitutive-accuracy control. Absolute stress tolerance is in Pa.
[Materials]
  [cp_stress]
    rtol = 1e-10
    abs_tol = 1e-3
  []
  [cp_update]
    resistance_tol = 1e-8
  []
[]

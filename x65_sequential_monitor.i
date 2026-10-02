[Postprocessors]
  [diag_eps_ferrite_material]
    type = ElementAverageMaterialProperty
    mat_prop = equivalent_plastic_strain
    block = '${ferrite_blocks}'
    execute_on = TIMESTEP_END
  []
  [diag_rate_ferrite_material]
    type = ElementAverageMaterialProperty
    mat_prop = equivalent_plastic_strain_rate
    block = '${ferrite_blocks}'
    execute_on = TIMESTEP_END
  []
  [diag_sigma_ferrite_material]
    type = ElementAverageMaterialProperty
    mat_prop = hydrostatic_stress
    block = '${ferrite_blocks}'
    execute_on = TIMESTEP_END
  []
  [diag_eps_pearlite_material]
    type = ElementAverageMaterialProperty
    mat_prop = equivalent_plastic_strain
    block = 'pearlite'
    execute_on = TIMESTEP_END
  []
  [diag_rate_pearlite_material]
    type = ElementAverageMaterialProperty
    mat_prop = equivalent_plastic_strain_rate
    block = 'pearlite'
    execute_on = TIMESTEP_END
  []
  [diag_sigma_pearlite_material]
    type = ElementAverageMaterialProperty
    mat_prop = hydrostatic_stress
    block = 'pearlite'
    execute_on = TIMESTEP_END
  []
[]

# Diagnostics for the ordered production solve; no physical parameter overrides.
[Postprocessors]
  [C_L_nodal_min]
    type = NodalExtremeValue
    variable = C_L
    value_type = min
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [C_L_nodal_max]
    type = NodalExtremeValue
    variable = C_L
    value_type = max
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]
[Outputs]
  file_base = x65_sequential_results/run
  exodus = true
  print_linear_residuals = false
  [checkpoint]
    type = Checkpoint
    time_step_interval = 5
    num_files = 2
  []
[]

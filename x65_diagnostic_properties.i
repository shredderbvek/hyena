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

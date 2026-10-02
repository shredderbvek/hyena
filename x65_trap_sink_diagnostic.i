# Isolate positivity of the existing storage/trap discretization.
# Positive, nonuniform initial concentration; no diffusion or stress drift.
[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 1
  ny = 1
  nz = 1
  xmax = 1e-6
  ymax = 1e-6
  zmax = 1e-6
  elem_type = TET4
[]
[Variables]
  [C_L]
    order = FIRST
    family = LAGRANGE
  []
[]
[Functions]
  [initial_C]
    type = ParsedFunction
    expression = '1e-9 + 1e3*x'
  []
  [eps]
    type = ParsedFunction
    expression = '0.01*t'
  []
  [rate]
    type = ParsedFunction
    expression = '0.01'
  []
[]
[ICs]
  [C]
    type = FunctionIC
    variable = C_L
    function = initial_C
  []
[]
[Materials]
  [plastic_history]
    type = GenericFunctionMaterial
    prop_names = 'equivalent_plastic_strain equivalent_plastic_strain_rate'
    prop_values = 'eps rate'
  []
  [oriani]
    type = OrianiHydrogenMaterial
    lattice_concentration = C_L
    lattice_site_density = 846874.924259
    reference_trap_density = 3227.10414254
    binding_energy = -60000
    temperature = 300
  []
[]
[Kernels]
  [storage]
    type = HydrogenLumpedTimeDerivative
    variable = C_L
  []
  [trap]
    type = DislocationTrapEvolution
    variable = C_L
  []
[]
[Postprocessors]
  [minimum_C]
    type = NodalExtremeValue
    variable = C_L
    value_type = min
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [maximum_C]
    type = NodalExtremeValue
    variable = C_L
    value_type = max
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]
[Executioner]
  type = Transient
  solve_type = NEWTON
  dt = 0.001
  num_steps = 1
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-12
  automatic_scaling = true
  resid_vs_jac_scaling_param = 1
[]
[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]
[Outputs]
  csv = true
  exodus = false
  file_base = /tmp/x65_trap_sink_diagnostic
[]

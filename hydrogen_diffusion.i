# One-trap lattice diffusion without mechanics or stress assistance.
# Concentration is in mol H/m^3; D is in m^2/s.
[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 40
  xmax = 1e-3
[]

[Variables]
  [C_L]
    initial_condition = 0
  []
[]

[Kernels]
  [storage]
    type = HydrogenTimeDerivative
    variable = C_L
  []
  [fick]
    type = HydrogenFickDiffusion
    variable = C_L
    diffusivity = 1.3e-9
  []
[]

[Materials]
  [oriani]
    type = OrianiHydrogenMaterial
    lattice_concentration = C_L
    lattice_site_density = 8.468e5 # mol lattice sites/m^3
    reference_trap_density = 0.3022 # 10^23.26 mol trap sites/m^3
    binding_energy = -35200
    temperature = 293
  []
[]

[BCs]
  [left]
    type = DirichletBC
    variable = C_L
    boundary = left
    value = 8.24
  []
  [right]
    type = DirichletBC
    variable = C_L
    boundary = right
    value = 0
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  dt = 1
  num_steps = 10
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
[]

[Outputs]
  exodus = true
[]

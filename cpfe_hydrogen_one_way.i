# Illustrative one-way CPFE -> hydrogen coupling.
# Hydrostatic stress is projected into an FE variable in the same nonlinear solve.
[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 20
  ny = 2
  nz = 2
  xmin = 0
  xmax = 1e-3
  ymin = 0
  ymax = 1e-3
  zmin = 0
  zmax = 1e-3
  elem_type = HEX8
[]

[Variables]
  [C_L]
    initial_condition = 8.24
    # Scalings are tied to the 1 mm mesh: residuals scale with element volume
    scaling = 1e13
  []
  [hydrostatic_stress]
    initial_condition = 0
    scaling = 1e3
  []
[]

[Physics/SolidMechanics/QuasiStatic/all]
  strain = FINITE
  incremental = true
  add_variables = true
  generate_output = stress_zz
[]

[Kernels]
  [hydrogen_storage]
    type = HydrogenTimeDerivative
    variable = C_L
  []
  [fick]
    type = HydrogenFickDiffusion
    variable = C_L
    diffusivity = 1.3e-9
  []
  [hydrostatic_stress_projection]
    type = MaterialPropertyValue
    variable = hydrostatic_stress
    prop_name = hydrostatic_stress
    positive = false
  []
  [stress_assisted]
    type = HydrogenStressAssistedDiffusion
    variable = C_L
    hydrostatic_stress = hydrostatic_stress
    diffusivity = 1.3e-9
    partial_molar_volume = 2.0e-6
    temperature = 293
  []
[]

[BCs]
  [fix_y]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0
  []
  [fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0
  []
  [fix_z]
    type = DirichletBC
    variable = disp_z
    boundary = back
    value = 0
  []
  [pull]
    type = FunctionDirichletBC
    variable = disp_z
    boundary = front
    function = pull_ramp
  []
  [hydrogen_left]
    type = DirichletBC
    variable = C_L
    boundary = left
    value = 8.24
  []
  [hydrogen_right]
    type = DirichletBC
    variable = C_L
    boundary = right
    value = 0
  []
[]

[Materials]
  [elasticity_tensor]
    type = ComputeElasticityTensorCP
    C_ijkl = '1.684e11 1.214e11 1.214e11 1.684e11 1.214e11 1.684e11 7.54e10 7.54e10 7.54e10'
    fill_method = symmetric9
  []
  [cp_stress]
    type = ComputeMultipleCrystalPlasticityStress
    crystal_plasticity_models = cp_update
    tan_mod_type = exact
  []
  [cp_update]
    type = CrystalPlasticityKalidindiUpdate
    number_slip_systems = 12
    slip_sys_file_name = /home/ghostrobot96/projects/moose/modules/solid_mechanics/test/tests/crystal_plasticity/input_slip_sys.txt
    h = 5.415e8
    t_sat = 1.098e8
    gss_initial = 3.0e7
  []
  [hydrostatic_stress]
    type = HydrostaticStressMaterial
    stress = stress
    hydrostatic_stress = hydrostatic_stress
  []
  [oriani]
    type = OrianiHydrogenMaterial
    lattice_concentration = C_L
    lattice_site_density = 8.468e5
    reference_trap_density = 0.3022
    binding_energy = -35200
    temperature = 293
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  end_time = 300
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.5
    optimal_iterations = 8
    timestep_limiting_function = dt_limit
    force_step_every_function_point = true
  []
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
[]

[Functions]
  # Ramp the displacement over 20 s, then hold it while hydrogen diffuses
  [pull_ramp]
    type = ParsedFunction
    expression = '1e-6*(1 + 500*y)*min(t/20, 1)'
  []
  # Maximum dt: 1 s during the ramp, 20 s during the hold
  [dt_limit]
    type = PiecewiseConstant
    x = '0 20'
    y = '1 20'
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Outputs]
  exodus = true
[]

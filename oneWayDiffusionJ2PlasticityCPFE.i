# One-way mechanics -> hydrogen coupling on a ferrite/pearlite bicrystal.
#   ferrite  : crystal plasticity (CrystalPlasticityKalidindiUpdate)
#   pearlite : J2 plasticity (IsotropicPlasticityStressUpdate)
#   whole domain: lattice hydrogen transport with Oriani trapping.
# The equivalent plastic strain driving the dislocation trap density comes from
# CPEquivalentPlasticStrain in ferrite and J2EquivalentPlasticStrain in pearlite.
#
# Units: SI (m, Pa, s, mol). The dummy mesh coordinates (0-20) are scaled by 1e-5,
# giving a 100 um x 100 um x 200 um bicrystal (ferrite z > 100 um, pearlite z < 100 um).

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  [file]
    type = FileMeshGenerator
    file = rve_2_ele.inp
  []
  [rename]
    type = RenameBlockGenerator
    input = file
    old_block = 'ferrite_HEX8 pearlite_HEX8'
    new_block = 'ferrite pearlite'
  []
  [scale]
    type = TransformGenerator
    input = rename
    transform = SCALE
    vector_value = '1e-5 1e-5 1e-5'
  []
  [faces]
    type = SideSetsFromNormalsGenerator
    input = scale
    normals = '-1 0 0  1 0 0  0 -1 0'
    new_boundary = 'x_min x_max y_min'
  []
  construct_side_list_from_node_list = true
[]

[Functions]
  # Pearlite J2 isotropic hardening function (flow stress in Pa)
  #   sigma_f = sigma_y * (1 + (E/sigma_y) * eps_p)^N
  # With UMAT props: sigma_y=1000 MPa, E=230000 MPa, N=0.2:
  #   sigma_f = 1e9 * (1 + 230 * eps_p)^0.2     [230 = E/sigma_y, units 1/strain]
  #
  [pearlite_J2_hardening]
    type = ParsedFunction
    expression = '1.0e9 * (1.0 + 230.0 * t)^0.2'
  []
  # x-displacement of the x_max face: ~1% strain ramped over 20 s, then held.
  # Loading parallel to the interface strains both phases equally, so both yield.
  [pull_ramp]
    type = ParsedFunction
    expression = '1e-6*(1 + 500*y)*min(t/20, 1)'
  []
  # Top-face hydrogen charge ramped to 8.24 over 20 s rather than applied suddenly
  [charge_ramp]
    type = ParsedFunction
    expression = '8.24*min(t/20, 1)'
  []
  # Maximum dt: 1 s during the ramp, 20 s during the hold
  [dt_limit]
    type = PiecewiseConstant
    x = '0 20'
    y = '1 20'
  []
[]

[Variables]
  [C_L]
    initial_condition = 0
    # Scalings are tied to the element size: residuals scale with element volume
    scaling = 1e13
  []
  [hydrostatic_stress]
    initial_condition = 0
    scaling = 1e3
  []
[]

[AuxVariables]
  [eps_p_vm]
    order = CONSTANT
    family = MONOMIAL
    block = pearlite
  []
  [equivalent_plastic_strain]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
  [equivalent_plastic_strain_output]
    type = MaterialRealAux
    variable = equivalent_plastic_strain
    property = equivalent_plastic_strain
    execute_on = timestep_end
  []
  [eps_p_vm_aux]
    type = MaterialRealAux
    variable = eps_p_vm
    property = effective_plastic_strain
    execute_on = timestep_end
    block = pearlite
  []
[]

# CP requires the finite-strain kinematics, so both phases share one FINITE action
[Physics/SolidMechanics/QuasiStatic/all]
  strain = FINITE
  incremental = true
  add_variables = true
  generate_output = 'stress_xx vonmises_stress'
[]

[Kernels]
  # Lumped storage: a consistent mass matrix undershoots below zero (past the Oriani pole
  # C_L = -N_L/K = -0.449) next to a fast-rising boundary concentration when dt < ~h^2/(6D)
  [hydrogen_storage]
    type = HydrogenLumpedTimeDerivative
    variable = C_L
  []
  [fick]
    type = HydrogenFickDiffusion
    variable = C_L
    diffusivity = 1.3e-9
  []
  [dislocation_trap_evolution]
    type = DislocationTrapEvolution
    variable = C_L
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
  [fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = x_min
    value = 0
  []
  [fix_y]
    type = DirichletBC
    variable = disp_y
    boundary = y_min
    value = 0
  []
  [fix_z]
    type = DirichletBC
    variable = disp_z
    boundary = fixed_face
    value = 0
  []
  [pull]
    type = FunctionDirichletBC
    variable = disp_x
    boundary = x_max
    function = pull_ramp
  []
  # Hydrogen charged on the ferrite top face, sink on the pearlite bottom face
  [hydrogen_charge]
    type = FunctionDirichletBC
    variable = C_L
    boundary = disp_z
    function = charge_ramp
  []
  [hydrogen_sink]
    type = DirichletBC
    variable = C_L
    boundary = fixed_face
    value = 0
  []
[]

[Materials]
  # ---------------- ferrite: crystal plasticity ----------------
  [elasticity_tensor_CP]
    type = ComputeElasticityTensorCP
    C_ijkl = '1.684e11 1.214e11 1.214e11 1.684e11 1.214e11 1.684e11 7.54e10 7.54e10 7.54e10'
    fill_method = symmetric9
    block = ferrite
  []
  [cp_stress]
    type = ComputeMultipleCrystalPlasticityStress
    crystal_plasticity_models = cp_update
    tan_mod_type = exact
    block = ferrite
  []
  [cp_update]
    type = CrystalPlasticityKalidindiUpdate
    number_slip_systems = 12
    slip_sys_file_name = /home/ghostrobot96/projects/moose/modules/solid_mechanics/test/tests/crystal_plasticity/input_slip_sys.txt
    h = 5.415e8
    t_sat = 1.098e8
    gss_initial = 3.0e7
    block = ferrite
  []
  [equivalent_plastic_strain_CP]
    type = CPEquivalentPlasticStrain
    number_slip_systems = 12
    block = ferrite
  []

  # ---------------- pearlite: J2 plasticity (Pa) ----------------
  [elasticity_tensor_J2]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 230e9
    poissons_ratio = 0.3
    block = pearlite
  []
  [J2_stress]
    type = ComputeMultipleInelasticStress
    inelastic_models = 'pearlite_J2'
    block = pearlite
  []
  # IsotropicPlasticityStressUpdate with the consistent tangent (MOOSE's returns the elastic one)
  [pearlite_J2]
    type = J2ConsistentTangentStressUpdate
    yield_stress = 1e9
    hardening_function = pearlite_J2_hardening
    block = pearlite
  []
  [equivalent_plastic_strain_J2]
    type = J2EquivalentPlasticStrain
    block = pearlite
  []

  # ---------------- hydrogen: whole domain ----------------
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

[Postprocessors]
  [eps_p_ferrite]
    type = ElementAverageValue
    variable = equivalent_plastic_strain
    block = ferrite
  []
  [eps_p_pearlite]
    type = ElementAverageValue
    variable = equivalent_plastic_strain
    block = pearlite
  []
  [C_L_ferrite]
    type = ElementAverageValue
    variable = C_L
    block = ferrite
  []
  [C_L_pearlite]
    type = ElementAverageValue
    variable = C_L
    block = pearlite
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

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Outputs]
  exodus = true
  csv = true
[]

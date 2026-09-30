# Stage 1A.1b — Pearlite J2 single element, y-axis uniaxial tension
# Constitutive cross-validation: IsotropicPlasticityStressUpdate vs analytical UMAT law.
# Loading: y-direction, 5% engineering strain at strain rate 0.05/s (t=0 to t=1.0 s).
#
# Parameters from umat_cementite (umat_umatht_all.f:8056-8095):
#   E=230000 MPa, nu=0.3, Sy=1000 MPa, N=0.2

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 3
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1
    zmin = 0
    zmax = 1
    elem_type = HEX8
  []
[]

[Physics/SolidMechanics/QuasiStatic]
  [all]
    strain = SMALL
    incremental = true
    add_variables = true
    generate_output = 'stress_yy'
  []
[]

[BCs]
  [fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0.0
  []
  [fix_y]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0.0
  []
  [fix_z]
    type = DirichletBC
    variable = disp_z
    boundary = back
    value = 0.0
  []
  [load_y]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = top
    function = '0.05 * t'
  []
[]

[Functions]
  # Pearlite J2 isotropic hardening function 
  #   sigma_f = sigma_y * (1 + (E/sigma_y) * eps_p)^N
  # With UMAT props: sigma_y=1000 MPa, E=230000 MPa, N=0.2:
  #   sigma_f = 1000 * (1 + 230 * eps_p)^0.2     [230 = E/sigma_y, units 1/strain]
  #
  [pearlite_J2_hardening]
    type = ParsedFunction
    expression = '1000.0 * (1.0 + 230.0 * t)^0.2'
  []
[]

[AuxVariables]
  [eps_p_vm]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [eps_p_vm_aux]
    type = MaterialRealAux
    variable = eps_p_vm
    property = effective_plastic_strain
    execute_on = timestep_end
  []
[]

[Materials]
  [elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 230000
    poissons_ratio = 0.3
  []
  [stress]
    type = ComputeMultipleInelasticStress
    inelastic_models = 'pearlite_J2'
  []
  [pearlite_J2]
    type = IsotropicPlasticityStressUpdate
    yield_stress = 1000
    hardening_function = pearlite_J2_hardening
  []
[]

[Postprocessors]
  [stress_yy]
    type = ElementAverageValue
    variable = stress_yy
  []
  [eps_p_vm]
    type = ElementAverageValue
    variable = eps_p_vm
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type -pc_asm_overlap -sub_pc_type -ksp_type -ksp_gmres_restart'
  petsc_options_value = ' asm      2              lu            gmres     200'
  nl_abs_tol = 1e-10
  nl_rel_tol = 1e-10
  nl_abs_step_tol = 1e-10
  dt = 0.01
  dtmin = 0.001
  dtmax = 0.1
  num_steps = 100
  [Predictor]
    type = SimplePredictor
    scale = 1.0
    skip_after_failed_timestep = true
  []
[]

[Outputs]
  csv = true
[]

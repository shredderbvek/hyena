# X65 manuscript: Two-Phase practical permeation case (Sections 3.3.6-3.3.8).
# SI units: m, Pa, s, mol/m^3, J/mol, K. One-way mechanics -> hydrogen.
# Retain fixed CP saturation at 330 MPa as the agreed hardening approximation.
# Hydrogen retains the application's lumped storage and FE stress projection.
ferrite_blocks = 'ferrite_grain_1 ferrite_grain_2 ferrite_grain_3 ferrite_grain_5 ferrite_grain_6 ferrite_grain_7 ferrite_grain_8 ferrite_grain_9 ferrite_grain_10 ferrite_grain_11 ferrite_grain_12 ferrite_grain_13 ferrite_grain_14 ferrite_grain_15 ferrite_grain_16 ferrite_grain_18 ferrite_grain_19 ferrite_grain_20'

ferrite_diffusivity = 3.29e-10
pearlite_diffusivity = 3.0e-11
temperature = 300
background_concentration = 0.00150776947299 # 9.08e11 atoms/mm^3, Section 3.3.8
charge_concentration = 1.50776947299       # 9.08e14 atoms/mm^3, Section 3.3.8

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  construct_side_list_from_node_list = true
  [file]
    type = FileMeshGenerator
    file = RVE_X65.inp
  []
  [grains]
    type = RenameBlockGenerator
    input = file
    old_block = 'PART-1-1_MAT1_GRN1_TET10 PART-1-1_MAT1_GRN2_TET10 PART-1-1_MAT1_GRN3_TET10 PART-1-1_MAT1_GRN4_TET10 PART-1-1_MAT1_GRN5_TET10 PART-1-1_MAT1_GRN6_TET10 PART-1-1_MAT1_GRN7_TET10 PART-1-1_MAT1_GRN8_TET10 PART-1-1_MAT1_GRN9_TET10 PART-1-1_MAT1_GRN10_TET10 PART-1-1_MAT1_GRN11_TET10 PART-1-1_MAT1_GRN12_TET10 PART-1-1_MAT1_GRN13_TET10 PART-1-1_MAT1_GRN14_TET10 PART-1-1_MAT1_GRN15_TET10 PART-1-1_MAT1_GRN16_TET10 PART-1-1_MAT1_GRN17_TET10 PART-1-1_MAT1_GRN18_TET10 PART-1-1_MAT1_GRN19_TET10 PART-1-1_MAT1_GRN20_TET10'
    new_block = 'ferrite_grain_1 ferrite_grain_2 ferrite_grain_3 pearlite ferrite_grain_5 ferrite_grain_6 ferrite_grain_7 ferrite_grain_8 ferrite_grain_9 ferrite_grain_10 ferrite_grain_11 ferrite_grain_12 ferrite_grain_13 ferrite_grain_14 ferrite_grain_15 ferrite_grain_16 pearlite ferrite_grain_18 ferrite_grain_19 ferrite_grain_20'
  []
  # Abaqus coordinates are mm; manuscript RVE dimensions are 8 x 8 x 1.5 um.
  [scale]
    type = TransformGenerator
    input = grains
    transform = SCALE
    vector_value = '1e-3 1e-3 1e-3'
  []
[]

[Functions]
  # Pearlite J2 isotropic hardening function (flow stress in Pa)
  #   sigma_f = sigma_y * (1 + (E/sigma_y) * eps_p)^N
  # Table 3.4 and UMAT props: sigma_y=1000 MPa, E=230000 MPa, N=0.2:
  #   sigma_f = 1e9 * (1 + 230 * eps_p)^0.2     [230 = E/sigma_y, units 1/strain]
  #
  [pearlite_J2_hardening]
    type = ParsedFunction
    expression = '1.0e9 * (1.0 + 230.0 * t)^0.2'
  []
  # Hoop tension: 5% of the 8 um y-span, linear ramp over 1 s, then hold.
  [pull_ramp]
    type = ParsedFunction
    expression = '4e-7*min(t, 1)'
  []
  # Abaqus Amp-C: quintic smooth step from background to charge over 0-1 s.
  [charge_ramp]
    type = ParsedFunction
    expression = '${background_concentration} + (${charge_concentration} - ${background_concentration})*(10*min(t,1)^3 - 15*min(t,1)^4 + 6*min(t,1)^5)'
  []
  # Numerical step caps: 0.01 s during loading/charging, 0.1 s during hold.
  [dt_limit]
    type = PiecewiseConstant
    x = '0 1'
    y = '0.01 0.1'
  []
[]

[Variables]
  [C_L]
    # Linear hydrogen basis retained for nodal lumped storage on TET10 geometry.
    order = FIRST
    family = LAGRANGE
  []
  [hydrostatic_stress]
    order = FIRST
    family = LAGRANGE
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
  generate_output = 'stress_xx stress_yy vonmises_stress'
[]

[Kernels]
  # Retain nodal lumped storage; positivity must be assessed for this RVE.
  [hydrogen_storage]
    type = HydrogenLumpedTimeDerivative
    variable = C_L
  []
  [fick_ferrite]
    type = HydrogenFickDiffusion
    variable = C_L
    diffusivity = ${ferrite_diffusivity}
    block = '${ferrite_blocks}'
  []
  [fick_pearlite]
    type = HydrogenFickDiffusion
    variable = C_L
    diffusivity = ${pearlite_diffusivity}
    block = pearlite
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
  [stress_assisted_ferrite]
    type = HydrogenStressAssistedDiffusion
    variable = C_L
    hydrostatic_stress = hydrostatic_stress
    diffusivity = ${ferrite_diffusivity}
    partial_molar_volume = 2.0e-6
    temperature = ${temperature}
    block = '${ferrite_blocks}'
  []
  [stress_assisted_pearlite]
    type = HydrogenStressAssistedDiffusion
    variable = C_L
    hydrostatic_stress = hydrostatic_stress
    diffusivity = ${pearlite_diffusivity}
    partial_molar_volume = 2.0e-6
    temperature = ${temperature}
    block = pearlite
  []
[]

[BCs]
  [fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = "X_LEFT"
    value = 0
  []
  [fix_y]
    type = DirichletBC
    variable = disp_y
    boundary = "Y_BOTTOM"
    value = 0
  []
  [fix_z]
    type = DirichletBC
    variable = disp_z
    boundary = "Z_BACK"
    value = 0
  []
  [pull]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = "Y_TOP"
    function = pull_ramp
  []
  # Hydrogen charged on RVE right face to left face.
  [hydrogen_charge]
    type = FunctionDirichletBC
    variable = C_L
    boundary = "X_RIGHT"
    function = charge_ramp
  []
  [hydrogen_sink]
    type = DirichletBC
    variable = C_L
    boundary = X_LEFT
    value = ${background_concentration}
  []
[]

[Materials]
  # ---------------- ferrite: crystal plasticity ----------------
  # MAT1/test.xtali uses kODF=1: texture row is GrainID (not element ID).
  # texture.txti flags 0 0 mean Kocks angles (psi, theta, phi) in degrees.
  # Match UMAT AnglesToRotMatrix using Bunge (psi+90, theta, 90-phi),
  # wrapped to [0,360); MOOSE CP applies the active rotation R_Bunge^T.
  [elasticity_tensor_CP_grain_1]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
    fill_method = symmetric9
    # UMAT grain 1: Kocks (131.73, 86.26, 229.29) degrees.
    euler_angle_1 = 221.73
    euler_angle_2 = 86.26
    euler_angle_3 = 220.71
    block = ferrite_grain_1
  []
  [elasticity_tensor_CP_grain_2]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
    fill_method = symmetric9
    # UMAT grain 2: Kocks (131.73, 86.26, 229.29) degrees.
    euler_angle_1 = 221.73
    euler_angle_2 = 86.26
    euler_angle_3 = 220.71
    block = ferrite_grain_2
  []
  [elasticity_tensor_CP_grain_3]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
    fill_method = symmetric9
    # UMAT grain 3: Kocks (131.73, 86.26, 229.29) degrees.
    euler_angle_1 = 221.73
    euler_angle_2 = 86.26
    euler_angle_3 = 220.71
    block = ferrite_grain_3
  []
  [elasticity_tensor_CP_grain_5]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
    fill_method = symmetric9
    # UMAT grain 5: Kocks (131.73, 86.26, 229.29) degrees.
    euler_angle_1 = 221.73
    euler_angle_2 = 86.26
    euler_angle_3 = 220.71
    block = ferrite_grain_5
  []
  [elasticity_tensor_CP_grain_6]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
    fill_method = symmetric9
    # UMAT grain 6: Kocks (131.73, 86.26, 229.29) degrees.
    euler_angle_1 = 221.73
    euler_angle_2 = 86.26
    euler_angle_3 = 220.71
    block = ferrite_grain_6
  []
  [elasticity_tensor_CP_grain_7]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
    fill_method = symmetric9
    # UMAT grain 7: Kocks (131.73, 86.26, 229.29) degrees.
    euler_angle_1 = 221.73
    euler_angle_2 = 86.26
    euler_angle_3 = 220.71
    block = ferrite_grain_7
  []
  [elasticity_tensor_CP_grain_8]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
    fill_method = symmetric9
    # UMAT grain 8: Kocks (131.73, 86.26, 229.29) degrees.
    euler_angle_1 = 221.73
    euler_angle_2 = 86.26
    euler_angle_3 = 220.71
    block = ferrite_grain_8
  []
  [elasticity_tensor_CP_grain_9]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
    fill_method = symmetric9
    # UMAT grain 9: Kocks (329.83, 45.23, 169.92) degrees.
    euler_angle_1 = 59.83
    euler_angle_2 = 45.23
    euler_angle_3 = 280.08
    block = ferrite_grain_9
  []
  [elasticity_tensor_CP_grain_10]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
    fill_method = symmetric9
    # UMAT grain 10: Kocks (208.78, 79.17, 347.94) degrees.
    euler_angle_1 = 298.78
    euler_angle_2 = 79.17
    euler_angle_3 = 102.06
    block = ferrite_grain_10
  []
  [elasticity_tensor_CP_grain_11]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
    fill_method = symmetric9
    # UMAT grain 11: Kocks (144.95, 30.76, 261.40) degrees.
    euler_angle_1 = 234.95
    euler_angle_2 = 30.76
    euler_angle_3 = 188.60
    block = ferrite_grain_11
  []
  [elasticity_tensor_CP_grain_12]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
    fill_method = symmetric9
    # UMAT grain 12: Kocks (31.83, 159.33, 264.14) degrees.
    euler_angle_1 = 121.83
    euler_angle_2 = 159.33
    euler_angle_3 = 185.86
    block = ferrite_grain_12
  []
  [elasticity_tensor_CP_grain_13]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
    fill_method = symmetric9
    # UMAT grain 13: Kocks (228.51, 95.52, 192.43) degrees.
    euler_angle_1 = 318.51
    euler_angle_2 = 95.52
    euler_angle_3 = 257.57
    block = ferrite_grain_13
  []
  [elasticity_tensor_CP_grain_14]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
    fill_method = symmetric9
    # UMAT grain 14: Kocks (158.86, 79.44, 359.90) degrees.
    euler_angle_1 = 248.86
    euler_angle_2 = 79.44
    euler_angle_3 = 90.10
    block = ferrite_grain_14
  []
  [elasticity_tensor_CP_grain_15]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
    fill_method = symmetric9
    # UMAT grain 15: Kocks (253.69, 118.83, 330.44) degrees.
    euler_angle_1 = 343.69
    euler_angle_2 = 118.83
    euler_angle_3 = 119.56
    block = ferrite_grain_15
  []
  [elasticity_tensor_CP_grain_16]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
    fill_method = symmetric9
    # UMAT grain 16: Kocks (48.85, 160.26, 259.66) degrees.
    euler_angle_1 = 138.85
    euler_angle_2 = 160.26
    euler_angle_3 = 190.34
    block = ferrite_grain_16
  []
  [elasticity_tensor_CP_grain_18]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
    fill_method = symmetric9
    # UMAT grain 18: Kocks (71.21, 139.18, 354.20) degrees.
    euler_angle_1 = 161.21
    euler_angle_2 = 139.18
    euler_angle_3 = 95.80
    block = ferrite_grain_18
  []
  [elasticity_tensor_CP_grain_19]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
    fill_method = symmetric9
    # UMAT grain 19: Kocks (327.43, 125.04, 162.16) degrees.
    euler_angle_1 = 57.43
    euler_angle_2 = 125.04
    euler_angle_3 = 287.84
    block = ferrite_grain_19
  []
  [elasticity_tensor_CP_grain_20]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
    fill_method = symmetric9
    # UMAT grain 20: Kocks (146.09, 99.43, 133.64) degrees.
    euler_angle_1 = 236.09
    euler_angle_2 = 99.43
    euler_angle_3 = 316.36
    block = ferrite_grain_20
  []
  [cp_stress]
    type = ComputeMultipleCrystalPlasticityStress
    crystal_plasticity_models = cp_update
    tan_mod_type = exact
    block = '${ferrite_blocks}'
  []
  [cp_update]
    type = CrystalPlasticityKalidindiUpdate
    crystal_lattice_type = BCC
    number_slip_systems = 12
    # 12 {110}<111> systems from bcc.sx, reordered normal then direction for MOOSE.
    slip_sys_file_name = x65_bcc_slip_sys.slip
    # Table 3.3; use full precision for the flow rule from Two_Phase/Mat1/bcc.sx.
    ao = 5.25322564697125
    xm = 0.1315151258615835
    gss_initial = 3.0e8
    # UMAT: dg/dGamma = h0*(t_sat-g)/(t_sat-g0), h0=4134 MPa.
    # MOOSE: dg/dGamma = h*(1-g/t_sat)^gss_a, with r=1 for equal hardening.
    # Freeze t_sat at 330 MPa (UMAT reference total slip rate 0.001 s^-1),
    # set gss_a=1 and h=h0*t_sat/(t_sat-g0)=45474 MPa to preserve that law.
    # Rate-dependent saturation exponent m'=0.1 has no counterpart in this model.
    r = 1.0
    gss_a = 1.0
    h = 4.5474e10
    t_sat = 3.3e8
    block = '${ferrite_blocks}'
  []
  [equivalent_plastic_strain_CP]
    type = CPEquivalentPlasticStrain
    number_slip_systems = 12
    block = '${ferrite_blocks}'
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
  # Table 3.5: N_T(0)=9.09e24 sites/m^3 in both phases.
  # OrianiHydrogenMaterial uses N_T=N_ref*10^(-2.33*exp(-5.5*eps_p));
  # N_ref=(9.09e24/N_A)*10^2.33=3227.10414254 mol/m^3, not N_T(0).
  # This follows UMAT kflag=3's strain dependence, normalized to Table 3.5's
  # initial density (the UMAT's 10^24.96 sites/m^3 is slightly different).
  # Binding-energy convention here is negative: K=exp(-binding_energy/(R*T)).
  [oriani_ferrite]
    type = OrianiHydrogenMaterial
    lattice_concentration = C_L
    lattice_site_density = 846874.924259 # 5.1e29 sites/m^3 / N_A
    reference_trap_density = 3227.10414254
    binding_energy = -60000
    temperature = ${temperature}
    block = '${ferrite_blocks}'
  []
  [oriani_pearlite]
    type = OrianiHydrogenMaterial
    lattice_concentration = C_L
    # UMAT's full precision 4.488e29 sites/m^3 (Table 3.5 rounds to 4.49e29).
    lattice_site_density = 745249.933348
    reference_trap_density = 3227.10414254
    binding_energy = -60000
    temperature = ${temperature}
    block = pearlite
  []
[]

[Postprocessors]
  [eps_p_ferrite]
    type = ElementAverageValue
    variable = equivalent_plastic_strain
    block = '${ferrite_blocks}'
  []
  [eps_p_pearlite]
    type = ElementAverageValue
    variable = equivalent_plastic_strain
    block = pearlite
  []
  [C_L_ferrite]
    type = ElementAverageValue
    variable = C_L
    block = '${ferrite_blocks}'
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
  end_time = 10
  # Balance residuals across displacement (m), stress (Pa), and hydrogen (mol/m^3).
  # Jacobian-only scaling made the stress projection dominate the first-step solve.
  automatic_scaling = true
  resid_vs_jac_scaling_param = 1
  # Keep the initial residual scale fixed as subsequent loading increments shrink.
  compute_scaling_once = true
  [TimeStepper]
    type = ConstantDT
    dt = 0.008
  []
  [Predictor]
    type = SimplePredictor
    scale = 1
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

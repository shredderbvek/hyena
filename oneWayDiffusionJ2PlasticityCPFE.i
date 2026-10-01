# One-way mechanics -> hydrogen coupling on a ferrite/pearlite bicrystal.
#   ferrite  : crystal plasticity (CrystalPlasticityKalidindiUpdate)
#   pearlite : J2 plasticity (J2ConsistentTangentStressUpdate)
#   whole domain: lattice hydrogen transport with Oriani trapping.
# The equivalent plastic strain driving the dislocation trap density comes from
# CPEquivalentPlasticStrain in ferrite and J2EquivalentPlasticStrain in pearlite.
#
# Units: SI (m, Pa, s, mol). The dummy mesh coordinates (0-20) are scaled by 1e-5,
# giving a 100 um x 100 um x 200 um bicrystal (ferrite z > 100 um, pearlite z < 100 um).
# X65 parameters: references/X65_CPFE_J2_HE/X65_Project_Manuscript_1.pdf,
# Tables 3.3-3.5; implementation details from Two_Phase/Mat1/bcc.sx and
# Two_Phase/umat_umatht_all.f. Retain this bicrystal's geometry and loading schedule.
# Ferrite hardening is a fixed-saturation MOOSE approximation, not a new calibration.
# Site/atom densities are converted to mol/m^3 using N_A = 6.02214076e23 mol^-1.

ferrite_diffusivity = 3.29e-10
pearlite_diffusivity = 3.0e-11
temperature = 300
background_concentration = 0.00150776947299 # 9.08e11 atoms/mm^3, Section 3.3.8
charge_concentration = 1.50776947299       # 9.08e14 atoms/mm^3, Section 3.3.8

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
  # Table 3.4 and UMAT props: sigma_y=1000 MPa, E=230000 MPa, N=0.2:
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
  # Paper's permeation concentrations; retain the bicrystal's 20 s charge ramp.
  [charge_ramp]
    type = ParsedFunction
    expression = '${background_concentration} + (${charge_concentration} - ${background_concentration})*min(t/20, 1)'
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
    initial_condition = ${background_concentration}
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
  # Lumped storage avoids negative concentrations next to the rising charge boundary.
  [hydrogen_storage]
    type = HydrogenLumpedTimeDerivative
    variable = C_L
  []
  [fick_ferrite]
    type = HydrogenFickDiffusion
    variable = C_L
    diffusivity = ${ferrite_diffusivity}
    block = ferrite
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
    block = ferrite
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
  # Hydrogen charged on ferrite top face; background concentration at pearlite bottom.
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
    value = ${background_concentration}
  []
[]

[Materials]
  # ---------------- ferrite: crystal plasticity ----------------
  [elasticity_tensor_CP]
    type = ComputeElasticityTensorCP
    C_ijkl = '2.33e11 1.36e11 1.36e11 2.33e11 1.36e11 2.33e11 1.18e11 1.18e11 1.18e11'
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
    block = ferrite
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

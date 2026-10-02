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

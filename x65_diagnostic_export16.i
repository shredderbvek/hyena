[Problem]
  restart_file_base = /tmp/x65_diag_seed16_cp/0016
[]
[Executioner]
  end_time = 0.026875
[]
[Outputs]
  exodus = false
  csv = false
  [seed_fields]
    type = Exodus
    file_base = /tmp/x65_diag_seed16_fields
    execute_on = INITIAL
  []
[]

[Problem]
  restart_file_base = /tmp/x65_diag_seed7_cp/0007
[]
[Executioner]
  end_time = 0.015875
[]
[Outputs]
  exodus = false
  csv = false
  [seed_fields]
    type = Exodus
    file_base = /tmp/x65_diag_seed7_fields
    execute_on = INITIAL
  []
[]

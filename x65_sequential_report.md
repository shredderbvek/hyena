# X65 sequential convergence verification

## Status

Full 10 s convergence is **pending**. The full run is active; a completed first step is not evidence of full-run convergence.

## Solver change

`RVE_X65_sequential.i` assigns displacements to `mechanics`, projected stress to `stress_projection`, and concentration to `hydrogen`. MOOSE solves those systems in that order once per common time step. This is appropriate for the current one-way model because hydrogen does not modify mechanics.

The installed MOOSE revision is `96077a59e5302ec3ca9f651c6f6da02594088253`. Its `FEProblemSolve::solve()` loops over systems without advancing material history; `TransientBase::incrementStepOrReject()` advances the problem after the combined successful step; `FEProblemBase::advanceState()` shifts all system solutions and material histories together. A failed solve causes restoration of all systems. These mechanisms avoid committing mechanics twice in a sequential step.

Official reference: [MOOSE FEProblemSolve](https://mooseframework.inl.gov/source/executioners/FEProblemSolve.html).

## Input changes

- Declare three ordered nonlinear systems and explicitly assign each variable.
- Disable automatic displacement creation; retain SECOND-order displacement and FIRST-order hydrogen/stress bases.
- Apply a full SMP preconditioner to each system; use Hypre BoomerAMG for mechanics.
- Assemble residual/Jacobian together and attach the existing predictor to mechanics.
- Increase adaptive optimal iterations from 8 to 20 because MOOSE sums iterations across systems.
- Use CP stress `rtol=1e-10`, `abs_tol=1e-3 Pa`, and slip-resistance tolerance `1e-8`, previously verified in the difficult isolated mechanics diagnostic.

No material calibration, texture, hardening law, loading/charging function, mesh, transport parameter, MOOSE library, or application C++ source is changed. The previous `RVE_X65_test_run.i` remains available for comparison.

## Preliminary evidence

- **PASS:** multi-system input setup.
- **PASS, limited:** first-step AMG/assembly/MPI comparison; monitored concentrations match the default sequential solver within approximately 5e-15 mol/m^3. This is not a pointwise constitutive-history comparison.
- **PASS:** passed the earlier stall at 0.026875 s; accepted time 0.029875 s after 10 steps, with 0 failed solves.
- **PENDING:** finish to 10 s with a successful process exit.
- **PASS, limited to the current accepted prefix:** nodal minimum 0.00068994709 mol/m^3; ferrite accumulated mean strain agrees with integrated mean rate within 2.44e-19. Pearlite remains elastic. This is not a pointwise comparison of all state variables or a positivity guarantee for rejected trials.

## Reproduction

```bash
source /home/ghostrobot96/miniforge/etc/profile.d/conda.sh
conda activate moose
mpiexec -n 4 ./hyena-opt -i RVE_X65_sequential.i x65_sequential_monitor.i --n-threads=4 > x65_sequential_results/run.log 2>&1
```

The diagnostic overlay records accepted-step nodal concentration extrema and phase-average material strain, strain rate, and hydrostatic stress. Checkpoints are written every five accepted steps. No nonlinear-trial positivity or mesh/time-step independence is established by this convergence run.

## Rejected solver comparisons

The default and DS-scaled PJFNK comparisons recovered checkpoint 5 with the same four MPI ranks/four threads. Both reported CP constitutive failures during the linear solve and `DIVERGED_LINE_SEARCH`; they were stopped and are excluded from the candidate. Their logs are `/tmp/x65_sequential_pjfnk4.log` and `/tmp/x65_sequential_ds.log`. The candidate retains NEWTON. A preliminary restart attempt with two threads was also rejected because this checkpoint requires four; production uses the checkpoint-compatible layout.

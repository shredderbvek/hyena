# X65 convergence diagnostics — 2026-10-01

## Result

The simultaneous Newton solve still fails at step 17. Separating mechanics,
hydrostatic-stress projection, and hydrogen succeeds for the same increment,
using the original physical parameters and local constitutive tolerances.
This establishes a successful single-increment diagnostic, not full-run convergence.

No production input, application C++ source, or MOOSE library file was changed.
Diagnostic inputs were added in the application root. Logs and numerical evidence
are retained in `x65_diagnostic_results/`; solution files and checkpoints are in `/tmp`.

## Step 17: matched checkpoint tests

All stages start from the replay's accepted step-16 checkpoint at **0.026875 s**.
The attempted increment is **0.00025 s**, ending at **0.027125 s**.
Runs use one MPI process, four threads, NEWTON, and the production relative/absolute
nonlinear tolerances of 1e-8/1e-10. Automatic residual scaling is recalculated on
recovery, so scaled residual magnitudes cannot be compared directly between runs.

| Check | Result | Verdict |
|---|---|---|
| Original coupled replay | 16 accepted steps; step 17 fails with `DIVERGED_LINE_SEARCH` | FAIL |
| Recovered coupled control | `DIVERGED_LINE_SEARCH`, without accepting a Newton update | FAIL |
| Coupled control with tighter local CP tolerances | `DIVERGED_LINE_SEARCH` after iteration 1 | FAIL |
| Mechanics, old hydrogen and projected stress fixed | 7 Newton iterations; final scaled residual 3.257176e-11 | PASS |
| Stress projection, new displacement fixed | 2 Newton iterations; residual 1.730371e-10 | PASS |
| Hydrogen, new displacement and projected stress fixed | 2 Newton iterations; residual 3.186267e-11 | PASS |
| Hydrogen positivity in monitored iterates | Minimum nodal C_L = 8.636638603847e-4 mol/m^3 | PASS for these samples |
| Preservation of fields during the separated solves | Maximum displacement transfer error 1.49e-23 m; stress transfer error 1.91e-6 Pa | PASS |
| Reported history consistency in projection and hydrogen | Transferred nodal fields agree closely; phase-average strain, rate, and stress match to the 14-digit CSV output precision | PASS, limited |

The mechanics stage fixes C_L and the previous projected stress at every nodal DOF.
The projection stage fixes the converged displacement and old C_L. The hydrogen
stage fixes the converged displacement and newly projected stress, retaining the
original hydrogen boundary conditions. Whole-domain FunctionDirichletBCs use the
RVE nodeset and SolutionUserObject/SolutionFunction to read the frozen fields.

Each stage recovers the **same original checkpoint**. The hydrogen stage does not
recover the already-advanced mechanics checkpoint: that would advance material
history twice and corrupt the plastic-strain rate. The meshes match exactly by
node ID. These checks do not compare every internal state variable pointwise at
every quadrature point. CP material averages in both projection and hydrogen are:

- Equivalent plastic strain: **2.8436615342109e-5**.
- Equivalent plastic strain rate: **0.0067515999231336 /s**.
- Hydrostatic stress: ferrite **95.163443 MPa**, pearlite **107.255733 MPa**.
- Pearlite equivalent plastic strain and rate are zero in the converged separated result.

Final lattice concentrations average **0.0014617804061729** in ferrite and
**0.0015009079285039 mol/m^3** in pearlite. Final minimum nodal concentration is
**0.00086371500213065 mol/m^3**.

## What stalls

During the failed step-17 replay, the residuals after Newton iteration 1 are:

| Variable | Scaled residual norm |
|---|---:|
| C_L | 4.91966 |
| hydrostatic_stress | 0.00417558 |
| disp_x | 0.00225055 |
| disp_y | 0.000467403 |
| disp_z | 0.00463257 |

The next iteration repeats these values and fails line search. A retry at
dt=0.000125 s stalls at total residual **0.5996951** and also fails line search.
The replay is bounded at that dtmin; it does not reproduce every smaller retry
from the user's original log. Its last accepted time remains 0.026875 s.

The recovered coupled control recalculates scaling and becomes dominated by the
stress-projection residual. It still fails. PETSc's line-search monitor shows
shrinking updates through 1e-2, 1e-3, and smaller factors without a residual
decrease. Recalculating scaling alone therefore does not fix this tested step.
Hydrogen dominance refers to the replay; stress-projection dominance refers to
the rescaled recovered control. Their residual magnitudes are not directly comparable.

Source inspection confirms that the assembled Jacobian omits:

- Displacement derivatives of the stress material in non-AD MaterialPropertyValue.
- Displacement derivatives of the plasticity-dependent hydrogen storage coefficient.
- Displacement derivatives of equivalent plastic strain/rate in DislocationTrapEvolution.

The stress-assisted hydrogen kernel does supply its projected-stress derivative.
SMP `full=true` cannot generate the missing material derivatives.

The separated tests show that hydrogen can converge with mechanics and stress
fixed. The missing cross derivatives are a strong explanation for the simultaneous
Newton failure, but their individual causal contribution has **not** been proved
by a complete Jacobian comparison or a run with all those derivatives restored.
Scaling and the approximate mechanical tangent can interact with line search.

For this one-way model, sequential mechanics → projection → hydrogen is a justified
next implementation: hydrogen does not feed back into the mechanics residual.
All three equations can be satisfied at the same time without a simultaneous
Newton direction. This has been demonstrated for one increment only.
A production implementation must preserve the beginning-of-step material history
through all three solves and commit the combined step once after all stages succeed.

## Larger-increment controls

These start from step 7 at 0.015875 s and attempt dt=0.008 s to 0.023875 s.

| Control | Observed result |
|---|---|
| Coupled solve, including recovered scaling control | FAIL: line-search divergence |
| Default local-tolerance mechanics | Stagnated at 2.004850e-5 after iteration 25; manually stopped, not a completed 50-iteration test |
| Coupled solve without line search | Cycled between approximately 5.8e-4 and 8.4e-3; stopped after iteration 24; not a reliable fix |
| Mechanics with improved local CP convergence | PASS: 27 iterations, residual 1.424882e-8 |
| Projection with those converged mechanics | PASS: 2 iterations |
| Hydrogen with those mechanics and projected stress fixed | PASS: 5 iterations, residual 7.116286e-14 |

The successful local-accuracy control sets cp_stress rtol=1e-10, abs_tol=1e-3 Pa,
and cp_update resistance_tol=1e-8. The hardening law and physical parameters are
unchanged. An earlier attempt with rtol=1e-10, the original abs_tol=1e-6 Pa, and
resistance_tol=1e-10 caused a constitutive failure before the first Newton iteration.
Its log is retained. Tighter tolerances are therefore not an unconditional remedy.

The large-step result also illustrates why solving an isolated mechanics problem
can demand more accuracy than the original coupled relative-residual criterion.
It should not be interpreted as proof that local CP accuracy causes the step-17
failure: default local tolerances pass isolated mechanics at step 17, and tighter
local tolerances do not rescue the simultaneous step-17 solve.

## Evidence and reproduction

Primary evidence:

- `x65_diagnostic_results/base.log`: replay and failed-step variable residuals.
- `step17_coupled.log`, `step17_coupled_tight.log`: recovered controls and line-search diagnostics.
- `step17_mechanics.log`, `step17_projection.log`, `step17_hydrogen.log`: successful stages.
- `field_checks.json`: full nodal-field transfer comparisons.
- `run_summary.json`: iteration counts, failure reasons, and production-input SHA256.
- `*_labelled.csv`: recovered CSV data with verified column labels restored.

MOOSE recovery appends CSV data without writing a new header. The labelled copies
use the original replay header and the additional material-property columns shown
in the output tables. Inherited, unexecuted postprocessor columns may contain zero;
they must not be treated as measurements. NONLINEAR CSV rows also use artificial
time offsets; use the log's step time to identify the physical time.

To repeat the main diagnostic with fresh output files:

```bash
source /home/ghostrobot96/miniforge/etc/profile.d/conda.sh
conda activate moose
./hyena-opt -i RVE_X65_test_run.i x65_diagnostic_monitor.i --n-threads=4 > /tmp/x65_diag_base.log 2>&1
# The preceding coupled replay is expected to exit with a convergence error.
mkdir -p /tmp/x65_diag_seed16_cp
cp -a /tmp/x65_diag_history_cp/0016-mesh.cpa.gz /tmp/x65_diag_history_cp/0016-restart-0.rd /tmp/x65_diag_seed16_cp/
./hyena-opt -i x65_diagnostic_restart_base.i x65_diagnostic_export16.i --n-threads=4
./hyena-opt -i x65_diagnostic_restart_base.i x65_diagnostic_step17_mechanics.i --recover /tmp/x65_diag_seed16_cp/0016 --n-threads=4 Executioner/TimeStepper/dt=0.00025
./hyena-opt -i x65_diagnostic_restart_base.i x65_diagnostic_step17_projection.i x65_diagnostic_properties.i --recover /tmp/x65_diag_seed16_cp/0016 --n-threads=4 Executioner/TimeStepper/dt=0.00025
./hyena-opt -i x65_diagnostic_restart_base.i x65_diagnostic_step17_hydrogen.i x65_diagnostic_properties.i --recover /tmp/x65_diag_seed16_cp/0016 --n-threads=4 Executioner/TimeStepper/dt=0.00025
```

The diagnostic base is a copy of the production input with initial-condition
declarations removed for restart and a ConstantDT stepper. Recovery preserves
the step count, old/older solution vectors, predictor, and material history.
An ordinary restart skips SimplePredictor on its first step; that was detected
and corrected before the matched stage comparisons.

## Limits

Full 10 s convergence remains unestablished. This work does not establish mesh or
time-step independence, hydrogen inventory/flux balance, calibration, or positivity
for all nonlinear trial states. Positive monitored concentrations do not prove
that every rejected line-search evaluation was positive.

Official references used alongside the installed source and the repository's
hydrogen implementation notes:

- [MOOSE restart and recovery](https://mooseframework.inl.gov/application_usage/restart_recover.html).
- [SimplePredictor](https://mooseframework.inl.gov/source/predictors/SimplePredictor.html).
- [SolutionUserObject](https://mooseframework.inl.gov/source/userobjects/SolutionUserObject.html) and [SolutionFunction](https://mooseframework.inl.gov/source/functions/SolutionFunction.html).
- [MaterialPropertyValue](https://mooseframework.inl.gov/source/kernels/MaterialPropertyValue.html).
- [CP stress update and local tolerances](https://mooseframework.inl.gov/source/materials/crystal_plasticity/ComputeMultipleCrystalPlasticityStress.html).

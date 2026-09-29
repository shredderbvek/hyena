#pragma once

#include "Kernel.h"

class HydrogenStressAssistedDiffusion : public Kernel
{
public:
  static InputParameters validParams();
  HydrogenStressAssistedDiffusion(const InputParameters & parameters);

protected:
  Real computeQpResidual() override;
  Real computeQpJacobian() override;
  Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const VariableGradient & _grad_hydrostatic_stress;
  const unsigned int _hydrostatic_stress_var;
  const Real _diffusivity;
  const Real _partial_molar_volume;
  const Real _gas_constant;
  const Real _temperature;
};

#pragma once

#include "Kernel.h"

class HydrogenFickDiffusion : public Kernel
{
public:
  static InputParameters validParams();
  HydrogenFickDiffusion(const InputParameters & parameters);

protected:
  Real computeQpResidual() override;
  Real computeQpJacobian() override;

  const Real _diffusivity;
};

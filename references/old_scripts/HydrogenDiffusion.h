#pragma once

#include "Kernel.h"

class HydrogenDiffusion : public Kernel
{
public:
  static InputParameters validParams();

  HydrogenDiffusion(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;

  virtual Real computeQpJacobian() override;

  const Real _D; // lattice diffusivity constant
};
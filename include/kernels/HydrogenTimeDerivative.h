#pragma once

#include "TimeKernel.h"

class HydrogenTimeDerivative : public TimeKernel
{
public:
  static InputParameters validParams();
  HydrogenTimeDerivative(const InputParameters & parameters);

protected:
  Real computeQpResidual() override;
  Real computeQpJacobian() override;

  const MaterialProperty<Real> & _coefficient;
  const MaterialProperty<Real> & _coefficient_derivative;
};

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
  Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const MaterialProperty<Real> & _coefficient;
  const MaterialProperty<Real> & _coefficient_derivative;
  const MaterialProperty<Real> & _coefficient_plastic_strain_derivative;
  const unsigned int _plastic_strain_var;
  const bool _has_plastic_strain;
};

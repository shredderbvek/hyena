#pragma once

#include "TimeKernel.h"

/**
 * Mass-lumped form of HydrogenTimeDerivative. Each node stores hydrogen according to its own
 * nodal rate, which keeps the backward-Euler storage matrix diagonal and avoids the undershoot
 * of the consistent mass matrix near sharp concentration changes.
 */
class HydrogenLumpedTimeDerivative : public TimeKernel
{
public:
  static InputParameters validParams();
  HydrogenLumpedTimeDerivative(const InputParameters & parameters);

protected:
  Real computeQpResidual() override;
  Real computeQpJacobian() override;

  const VariableValue & _u_dot_nodal;
  const MaterialProperty<Real> & _coefficient;
  const MaterialProperty<Real> & _coefficient_derivative;
};

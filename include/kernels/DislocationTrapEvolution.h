#pragma once

#include "Kernel.h"

class DislocationTrapEvolution : public Kernel
{
public:
  static InputParameters validParams();
  DislocationTrapEvolution(const InputParameters & parameters);

protected:
  Real computeQpResidual() override;
  Real computeQpJacobian() override;
  Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const VariableValue & _plastic_strain_dot;
  const VariableValue & _plastic_strain_dot_du;
  const unsigned int _plastic_strain_var;
  const MaterialProperty<Real> & _trap_occupancy;
  const MaterialProperty<Real> & _trap_occupancy_derivative;
  const MaterialProperty<Real> & _trap_density_derivative;
  const MaterialProperty<Real> & _trap_density_second_derivative;
};

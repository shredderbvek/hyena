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
  const MaterialProperty<Real> & _plastic_strain_rate;
  const MaterialProperty<Real> & _trap_occupancy;
  const MaterialProperty<Real> & _trap_occupancy_derivative;
  const MaterialProperty<Real> & _trap_density_derivative;
};

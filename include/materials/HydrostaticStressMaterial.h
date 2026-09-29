#pragma once

#include "Material.h"
#include "RankTwoTensor.h"

class HydrostaticStressMaterial : public Material
{
public:
  static InputParameters validParams();
  HydrostaticStressMaterial(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  const MaterialProperty<RankTwoTensor> & _stress;
  MaterialProperty<Real> & _hydrostatic_stress;
};

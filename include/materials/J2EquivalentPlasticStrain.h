#pragma once

#include "Material.h"
#include "RankTwoTensor.h"

class J2EquivalentPlasticStrain : public Material
{
public:
  static InputParameters validParams();
  J2EquivalentPlasticStrain(const InputParameters & parameters);

protected:
  void initQpStatefulProperties() override;
  void computeQpProperties() override;

  const std::string _base_name;
  const MaterialProperty<Real> & _effective_plastic_strain;
  const MaterialProperty<Real> & _effective_plastic_strain_old;
  const MaterialProperty<RankTwoTensor> & _stress; // dependency on J2 stress update ordering
  MaterialProperty<Real> & _equivalent_plastic_strain;
  MaterialProperty<Real> & _equivalent_plastic_strain_rate;
};

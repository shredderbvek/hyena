#pragma once

#include "Material.h"

class CPEquivalentPlasticStrain : public Material
{
public:
  static InputParameters validParams();
  CPEquivalentPlasticStrain(const InputParameters & parameters);

protected:
  void initQpStatefulProperties() override;
  void computeQpProperties() override;

  const std::string _base_name;
  const unsigned int _number_slip_systems;
  const MaterialProperty<std::vector<Real>> & _slip_increment;
  const MaterialProperty<std::vector<RankTwoTensor>> & _flow_direction;
  const MaterialProperty<RankTwoTensor> & _stress; // dependency on CP stress update ordering
  const MaterialProperty<Real> & _equivalent_plastic_strain_old;
  MaterialProperty<Real> & _equivalent_plastic_strain;
  MaterialProperty<Real> & _equivalent_plastic_strain_rate;
};

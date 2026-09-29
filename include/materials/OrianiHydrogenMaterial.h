#pragma once

#include "Material.h"

class OrianiHydrogenMaterial : public Material
{
public:
  static InputParameters validParams();
  OrianiHydrogenMaterial(const InputParameters & parameters);

protected:
  void computeQpProperties() override;

  const VariableValue & _lattice_concentration;
  const OptionalMaterialProperty<Real> & _plastic_strain;
  const Real _lattice_site_density;
  const Real _reference_trap_density;
  const Real _binding_energy;
  const Real _gas_constant;
  const Real _temperature;
  MaterialProperty<Real> & _time_coefficient;
  MaterialProperty<Real> & _time_coefficient_derivative;
  MaterialProperty<Real> & _trap_occupancy;
  MaterialProperty<Real> & _trap_occupancy_derivative;
  MaterialProperty<Real> & _trap_density_derivative;
};

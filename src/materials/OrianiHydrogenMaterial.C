#include "OrianiHydrogenMaterial.h"

#include <cmath>

registerMooseObject("HyenaApp", OrianiHydrogenMaterial);

InputParameters
OrianiHydrogenMaterial::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("Compute one-trap Oriani occupancy and hydrogen storage coefficients.");
  params.addRequiredCoupledVar("lattice_concentration", "Lattice hydrogen concentration");
  params.addRequiredParam<Real>("lattice_site_density", "Lattice interstitial site density");
  params.addRequiredParam<Real>("reference_trap_density", "Dislocation trap density prefactor in the plastic-strain law");
  params.addRequiredParam<Real>("binding_energy", "Trap binding energy; negative for a favorable trap");
  params.addParam<Real>("gas_constant", 8.314462618, "Gas constant");
  params.addRequiredParam<Real>("temperature", "Absolute temperature");
  return params;
}

OrianiHydrogenMaterial::OrianiHydrogenMaterial(const InputParameters & parameters)
  : Material(parameters),
    _lattice_concentration(coupledValue("lattice_concentration")),
    _plastic_strain(getOptionalMaterialProperty<Real>("equivalent_plastic_strain")),
    _lattice_site_density(getParam<Real>("lattice_site_density")),
    _reference_trap_density(getParam<Real>("reference_trap_density")),
    _binding_energy(getParam<Real>("binding_energy")),
    _gas_constant(getParam<Real>("gas_constant")),
    _temperature(getParam<Real>("temperature")),
    _time_coefficient(declareProperty<Real>("hydrogen_time_coefficient")),
    _time_coefficient_derivative(declareProperty<Real>("dhydrogen_time_coefficient_dC")),
    _trap_occupancy(declareProperty<Real>("dislocation_trap_occupancy")),
    _trap_occupancy_derivative(declareProperty<Real>("ddislocation_trap_occupancy_dC")),
    _trap_density_derivative(declareProperty<Real>("dislocation_trap_density_derivative"))
{
}

void
OrianiHydrogenMaterial::computeQpProperties()
{
  const Real concentration = _lattice_concentration[_qp];
  const Real plastic_strain = _plastic_strain ? _plastic_strain[_qp] : 0.0;
  const Real K = std::exp(-_binding_energy / (_gas_constant * _temperature));
  const Real trap_density = _reference_trap_density *
                            std::pow(10.0, -2.33 * std::exp(-5.5 * plastic_strain));
  const Real denominator = _lattice_site_density + K * concentration;
  const Real occupancy = K * concentration / denominator;

  _trap_occupancy[_qp] = occupancy;
  _trap_occupancy_derivative[_qp] =
      K * _lattice_site_density / (denominator * denominator);
  _time_coefficient[_qp] = 1.0 + K * _lattice_site_density * trap_density /
                                      (denominator * denominator);
  _time_coefficient_derivative[_qp] =
      -2.0 * K * K * _lattice_site_density * trap_density /
      (denominator * denominator * denominator);
  const Real trap_density_rate_coefficient =
      2.33 * 5.5 * std::log(10.0) * std::exp(-5.5 * plastic_strain);
  _trap_density_derivative[_qp] = trap_density_rate_coefficient * trap_density;
}

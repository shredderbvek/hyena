#include "HydrogenStressAssistedDiffusion.h"

registerMooseObject("HyenaApp", HydrogenStressAssistedDiffusion);

InputParameters
HydrogenStressAssistedDiffusion::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addClassDescription("Stress-assisted lattice hydrogen diffusion using the FE gradient of hydrostatic stress.");
  params.addRequiredCoupledVar("hydrostatic_stress", "Projected hydrostatic stress field");
  params.addRequiredParam<Real>("diffusivity", "Lattice diffusivity");
  params.addRequiredParam<Real>("partial_molar_volume", "Partial molar volume of hydrogen");
  params.addParam<Real>("gas_constant", 8.314462618, "Gas constant");
  params.addRequiredParam<Real>("temperature", "Absolute temperature");
  return params;
}

HydrogenStressAssistedDiffusion::HydrogenStressAssistedDiffusion(const InputParameters & parameters)
  : Kernel(parameters),
    _grad_hydrostatic_stress(coupledGradient("hydrostatic_stress")),
    _hydrostatic_stress_var(coupled("hydrostatic_stress")),
    _diffusivity(getParam<Real>("diffusivity")),
    _partial_molar_volume(getParam<Real>("partial_molar_volume")),
    _gas_constant(getParam<Real>("gas_constant")),
    _temperature(getParam<Real>("temperature"))
{
}

Real
HydrogenStressAssistedDiffusion::computeQpResidual()
{
  return -_diffusivity * _partial_molar_volume / (_gas_constant * _temperature) *
         _u[_qp] * (_grad_hydrostatic_stress[_qp] * _grad_test[_i][_qp]);
}

Real
HydrogenStressAssistedDiffusion::computeQpJacobian()
{
  return -_diffusivity * _partial_molar_volume / (_gas_constant * _temperature) *
         _phi[_j][_qp] * (_grad_hydrostatic_stress[_qp] * _grad_test[_i][_qp]);
}

Real
HydrogenStressAssistedDiffusion::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _hydrostatic_stress_var)
    return -_diffusivity * _partial_molar_volume / (_gas_constant * _temperature) *
           _u[_qp] * (_grad_phi[_j][_qp] * _grad_test[_i][_qp]);
  return 0.0;
}

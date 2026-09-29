#include "HydrogenFickDiffusion.h"

registerMooseObject("HyenaApp", HydrogenFickDiffusion);

InputParameters
HydrogenFickDiffusion::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addClassDescription("Fickian lattice hydrogen diffusion with constant diffusivity.");
  params.addRequiredParam<Real>("diffusivity", "Lattice hydrogen diffusivity");
  return params;
}

HydrogenFickDiffusion::HydrogenFickDiffusion(const InputParameters & parameters)
  : Kernel(parameters), _diffusivity(getParam<Real>("diffusivity"))
{
}

Real
HydrogenFickDiffusion::computeQpResidual()
{
  return _diffusivity * (_grad_u[_qp] * _grad_test[_i][_qp]);
}

Real
HydrogenFickDiffusion::computeQpJacobian()
{
  return _diffusivity * (_grad_phi[_j][_qp] * _grad_test[_i][_qp]);
}

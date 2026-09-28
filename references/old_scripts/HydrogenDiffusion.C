#include "HydrogenDiffusion.h"

registerMooseObject("cpfe_heApp", HydrogenDiffusion);

InputParameters
HydrogenDiffusion::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addClassDescription("The Laplacian operator ($-\\nabla \\cdot \\nabla u$), with the weak "
                             "form of $(\\nabla \\phi_i, D \\nabla u_h)$.");
  params.addRequiredParam<Real>("D", "lattice diffusivity : constant value");
  return params;
}

HydrogenDiffusion::HydrogenDiffusion(const InputParameters & parameters) : Kernel(parameters), _D(getParam<Real>("D")) {}

Real
HydrogenDiffusion::computeQpResidual()
{
  return _D * _grad_u[_qp] * _grad_test[_i][_qp];
}

Real
HydrogenDiffusion::computeQpJacobian()
{
  return _D * _grad_phi[_j][_qp] * _grad_test[_i][_qp];
}
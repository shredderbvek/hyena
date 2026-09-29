#include "HydrogenTimeDerivative.h"

registerMooseObject("HyenaApp", HydrogenTimeDerivative);

InputParameters
HydrogenTimeDerivative::validParams()
{
  InputParameters params = TimeKernel::validParams();
  params.addClassDescription("Lattice hydrogen storage with one Oriani-equilibrium trap.");
  return params;
}

HydrogenTimeDerivative::HydrogenTimeDerivative(const InputParameters & parameters)
  : TimeKernel(parameters),
    _coefficient(getMaterialProperty<Real>("hydrogen_time_coefficient")),
    _coefficient_derivative(getMaterialProperty<Real>("dhydrogen_time_coefficient_dC"))
{
}

Real
HydrogenTimeDerivative::computeQpResidual()
{
  return _test[_i][_qp] * _coefficient[_qp] * _u_dot[_qp];
}

Real
HydrogenTimeDerivative::computeQpJacobian()
{
  return _test[_i][_qp] *
         (_coefficient[_qp] * _phi[_j][_qp] * _du_dot_du[_qp] +
          _coefficient_derivative[_qp] * _phi[_j][_qp] * _u_dot[_qp]);
}

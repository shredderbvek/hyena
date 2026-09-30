#include "HydrogenLumpedTimeDerivative.h"

registerMooseObject("HyenaApp", HydrogenLumpedTimeDerivative);

InputParameters
HydrogenLumpedTimeDerivative::validParams()
{
  InputParameters params = TimeKernel::validParams();
  params.addClassDescription(
      "Mass-lumped lattice hydrogen storage with one Oriani-equilibrium trap: "
      "(psi_i, A) times the nodal rate of the lattice concentration.");
  return params;
}

HydrogenLumpedTimeDerivative::HydrogenLumpedTimeDerivative(const InputParameters & parameters)
  : TimeKernel(parameters),
    _u_dot_nodal(_var.dofValuesDot()),
    _coefficient(getMaterialProperty<Real>("hydrogen_time_coefficient")),
    _coefficient_derivative(getMaterialProperty<Real>("dhydrogen_time_coefficient_dC"))
{
}

Real
HydrogenLumpedTimeDerivative::computeQpResidual()
{
  return _test[_i][_qp] * _coefficient[_qp] * _u_dot_nodal[_i];
}

Real
HydrogenLumpedTimeDerivative::computeQpJacobian()
{
  // The nodal rate depends only on its own dof; the coefficient depends on C_L at the qp
  const Real rate_derivative = _i == _j ? _coefficient[_qp] * _du_dot_du[_qp] : 0.0;
  return _test[_i][_qp] *
         (rate_derivative + _coefficient_derivative[_qp] * _phi[_j][_qp] * _u_dot_nodal[_i]);
}

#include "HydrogenTimeDerivative.h"

registerMooseObject("HyenaApp", HydrogenTimeDerivative);

InputParameters
HydrogenTimeDerivative::validParams()
{
  InputParameters params = TimeKernel::validParams();
  params.addClassDescription("Lattice hydrogen storage with one Oriani-equilibrium trap.");
  params.addCoupledVar("plastic_strain", 0.0, "Equivalent plastic strain driving dislocation trap density");
  return params;
}

HydrogenTimeDerivative::HydrogenTimeDerivative(const InputParameters & parameters)
  : TimeKernel(parameters),
    _coefficient(getMaterialProperty<Real>("hydrogen_time_coefficient")),
    _coefficient_derivative(getMaterialProperty<Real>("dhydrogen_time_coefficient_dC")),
    _coefficient_plastic_strain_derivative(
        getMaterialProperty<Real>("dhydrogen_time_coefficient_deps")),
    _plastic_strain_var(coupled("plastic_strain")),
    _has_plastic_strain(isCoupled("plastic_strain"))
{
}

Real
HydrogenTimeDerivative::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (_has_plastic_strain && jvar == _plastic_strain_var)
    return _test[_i][_qp] * _coefficient_plastic_strain_derivative[_qp] *
           _u_dot[_qp] * _phi[_j][_qp];
  return 0.0;
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

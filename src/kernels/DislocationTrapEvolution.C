#include "DislocationTrapEvolution.h"

registerMooseObject("HyenaApp", DislocationTrapEvolution);

InputParameters
DislocationTrapEvolution::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addClassDescription("Hydrogen storage change caused by evolving dislocation trap density.");
  params.addRequiredCoupledVar("plastic_strain", "Equivalent plastic strain");
  return params;
}

DislocationTrapEvolution::DislocationTrapEvolution(const InputParameters & parameters)
  : Kernel(parameters),
    _plastic_strain_dot(coupledDot("plastic_strain")),
    _plastic_strain_dot_du(coupledDotDu("plastic_strain")),
    _plastic_strain_var(coupled("plastic_strain")),
    _trap_occupancy(getMaterialProperty<Real>("dislocation_trap_occupancy")),
    _trap_occupancy_derivative(getMaterialProperty<Real>("ddislocation_trap_occupancy_dC")),
    _trap_density_derivative(getMaterialProperty<Real>("dislocation_trap_density_derivative")),
    _trap_density_second_derivative(
        getMaterialProperty<Real>("dislocation_trap_density_second_derivative"))
{
}

Real
DislocationTrapEvolution::computeQpResidual()
{
  return _test[_i][_qp] * _trap_occupancy[_qp] * _trap_density_derivative[_qp] *
         _plastic_strain_dot[_qp];
}

Real
DislocationTrapEvolution::computeQpJacobian()
{
  return _test[_i][_qp] * _trap_occupancy_derivative[_qp] *
         _trap_density_derivative[_qp] * _plastic_strain_dot[_qp] * _phi[_j][_qp];
}

Real
DislocationTrapEvolution::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _plastic_strain_var)
    return _test[_i][_qp] *
           (_trap_occupancy[_qp] * _trap_density_second_derivative[_qp] *
                _plastic_strain_dot[_qp] +
            _trap_occupancy[_qp] * _trap_density_derivative[_qp] *
                _plastic_strain_dot_du[_qp]) *
           _phi[_j][_qp];
  return 0.0;
}

#include "DislocationTrapEvolution.h"

registerMooseObject("HyenaApp", DislocationTrapEvolution);

InputParameters
DislocationTrapEvolution::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addClassDescription("Hydrogen storage change caused by evolving dislocation trap density.");
  return params;
}

DislocationTrapEvolution::DislocationTrapEvolution(const InputParameters & parameters)
  : Kernel(parameters),
    _plastic_strain_rate(getMaterialProperty<Real>("equivalent_plastic_strain_rate")),
    _trap_occupancy(getMaterialProperty<Real>("dislocation_trap_occupancy")),
    _trap_occupancy_derivative(getMaterialProperty<Real>("ddislocation_trap_occupancy_dC")),
    _trap_density_derivative(getMaterialProperty<Real>("dislocation_trap_density_derivative"))
{
}

Real
DislocationTrapEvolution::computeQpResidual()
{
  return _test[_i][_qp] * _trap_occupancy[_qp] * _trap_density_derivative[_qp] *
         _plastic_strain_rate[_qp];
}

Real
DislocationTrapEvolution::computeQpJacobian()
{
  return _test[_i][_qp] * _trap_occupancy_derivative[_qp] *
         _trap_density_derivative[_qp] * _plastic_strain_rate[_qp] * _phi[_j][_qp];
}

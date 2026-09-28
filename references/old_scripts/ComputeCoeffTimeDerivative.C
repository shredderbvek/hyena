#include "ComputeCoeffTimeDerivative.h"
#include <cmath>

registerMooseObject("cpfe_heApp", ComputeCoeffTimeDerivative);

InputParameters
ComputeCoeffTimeDerivative::validParams()
{
    InputParameters params = Kernel::validParams();
    params.addClassDescription("Time derivative kernel that acts on coupled variable with a scalar coefficient term.");
    params.addParam<MaterialPropertyName>("lattice_diffusivity","lattice diffusivity constant");
    params.addParam<MaterialPropertyName>("lattice_density", " hydrogen lattice density");
    params.addParam<MaterialPropertyName>("binding_energy", " binding energy for dislocation trap");
    params.addParam<MaterialPropertyName>("gas_constant", " gas constant");
    params.addParam<MaterialPropertyName>("abs_temp", "absolute temperature");
    params.addParam<MaterialPropertyName>("dis_trap_density", "dislocation trap density");
    params.addRequiredCoupledVar("C_L", "Coupled Variable: Lattice Hydrogen concentration");
    return params;
}

ComputeCoeffTimeDerivative::ComputeCoeffTimeDerivative(const InputParameters & parameters)
: Kernel(parameters),
 _D(getMaterialProperty<Real>("lattice_diffusivity")),
 _N_L(getMaterialProperty<Real>("lattice_density")),
 _W_B(getMaterialProperty<Real>("binding_energy")),
 _R(getMaterialProperty<Real>("gas_constant")),
 _T(getMaterialProperty<Real>("abs_temp")),
 _N_T(getMaterialProperty<Real>("dis_trap_density")),
 _C_L_dot(coupledDot("C_L")),
 _dC_L_dot(coupledDotDu("C_L")),
 _C_L_var(coupled("C_L")),
 _C_L_val(coupledValue("C_L")),
 _coeff(0.0)
{
}

Real
ComputeCoeffTimeDerivative::computeQpResidual()
{
    const Real _C_L = _C_L_val[_qp];
    if (_C_L <= 0.0)
        return 0.0;

    const Real _K = std::exp(- _W_B[_qp] / (_R[_qp] * _T[_qp])); // computation of equilibrium constant
    const Real _C_T = (_K * _C_L * _N_T[_qp]) / (_N_L[_qp] + _K * _C_L); // computation of trap concentration ( dislocation)
    const Real _theta_T = _C_T / _N_T[_qp]; // computation of dislocation trap occupancy

    _coeff = (_C_L + _C_T * (1 - _theta_T)) / _C_L; // calculation of coefficient term of the time derivative kernel

    return _test[_i][_qp] * _coeff * _C_L_dot[_qp]; 
}

Real
ComputeCoeffTimeDerivative::computeQpJacobian()
{
    return 0.0;
}

Real
ComputeCoeffTimeDerivative::computeQpOffDiagJacobian(unsigned int jvar)
{
    if (jvar == _C_L_var)
        return _test[_i][_qp] * _phi[_j][_qp] * _coeff * _dC_L_dot[_qp];

    return 0.0;
}
#pragma once

#include "Kernel.h"
#include <cmath>

class ComputeCoeffTimeDerivative : public Kernel
{
    public:
        static InputParameters validParams();
        ComputeCoeffTimeDerivative(const InputParameters & parameters);

    protected:
        virtual Real computeQpResidual() override;
        virtual Real computeQpJacobian() override;
        virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

    private:
        const MaterialProperty<Real> & _D; // lattice diffusivity constant
        const MaterialProperty<Real> & _N_L; // Lattice trap density (dislocation)
        const MaterialProperty<Real> & _W_B; // Binding engergy for trap (dislocation)
        const MaterialProperty<Real> & _R; // gas constant
        const MaterialProperty<Real> & _T; // absolute temperature
        const MaterialProperty<Real> & _N_T; // Dislocation trap density 
        const VariableValue & _C_L_dot;
        const VariableValue & _dC_L_dot;
        const unsigned int _C_L_var;
        const VariableValue & _C_L_val;
        Real _coeff; // (C_L +  C_T * (1 - theta_T)) / C_L
};

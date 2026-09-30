#include "J2ConsistentTangentStressUpdate.h"

#include "Function.h"

registerMooseObject("HyenaApp", J2ConsistentTangentStressUpdate);

InputParameters
J2ConsistentTangentStressUpdate::validParams()
{
  InputParameters params = IsotropicPlasticityStressUpdate::validParams();
  params.addClassDescription("J2 isotropic plasticity (IsotropicPlasticityStressUpdate) returning "
                             "the consistent tangent operator instead of the elastic one.");
  return params;
}

J2ConsistentTangentStressUpdate::J2ConsistentTangentStressUpdate(const InputParameters & parameters)
  : IsotropicPlasticityStressUpdate(parameters)
{
}

Real
J2ConsistentTangentStressUpdate::computeStressDerivative(const Real /*effective_trial_stress*/,
                                                         const Real scalar)
{
  // On the yield surface sigma_e = sigma_f(eps_p_old + d_eps_p), so d(d_eps_p)/d(sigma_e) = 1/H
  // with H the hardening slope at the updated plastic strain.
  const Real slope =
      _hardening_function
          ? _hardening_function->timeDerivative(_effective_inelastic_strain_old[_qp] + scalar)
          : _hardening_constant;

  // A non-positive slope has no finite inverse. Returning zero keeps the flow-direction
  // stiffness elastic while the transverse deviatoric terms stay consistent. This is not
  // MOOSE's elastic tangent.
  return slope > 0.0 ? 1.0 / slope : 0.0;
}

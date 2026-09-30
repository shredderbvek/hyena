#pragma once

#include "IsotropicPlasticityStressUpdate.h"

/**
 * IsotropicPlasticityStressUpdate with the consistent (PARTIAL) tangent operator. The base class
 * returns the elastic tangent, which gives only linear Newton convergence once material yields.
 */
class J2ConsistentTangentStressUpdate : public IsotropicPlasticityStressUpdate
{
public:
  static InputParameters validParams();
  J2ConsistentTangentStressUpdate(const InputParameters & parameters);

  TangentCalculationMethod getTangentCalculationMethod() override
  {
    return TangentCalculationMethod::PARTIAL;
  }

protected:
  Real computeStressDerivative(const Real effective_trial_stress, const Real scalar) override;
};

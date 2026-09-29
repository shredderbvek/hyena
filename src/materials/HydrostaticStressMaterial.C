#include "HydrostaticStressMaterial.h"

registerMooseObject("HyenaApp", HydrostaticStressMaterial);

InputParameters
HydrostaticStressMaterial::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("Compute tensile-positive hydrostatic stress as one-third the Cauchy stress trace.");
  params.addParam<MaterialPropertyName>("stress", "stress", "Cauchy stress tensor property");
  params.addParam<MaterialPropertyName>("hydrostatic_stress", "hydrostatic_stress", "Output tensile-positive hydrostatic stress");
  return params;
}

HydrostaticStressMaterial::HydrostaticStressMaterial(const InputParameters & parameters)
  : Material(parameters),
    _stress(getMaterialProperty<RankTwoTensor>(getParam<MaterialPropertyName>("stress"))),
    _hydrostatic_stress(declareProperty<Real>(getParam<MaterialPropertyName>("hydrostatic_stress")))
{
}

void
HydrostaticStressMaterial::computeQpProperties()
{
  _hydrostatic_stress[_qp] = _stress[_qp].trace() / 3.0;
}

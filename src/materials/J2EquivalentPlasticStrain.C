#include "J2EquivalentPlasticStrain.h"

registerMooseObject("HyenaApp", J2EquivalentPlasticStrain);

InputParameters
J2EquivalentPlasticStrain::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription(
      "Expose the J2 radial-return effective plastic strain and its rate as the equivalent "
      "plastic strain used by the hydrogen trapping model.");
  params.addParam<std::string>("base_name", "Optional J2 plasticity material property prefix");
  return params;
}

J2EquivalentPlasticStrain::J2EquivalentPlasticStrain(const InputParameters & parameters)
  : Material(parameters),
    _base_name(isParamValid("base_name") ? getParam<std::string>("base_name") + "_" : ""),
    _effective_plastic_strain(getMaterialProperty<Real>(_base_name + "effective_plastic_strain")),
    _effective_plastic_strain_old(
        getMaterialPropertyOld<Real>(_base_name + "effective_plastic_strain")),
    _stress(getMaterialProperty<RankTwoTensor>(_base_name + "stress")),
    _equivalent_plastic_strain(declareProperty<Real>("equivalent_plastic_strain")),
    _equivalent_plastic_strain_rate(declareProperty<Real>("equivalent_plastic_strain_rate"))
{
}

void
J2EquivalentPlasticStrain::initQpStatefulProperties()
{
  _equivalent_plastic_strain[_qp] = 0.0;
  _equivalent_plastic_strain_rate[_qp] = 0.0;
}

void
J2EquivalentPlasticStrain::computeQpProperties()
{
  _equivalent_plastic_strain[_qp] = _effective_plastic_strain[_qp];
  _equivalent_plastic_strain_rate[_qp] =
      (_effective_plastic_strain[_qp] - _effective_plastic_strain_old[_qp]) / _dt;
}

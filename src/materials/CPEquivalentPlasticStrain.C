#include "CPEquivalentPlasticStrain.h"

#include "libmesh/utility.h"
#include "libmesh/int_range.h"

#include <cmath>

registerMooseObject("HyenaApp", CPEquivalentPlasticStrain);

InputParameters
CPEquivalentPlasticStrain::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription(
      "Compute accumulated equivalent plastic strain and its rate from crystal-plasticity slip.");
  params.addRequiredParam<unsigned int>("number_slip_systems", "Number of crystal slip systems");
  params.addParam<std::string>("base_name", "Optional crystal-plasticity material property prefix");
  return params;
}

CPEquivalentPlasticStrain::CPEquivalentPlasticStrain(const InputParameters & parameters)
  : Material(parameters),
    _base_name(isParamValid("base_name") ? getParam<std::string>("base_name") + "_" : ""),
    _number_slip_systems(getParam<unsigned int>("number_slip_systems")),
    _slip_increment(getMaterialProperty<std::vector<Real>>(_base_name + "slip_increment")),
    _flow_direction(
        getMaterialProperty<std::vector<RankTwoTensor>>(_base_name + "flow_direction")),
    _stress(getMaterialProperty<RankTwoTensor>(_base_name + "stress")),
    _equivalent_plastic_strain_old(getMaterialPropertyOld<Real>("equivalent_plastic_strain")),
    _equivalent_plastic_strain(declareProperty<Real>("equivalent_plastic_strain")),
    _equivalent_plastic_strain_rate(declareProperty<Real>("equivalent_plastic_strain_rate"))
{
}

void
CPEquivalentPlasticStrain::initQpStatefulProperties()
{
  _equivalent_plastic_strain[_qp] = 0.0;
  _equivalent_plastic_strain_rate[_qp] = 0.0;
}

void
CPEquivalentPlasticStrain::computeQpProperties()
{
  RankTwoTensor plastic_velocity_gradient;
  for (const auto i : make_range(_number_slip_systems))
    plastic_velocity_gradient += _flow_direction[_qp][i] * _slip_increment[_qp][i];

  const RankTwoTensor plastic_rate_of_deformation =
      0.5 * (plastic_velocity_gradient + plastic_velocity_gradient.transpose());
  _equivalent_plastic_strain_rate[_qp] =
      std::sqrt((2.0 / 3.0) * plastic_rate_of_deformation.doubleContraction(
                                    plastic_rate_of_deformation));
  _equivalent_plastic_strain[_qp] =
      _equivalent_plastic_strain_old[_qp] + _dt * _equivalent_plastic_strain_rate[_qp];
}

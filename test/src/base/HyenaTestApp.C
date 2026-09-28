//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "HyenaTestApp.h"
#include "HyenaApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
HyenaTestApp::validParams()
{
  InputParameters params = HyenaApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

HyenaTestApp::HyenaTestApp(const InputParameters & parameters) : MooseApp(parameters)
{
  HyenaTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

HyenaTestApp::~HyenaTestApp() {}

void
HyenaTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  HyenaApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"HyenaTestApp"});
    Registry::registerActionsTo(af, {"HyenaTestApp"});
  }
}

void
HyenaTestApp::registerApps()
{
  registerApp(HyenaApp);
  registerApp(HyenaTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
HyenaTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  HyenaTestApp::registerAll(f, af, s);
}
extern "C" void
HyenaTestApp__registerApps()
{
  HyenaTestApp::registerApps();
}

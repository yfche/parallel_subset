//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "IntegratedBC.h"
#include "MooseTypes.h"

class Function;

/**
 * Pressure applies a pressure on a given boundary in the direction defined by component
 */
class Pressure : public IntegratedBC
{
public:
  static InputParameters validParams();

  Pressure(const InputParameters & parameters);

protected:
  virtual void initialSetup() override;
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;

  Real computeFactor();

  const int _component;

  const Real _factor;

  const Function * const _function;

  const PostprocessorValue * const _postprocessor;

  /// _alpha Parameter for HHT time integration scheme
  const Real _alpha;

  /// Whether to use the displaced mesh
  const bool _use_displaced_mesh;

  /// Coordinate system type
  Moose::CoordinateSystemType _coord_type;
};

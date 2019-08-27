#pragma once

#include "HeatTransferFromTemperature1Phase.h"

class HeatTransferFromExternalAppTemperature1Phase;

template <>
InputParameters validParams<HeatTransferFromExternalAppTemperature1Phase>();

/**
 * Heat transfer into 1-phase flow channel from temperature provided by an external application
 */
class HeatTransferFromExternalAppTemperature1Phase : public HeatTransferFromTemperature1Phase
{
public:
  HeatTransferFromExternalAppTemperature1Phase(const InputParameters & parameters);

  virtual void addVariables() override;
  virtual void addMooseObjects() override;

protected:
  virtual const FEType & getFEType() override;
  virtual void check() const override;

  /// Name of the function specifying initial condition for wall temperature
  const FunctionName _T_wall_fn_name;
  /// The type of the wall temperature variable
  FEType _fe_type;
};

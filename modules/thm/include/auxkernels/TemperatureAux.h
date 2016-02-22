#ifndef TEMPERATUREAUX_H
#define TEMPERATUREAUX_H

#include "AuxKernel.h"

// Forward Declarations
class TemperatureAux;
class Function;
class SinglePhaseCommonFluidProperties;

template<>
InputParameters validParams<TemperatureAux>();

/**
 * Computes temperature from fluid properties user object
 */
class TemperatureAux : public AuxKernel
{
public:
  TemperatureAux(const InputParameters & parameters);
  virtual ~TemperatureAux();

protected:
  virtual Real computeValue();

  const VariableValue & _rho;
  const VariableValue & _rhou;
  const VariableValue & _rhoE;

  const SinglePhaseCommonFluidProperties & _spfp;
};

#endif

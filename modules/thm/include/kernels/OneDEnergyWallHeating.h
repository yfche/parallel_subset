#ifndef ONEDENERGYWALLHEATING_H
#define ONEDENERGYWALLHEATING_H

#include "Kernel.h"

// Forward Declarations
class OneDEnergyWallHeating;

template<>
InputParameters validParams<OneDEnergyWallHeating>();

// The spatial part of the 1D energy conservation for Navier-Stokes flow
class OneDEnergyWallHeating : public Kernel
{
public:
  OneDEnergyWallHeating(const std::string & name, InputParameters parameters);
  virtual ~OneDEnergyWallHeating();

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);

  const MaterialProperty<Real> & _temperature;
  const MaterialProperty<Real> & _dT_drhoA;
  const MaterialProperty<Real> & _dT_drhouA;
  const MaterialProperty<Real> & _dT_drhoEA;

  VariableValue & _heat_transfer_coefficient;
  VariableValue & _Tw;
  VariableValue & _Phf;

  // For Jacobian terms
  unsigned _rhoA_var_number;
  unsigned _rhouA_var_number;

};

#endif //ONEDENERGYWALLHEATING_H

#pragma once

#include "Material.h"
#include "DerivativeMaterialInterfaceTHM.h"

class WallFrictionChurchillMaterial;

template <>
InputParameters validParams<WallFrictionChurchillMaterial>();

/**
 * Computes drag coefficient using the Churchill formula for Fanning friction factor
 */
class WallFrictionChurchillMaterial : public DerivativeMaterialInterfaceTHM<Material>
{
public:
  WallFrictionChurchillMaterial(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

  /// Darcy wall friction coefficient
  const MaterialPropertyName _f_D_name;
  MaterialProperty<Real> & _f_D;
  MaterialProperty<Real> & _df_D_drhoA;
  MaterialProperty<Real> & _df_D_drhouA;
  MaterialProperty<Real> & _df_D_drhoEA;

  /// Dynamic viscosity
  const MaterialProperty<Real> & _mu;

  /// Density of the phase
  const MaterialProperty<Real> & _rho;
  /// Velocity (x-component)
  const MaterialProperty<Real> & _vel;
  /// Hydraulic diameter
  const MaterialProperty<Real> & _D_h;
  /// Roughness of the surface
  const Real & _roughness;
};

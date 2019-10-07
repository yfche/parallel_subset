# Tests the derivatives of the total enthalpy material property for the 7-equation model.

[JacobianTest2Phase]
  A = 1e2
  alpha_vapor = 0.3
  p_liquid = 1e6
  p_vapor = 2e6
  T_liquid = 300
  T_vapor = 500
  vel_liquid = 2
  vel_vapor = 4
  snes_test_err = 1e-8
  fp_2phase = fp_2phase
[]

[FluidProperties]
  [./fp_2phase]
    type = StiffenedGas7EqnFluidProperties
  [../]
[]

[Kernels]
  [./test_liquid]
    type = MaterialDerivativeTestKernel
    variable = arhoA_liquid
    material_property = H_liquid
    args = 'beta arhoA_liquid arhouA_liquid arhoEA_liquid'
  [../]
  [./test_vapor]
    type = MaterialDerivativeTestKernel
    variable = arhoA_vapor
    material_property = H_vapor
    args = 'beta arhoA_vapor arhouA_vapor arhoEA_vapor'
  [../]
[]

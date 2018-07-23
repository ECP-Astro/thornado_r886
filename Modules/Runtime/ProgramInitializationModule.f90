MODULE ProgramInitializationModule

  USE KindModule, ONLY: &
    DP
  USE UnitsModule, ONLY: &
    ActivateUnitsDisplay, &
    DescribeUnitsDisplay, &
    UnitsDisplay
  USE ProgramHeaderModule, ONLY: &
    nX, swX, xL, xR, ZoomX, &
    nE, swE, eL, eR, ZoomE, &
    nDimsX, nDimsE, nDims, &
    nDOFX,  nDOFE,  nDOF, &
    nNodesX, nNodesE, nNodes, &
    InitializeProgramHeader
  USE UtilitiesModule, ONLY: &
    InitializeWeights
  USE QuadratureModule, ONLY: &
    InitializeQuadratures
  USE ReferenceElementModule, ONLY: &
    InitializeReferenceElement
  USE PolynomialBasisModule_Lagrange, ONLY: &
    InitializePolynomialBasis_Lagrange
  USE PolynomialBasisModule_Legendre, ONLY: &
    InitializePolynomialBasis_Legendre
  USE PolynomialBasisMappingModule, ONLY: &
    InitializePolynomialBasisMapping
  USE MeshModule, ONLY: &
    MeshX, MeshE, &
    CreateMesh, &
    DestroyMesh
  USE GeometryFieldsModule, ONLY: &
    CreateGeometryFields, &
    DestroyGeometryFields
  USE GeometryFieldsModuleE, ONLY: &
    CreateGeometryFieldsE, &
    DestroyGeometryFieldsE
  USE FluidFieldsModule, ONLY: &
    CreateFluidFields, &
    DestroyFluidFields
  USE RadiationFieldsModule, ONLY: &
    CreateRadiationFields, &
    DestroyRadiationFields
  USE EquationOfStateModule, ONLY: &
    InitializeEquationOfState, &
    FinalizeEquationOfState
  USE OpacityModule, ONLY: &
    InitializeOpacities, &
    FinalizeOpacities
  USE GravitySolutionModule, ONLY: &
    InitializeGravitySolver, &
    FinalizeGravitySolver
  USE FluidEvolutionModule, ONLY: &
    InitializeFluidEvolution, &
    FinalizeFluidEvolution
  USE RadiationEvolutionModule, ONLY: &
    InitializeRadiationEvolution, &
    FinalizeRadiationEvolution
  USE RiemannSolverModule, ONLY: &
    InitializeRiemannSolvers, &
    FinalizeRiemannSolvers
  USE FluidRadiationCouplingModule, ONLY: &
    InitializeFluidRadiationCoupling, &
    FinalizeFluidRadiationCoupling
  USE TimeSteppingModule, ONLY: &
    InitializeTimeStepping, &
    FinalizeTimeStepping

  IMPLICIT NONE
  PRIVATE

  INCLUDE 'mpif.h'

  LOGICAL :: BasicInitialization
  INTEGER :: mpierr

  PUBLIC :: InitializeProgram
  PUBLIC :: FinalizeProgram

CONTAINS


  SUBROUTINE InitializeProgram &
    ( ProgramName_Option, nX_Option, swX_Option, bcX_Option, xL_Option, &
      xR_Option, zoomX_Option, nE_Option, swE_Option, bcE_Option, &
      eL_Option, eR_Option, zoomE_Option, CoordinateSystem_Option, &
      nNodes_Option, ActivateUnits_Option, EquationOfState_Option, &
      EquationOfStateTableName_Option, Gamma_IDEAL_Option, &
      Opacity_Option, OpacityTableName_Option, GravitySolver_Option, &
      PointMass_Option, FluidSolver_Option, RadiationSolver_Option, &
      FluidRiemannSolver_Option, RadiationRiemannSolver_Option, &
      FluidRadiationCoupling_Option, EvolveGravity_Option, &
      EvolveFluid_Option, EvolveRadiation_Option, &
      ApplySlopeLimiter_Option, BetaTVB_Option, BetaTVD_Option, &
      ApplyPositivityLimiter_Option, nStages_SSP_RK_Option, &
      nStages_SI_RK_Option, IMEX_Scheme_Option, BasicInitialization_Option )

    CHARACTER(LEN=*),       INTENT(in), OPTIONAL :: ProgramName_Option
    INTEGER,  DIMENSION(3), INTENT(in), OPTIONAL :: nX_Option
    INTEGER,  DIMENSION(3), INTENT(in), OPTIONAL :: swX_Option
    INTEGER,  DIMENSION(3), INTENT(in), OPTIONAL :: bcX_Option
    REAL(DP), DIMENSION(3), INTENT(in), OPTIONAL :: xL_Option
    REAL(DP), DIMENSION(3), INTENT(in), OPTIONAL :: xR_Option
    REAL(DP), DIMENSION(3), INTENT(in), OPTIONAL :: zoomX_Option
    INTEGER,                INTENT(in), OPTIONAL :: nE_Option
    INTEGER,                INTENT(in), OPTIONAL :: swE_Option
    INTEGER,                INTENT(in), OPTIONAL :: bcE_Option
    REAL(DP),               INTENT(in), OPTIONAL :: eL_Option
    REAL(DP),               INTENT(in), OPTIONAL :: eR_Option
    REAL(DP),               INTENT(in), OPTIONAL :: zoomE_Option
    INTEGER,                INTENT(in), OPTIONAL :: nNodes_Option
    CHARACTER(LEN=*),       INTENT(in), OPTIONAL :: CoordinateSystem_Option
    LOGICAL,                INTENT(in), OPTIONAL :: ActivateUnits_Option
    CHARACTER(LEN=*),       INTENT(in), OPTIONAL :: EquationOfState_Option
    CHARACTER(LEN=*),       INTENT(in), OPTIONAL :: &
      EquationOfStateTableName_Option
    REAL(DP),               INTENT(in), OPTIONAL :: Gamma_IDEAL_Option
    CHARACTER(LEN=*),       INTENT(in), OPTIONAL :: Opacity_Option
    CHARACTER(LEN=*),       INTENT(in), OPTIONAL :: OpacityTableName_Option
    CHARACTER(LEN=*),       INTENT(in), OPTIONAL :: GravitySolver_Option
    REAL(DP),               INTENT(in), OPTIONAL :: PointMass_Option
    CHARACTER(LEN=*),       INTENT(in), OPTIONAL :: FluidSolver_Option
    CHARACTER(LEN=*),       INTENT(in), OPTIONAL :: RadiationSolver_Option
    CHARACTER(LEN=*),       INTENT(in), OPTIONAL :: FluidRiemannSolver_Option
    CHARACTER(LEN=*),       INTENT(in), OPTIONAL :: &
      RadiationRiemannSolver_Option
    CHARACTER(LEN=*),       INTENT(in), OPTIONAL :: &
      FluidRadiationCoupling_Option
    LOGICAL,                INTENT(in), OPTIONAL :: EvolveGravity_Option
    LOGICAL,                INTENT(in), OPTIONAL :: EvolveFluid_Option
    LOGICAL,                INTENT(in), OPTIONAL :: EvolveRadiation_Option
    LOGICAL,                INTENT(in), OPTIONAL :: ApplySlopeLimiter_Option
    REAL(DP),               INTENT(in), OPTIONAL :: BetaTVB_Option
    REAL(DP),               INTENT(in), OPTIONAL :: BetaTVD_Option
    LOGICAL,                INTENT(in), OPTIONAL :: &
      ApplyPositivityLimiter_Option
    INTEGER,                INTENT(in), OPTIONAL :: nStages_SSP_RK_Option
    INTEGER,                INTENT(in), OPTIONAL :: nStages_SI_RK_Option
    CHARACTER(LEN=*),       INTENT(in), OPTIONAL :: IMEX_Scheme_Option
    LOGICAL,                INTENT(in), OPTIONAL :: BasicInitialization_Option

    LOGICAL :: ActivateUnits
    INTEGER :: iDim

    CALL MPI_INIT( mpierr )

    CALL InitializeProgramHeader     &
           ( ProgramName_Option      &
               = ProgramName_Option, &
             nNodes_Option           &
               = nNodes_Option,      &
             nX_Option               &
               = nX_Option,          &
             swX_Option              &
               = swX_Option,         &
             bcX_Option              &
               = bcX_Option,         &
             xL_Option               &
               = xL_Option,          &
             xR_Option               &
               = xR_Option,          &
             zoomX_Option            &
               = zoomX_Option,       &
             nE_Option               &
               = nE_Option,          &
             swE_Option              &
               = swE_Option,         &
             bcE_Option              &
               = bcE_Option,         &
             eL_Option               &
               = eL_Option,          &
             eR_Option               &
               = eR_Option,          &
             zoomE_Option            &
               = zoomE_Option )

    BasicInitialization = .FALSE.
    IF( PRESENT( BasicInitialization_Option ) ) &
      BasicInitialization = BasicInitialization_Option

    IF( BasicInitialization )THEN

      WRITE(*,'(A5,A20)') '', 'Basic Initialization'
      WRITE(*,*)

    END IF

    ! --- Units ---

    ActivateUnits = .FALSE.
    IF( PRESENT( ActivateUnits_Option ) ) &
      ActivateUnits = ActivateUnits_Option

    IF( ActivateUnits )THEN

      CALL ActivateUnitsDisplay
      CALL DescribeUnitsDisplay

    END IF

    WRITE(*,'(A5,A17,I1)') &
      '', 'Dimensionality = ', nDims
    WRITE(*,'(A5,A18)') &
      '', '------------------'
    WRITE(*,*)
    WRITE(*,'(A7,A9,I1,A2,A9,I1)') &
      '', 'nDimsX = ', nDimsX, '', 'nDimsE = ', nDimsE
    WRITE(*,*)

    WRITE(*,'(A7,A9,I4.4,A2,A9,I4.4,A2,A9,I4.4,A2,A6,I4.4)') &
      '', 'nX(1) = ', nX(1), '', 'nX(2) = ', nX(2), &
      '', 'nX(3) = ', nX(3), '', 'nE = ', nE
    WRITE(*,'(A7,A9,I4,A2,A9,I4,A2,A9,I4,A2,A6,I4)') &
      '', 'swX(1) = ', swX(1), '', 'swX(2) = ', swX(2), &
      '', 'swX(3) = ', swX(3), '', 'swE = ', swE
    WRITE(*,*)

    WRITE(*,'(A5,A36)') '', 'Degrees of Freedom / Element / Field'
    WRITE(*,*)
    WRITE(*,'(A7,A9,I2.2)') &
      '', 'nNodes = ', nNodes
    WRITE(*,*)
    DO iDim = 1, 3
      WRITE(*,'(A9,A4,I1,A10,I1,A4,I2.2)') &
        '', 'i = ', iDim, ', nNodesX(', iDim, ') = ', nNodesX(iDim)
    END DO
    WRITE(*,'(A16,A13,I2.2)') &
      '', 'nNodesE    = ', nNodesE
    WRITE(*,*)
    WRITE(*,'(A7,A8,I4.4,A2,A8,I4.4,A2,A7,I4.4)') &
      '', 'nDOFX = ', nDOFX, '', 'nDOFE = ', nDOFE, '', 'nDOF = ', nDOF
    WRITE(*,*)

    ! --- Quadratures ---

    CALL InitializeQuadratures

    ! --- Polynomial Basis ---

    CALL InitializePolynomialBasis_Lagrange

    CALL InitializePolynomialBasis_Legendre

    ASSOCIATE( U => UnitsDisplay )

    ! --- Spatial Grid ---

    WRITE(*,'(A5,A)') '', 'Computational Domain'
    WRITE(*,'(A5,A)') '', '--------------------'
    WRITE(*,*)
    WRITE(*,'(A7,A)') '', 'Spatial Domain:'
    WRITE(*,'(A7,A)') '', '---------------'
    WRITE(*,*)
    DO iDim = 1, 3

      WRITE(*,'(A7,A3,I1,A4,ES9.2E2,A1,A,A2,A3,I1,A4,&
                &ES9.2E2,A1,A,A2,A6,I1,A4,ES10.4E2)') &
        '',   'xL(', iDim, ') = ', xL(iDim) / U % LengthUnit, &
        '', TRIM( U % LengthLabel ), &
        ', ', 'xR(', iDim, ') = ', xR(iDim) / U % LengthUnit, &
        '', TRIM( U % LengthLabel ), &
        ', ', 'ZoomX(', iDim, ') = ', ZoomX(iDim)
      WRITE(*,*)

      CALL CreateMesh &
             ( MeshX(iDim), nX(iDim), nNodesX(iDim), swX(iDim), &
               xL(iDim), xR(iDim), ZoomOption = ZoomX(iDim) )

      WRITE(*,'(A9,A11,I1,A4,ES9.2E2,A1,A,A3,ES9.2E2,A1,A)') &
        '', 'MIN/MAX dx(', iDim, ') = ', &
        MINVAL( MeshX(iDim) % Width(1:nX(iDim)) ) &
          / U % LengthUnit, '', TRIM( U % LengthLabel ), &
        ' / ', &
        MAXVAL( MeshX(iDim) % Width(1:nX(iDim)) ) &
          / U % LengthUnit, '', TRIM( U % LengthLabel )
      WRITE(*,*)

    END DO

    ! --- Spectral Grid ---

    WRITE(*,*)
    WRITE(*,'(A7,A)') '', 'Spectral Domain:'
    WRITE(*,'(A7,A)') '', '----------------'
    WRITE(*,*)

    WRITE(*,'(A7,A5,ES8.2E2,A1,A,A2,A5,ES8.2E2,A1,A,A2,A8,ES10.4E2)') &
      '', 'eL = ', eL / U % EnergyUnit, '', TRIM( U % EnergyLabel ), &
      ', ', &
          'eR = ', eR / U % EnergyUnit, '', TRIM( U % EnergyLabel ), &
      ', ', 'ZoomE = ', ZoomE
    WRITE(*,*)

    CALL CreateMesh &
           ( MeshE, nE, nNodesE, swE, eL, eR, ZoomOption = ZoomE )

    WRITE(*,'(A9,A13,ES8.2E2,A1,A,A3,ES8.2E2,A1,A)') &
      '', 'MIN/MAX de = ', &
      MINVAL( MeshE % Width(1:nE) ) / U % EnergyUnit, &
      '', TRIM( U % EnergyLabel ), &
      ' / ', &
      MAXVAL( MeshE % Width(1:nE) ) / U % EnergyUnit, &
      '', TRIM( U % EnergyLabel )

    END ASSOCIATE ! U

    ! --- Geometry (Position Space) ---

    CALL CreateGeometryFields &
           ( nX, swX, CoordinateSystem_Option = CoordinateSystem_Option )

    ! --- Geometry (Energy Space) ---

    CALL CreateGeometryFieldsE( nE, swE )

    ! --- Physical Fields ---

    ! --- Fluid Fields ---

    CALL CreateFluidFields( nX, swX )

    ! --- Radiation Fields ---

    CALL CreateRadiationFields( nX, swX, nE, swE )

    ! --- For Mapping Between Nodal and Modal Representations ---

    CALL InitializePolynomialBasisMapping &
           ( MeshE    % Nodes, MeshX(1) % Nodes, &
             MeshX(2) % Nodes, MeshX(3) % Nodes )

    IF( BasicInitialization ) RETURN

    ! --- Equation of State ---

    CALL InitializeEquationOfState &
           ( EquationOfState_Option &
               = EquationOfState_Option, &
             EquationOfStateTableName_Option &
               = EquationOfStateTableName_Option, &
             Gamma_IDEAL_Option &
               = Gamma_IDEAL_Option )

    ! --- Opacities ---

    CALL InitializeOpacities &
           ( Opacity_Option &
               = Opacity_Option, &
             OpacityTableName_Option &
               = OpacityTableName_Option )

    ! --- Gravity Solver ---

    CALL InitializeGravitySolver &
           ( GravitySolver_Option &
               = GravitySolver_Option, &
             PointMass_Option &
               = PointMass_Option )

    ! --- Fluid Solver ---

    CALL InitializeFluidEvolution &
           ( FluidSolver_Option &
               = FluidSolver_Option, &
             ApplySlopeLimiter_Option &
               = ApplySlopeLimiter_Option, &
             BetaTVB_Option &
               = BetaTVB_Option, &
             BetaTVD_Option &
               = BetaTVD_Option, &
             ApplyPositivityLimiter_Option &
               = ApplyPositivityLimiter_Option )

    ! --- Radiation Solver ---

    CALL InitializeRadiationEvolution &
           ( RadiationSolver_Option &
               = RadiationSolver_Option, &
             ApplySlopeLimiter_Option &
               = ApplySlopeLimiter_Option, &
             BetaTVB_Option &
               = BetaTVB_Option, &
             BetaTVD_Option &
               = BetaTVD_Option, &
             ApplyPositivityLimiter_Option &
               = ApplyPositivityLimiter_Option )

    ! --- Riemann Solvers ---

    CALL InitializeRiemannSolvers &
           ( FluidRiemannSolver_Option &
               = FluidRiemannSolver_Option, &
             RadiationRiemannSolver_Option &
               = RadiationRiemannSolver_Option )

    ! --- Fluid-Radiation Solver ---

    CALL InitializeFluidRadiationCoupling &
           ( FluidRadiationCoupling_Option &
               = FluidRadiationCoupling_Option )

    ! --- Time Stepping ---

    CALL InitializeTimeStepping &
           ( EvolveGravity_Option &
               = EvolveGravity_Option, &
             EvolveFluid_Option &
               = EvolveFluid_Option, &
             EvolveRadiation_Option &
               = EvolveRadiation_Option, &
             nStages_SSP_RK_Option &
               = nStages_SSP_RK_Option, &
             nStages_SI_RK_Option &
               = nStages_SI_RK_Option, &
             IMEX_Scheme_Option &
               = IMEX_Scheme_Option )

  END SUBROUTINE InitializeProgram


  SUBROUTINE FinalizeProgram

    INTEGER :: iDim

    ! --- Spatial Grid ---

    DO iDim = 1, 3

      CALL DestroyMesh( MeshX(iDim) )

    END DO

    ! --- Spectral Grid ---

    CALL DestroyMesh( MeshE )

    ! --- Geometry ---

    CALL DestroyGeometryFields

    CALL DestroyGeometryFieldsE

    ! --- Physical Fields ---

    CALL DestroyFluidFields

    CALL DestroyRadiationFields

    IF( BasicInitialization )THEN

      CALL MPI_FINALIZE( mpierr )

      RETURN

    END IF

    ! --- Equation of State ---

    CALL FinalizeEquationOfState

    ! --- Opacities ---

    CALL FinalizeOpacities

    ! --- Gravity Solver ---

    CALL FinalizeGravitySolver

    ! --- Fluid Solver ---

    CALL FinalizeFluidEvolution

    ! --- Radiation Solver ---

    CALL FinalizeRadiationEvolution

    ! --- Riemann Solvers ---

    CALL FinalizeRiemannSolvers

    ! --- Fluid-Radiation Solver ---

    CALL FinalizeFluidRadiationCoupling

    ! --- Time Stepping ---

    CALL FinalizeTimeStepping

    CALL MPI_FINALIZE( mpierr )

  END SUBROUTINE FinalizeProgram


END MODULE ProgramInitializationModule

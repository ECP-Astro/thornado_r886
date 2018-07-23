MODULE RadiationFieldsModule

  USE KindModule, ONLY: &
    DP
  USE ProgramHeaderModule, ONLY: &
    nDOF

  IMPLICIT NONE
  PRIVATE

  LOGICAL :: Verbose

  INTEGER, PUBLIC :: nSpecies = 1

  ! --- Eulerian (Conserved) Radiation Fields ---

  INTEGER, PUBLIC, PARAMETER :: iCR_N  = 1  ! Eulerian Number Density
  INTEGER, PUBLIC, PARAMETER :: iCR_G1 = 2  ! Eulerian Number Flux Density 1
  INTEGER, PUBLIC, PARAMETER :: iCR_G2 = 3  ! Eulerian Number Flux Density 2
  INTEGER, PUBLIC, PARAMETER :: iCR_G3 = 4  ! Eulerian Number Flux Density 3
  INTEGER, PUBLIC, PARAMETER :: nCR    = 4  ! n Eulerian Radiation Fields

  CHARACTER(32), DIMENSION(nCR), PUBLIC, PARAMETER :: &
    namesCR = [ 'Eulerian Number Density         ', &
                'Eulerian Number Flux Density (1)', &
                'Eulerian Number Flux Density (2)', &
                'Eulerian Number Flux Density (3)' ]

  REAL(DP), DIMENSION(nCR), PUBLIC :: unitsCR

  REAL(DP), ALLOCATABLE, PUBLIC :: uCR  (:,:,:,:,:,:,:)
  REAL(DP), ALLOCATABLE, PUBLIC :: rhsCR(:,:,:,:,:,:,:)

  ! --- Lagrangian (Primitive) Radiation Fields ---

  INTEGER, PUBLIC, PARAMETER :: iPR_D  = 1  ! Lagrangian Number Density
  INTEGER, PUBLIC, PARAMETER :: iPR_I1 = 2  ! Lagrangian Number Flux 1
  INTEGER, PUBLIC, PARAMETER :: iPR_I2 = 3  ! Lagrangian Number Flux 2
  INTEGER, PUBLIC, PARAMETER :: iPR_I3 = 4  ! Lagrangian Number Flux 3
  INTEGER, PUBLIC, PARAMETER :: nPR    = 4  ! n Lagrangian Radiation Fields

  CHARACTER(34), DIMENSION(nPR), PUBLIC, PARAMETER :: &
    namesPR = [ 'Lagrangian Number Density         ', &
                'Lagrangian Number Flux Density (1)', &
                'Lagrangian Number Flux Density (2)', &
                'Lagrangian Number Flux Density (3)' ]

  REAL(DP), DIMENSION(nPR), PUBLIC :: unitsPR

  REAL(DP), ALLOCATABLE, PUBLIC :: uPR(:,:,:,:,:,:,:)

  ! --- Auxiliary Radiation Fields ---

  INTEGER, PUBLIC, PARAMETER :: iAR_F = 1  ! Flux Factor
  INTEGER, PUBLIC, PARAMETER :: iAR_K = 2  ! Eddington Factor
  INTEGER, PUBLIC, PARAMETER :: nAR   = 2  ! n Auxiliary Radiation Fields

  CHARACTER(32), DIMENSION(nAR), PUBLIC, PARAMETER :: &
    namesAR = [ 'Lagrangian Flux Factor          ', &
                'Lagrangian Eddington Factor     ' ]

  REAL(DP), DIMENSION(nAR), PUBLIC :: unitsAR

  REAL(DP), ALLOCATABLE, PUBLIC :: uAR(:,:,:,:,:,:,:)

  ! --- Diagnostic Variables ---

  REAL(DP), ALLOCATABLE, PUBLIC :: Discontinuity(:,:,:,:)

  PUBLIC :: CreateRadiationFields
  PUBLIC :: DestroyRadiationFields

CONTAINS


  SUBROUTINE CreateRadiationFields &
    ( nX, swX, nE, swE, nSpecies_Option, Verbose_Option )

    INTEGER, INTENT(in) :: nX(3), swX(3)
    INTEGER, INTENT(in) :: nE,    swE
    INTEGER, INTENT(in), OPTIONAL :: nSpecies_Option
    LOGICAL, INTENT(in), OPTIONAL :: Verbose_Option

    IF( PRESENT( nSpecies_Option ) )THEN
      nSpecies = nSpecies_Option
    ELSE
      nSpecies = 1
    END IF

    IF( PRESENT( Verbose_Option ) )THEN
      Verbose = Verbose_Option
    ELSE
      Verbose = .TRUE.
    END IF

    CALL CreateRadiationFields_Conserved( nX, swX, nE, swE )
    CALL CreateRadiationFields_Primitive( nX, swX, nE, swE )
    CALL CreateRadiationFields_Auxiliary( nX, swX, nE, swE )

    ALLOCATE &
      ( rhsCR(1:nDOF,1:nE,1:nX(1),1:nX(2),1:nX(3),1:nCR,1:nSpecies) )

    ALLOCATE( Discontinuity(1:nE,1:nX(1),1:nX(2),1:nX(3)) )
    Discontinuity = 0.0_DP

    CALL SetUnitsRadiationFields

  END SUBROUTINE CreateRadiationFields


  SUBROUTINE CreateRadiationFields_Conserved( nX, swX, nE, swE )

    INTEGER, INTENT(in) :: nX(3), swX(3)
    INTEGER, INTENT(in) :: nE,    swE

    INTEGER :: iCR

    IF( Verbose )THEN
      WRITE(*,*)
      WRITE(*,'(A5,A28)') '', 'Radiation Fields (Conserved)'
      WRITE(*,*)
      DO iCR = 1, nCR
        WRITE(*,'(A5,A)') '', TRIM( namesCR(iCR) )
      END DO
    END IF

    ALLOCATE &
      ( uCR(1:nDOF, &
            1-swE:nE+swE, &
            1-swX(1):nX(1)+swX(1), &
            1-swX(2):nX(2)+swX(2), &
            1-swX(3):nX(3)+swX(3), &
            1:nCR, 1:nSpecies) )

  END SUBROUTINE CreateRadiationFields_Conserved


  SUBROUTINE CreateRadiationFields_Primitive( nX, swX, nE, swE )

    INTEGER, INTENT(in) :: nX(3), swX(3)
    INTEGER, INTENT(in) :: nE,    swE

    INTEGER :: iPR

    IF( Verbose )THEN
      WRITE(*,*)
      WRITE(*,'(A5,A28)') '', 'Radiation Fields (Primitive)'
      WRITE(*,*)
      DO iPR = 1, nPR
        WRITE(*,'(A5,A)') '', TRIM( namesPR(iPR) )
      END DO
    END IF

    ALLOCATE &
      ( uPR(1:nDOF, &
            1-swE:nE+swE, &
            1-swX(1):nX(1)+swX(1), &
            1-swX(2):nX(2)+swX(2), &
            1-swX(3):nX(3)+swX(3), &
            1:nPR, 1:nSpecies) )

  END SUBROUTINE CreateRadiationFields_Primitive


  SUBROUTINE CreateRadiationFields_Auxiliary( nX, swX, nE, swE )

    INTEGER, INTENT(in) :: nX(3), swX(3)
    INTEGER, INTENT(in) :: nE, swE

    INTEGER :: iAR

    IF( Verbose )THEN
      WRITE(*,*)
      WRITE(*,'(A5,A28)') '', 'Radiation Fields (Auxiliary)'
      WRITE(*,*)
      DO iAR = 1, nAR
        WRITE(*,'(A5,A)') '', TRIM( namesAR(iAR) )
      END DO
    END IF

    ALLOCATE &
      ( uAR(1:nDOF, &
            1-swE:nE+swE, &
            1-swX(1):nX(1)+swX(1), &
            1-swX(2):nX(2)+swX(2), &
            1-swX(3):nX(3)+swX(3), &
            1:nAR, 1:nSpecies) )

  END SUBROUTINE CreateRadiationFields_Auxiliary


  SUBROUTINE DestroyRadiationFields

    DEALLOCATE( uCR, rhsCR, uPR, uAR )
    DEALLOCATE( Discontinuity )

  END SUBROUTINE DestroyRadiationFields


  SUBROUTINE SetUnitsRadiationFields

    USE UnitsModule, ONLY: &
      UnitsActive

    IF( UnitsActive )THEN

      unitsCR = 1.0_DP
      unitsPR = 1.0_DP
      unitsAR = 1.0_DP

    ELSE

      unitsCR = 1.0_DP
      unitsPR = 1.0_DP
      unitsAR = 1.0_DP

    END IF

  END SUBROUTINE SetUnitsRadiationFields


END MODULE RadiationFieldsModule

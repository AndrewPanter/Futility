!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++!
!                          Futility Development Group                          !
!                             All rights reserved.                             !
!                                                                              !
! Futility is a jointly-maintained, open-source project between the University !
! of Michigan and Oak Ridge National Laboratory.  The copyright and license    !
! can be found in LICENSE.txt in the head directory of this repository.        !
!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++!
!> @brief A Fortran 2003 module that encompasses a base class for solution
!>        acceleration.  Module also includes both picard iteration and a
!>        modified picard iteration.  Anderson Acceleration extends this base
!>        class in the AndersonAcceleration module.
!>
!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++!
MODULE SolutionAccelerationModule
#include "Futility_DBC.h"
USE Futility_DBC
USE IntrType
USE FutilityComputingEnvironmentModule
USE ParameterLists
USE ParallelEnv
USE VectorTypes

IMPLICIT NONE

PRIVATE

!List of public members
PUBLIC :: SolutionAccelerationType
PUBLIC :: RelaxedPicardType
PUBLIC :: ModifiedPicardType

!> @brief the base Solution Acceleration Type
TYPE,ABSTRACT :: SolutionAccelerationType
  !> Initialization status
  LOGICAL(SBK) :: isInit=.FALSE.
  !> Size of solution vector/matrix
  INTEGER(SIK) :: n=-1
  !> Current iteration count
  INTEGER(SIK) :: s=0
  !> Starting iteration
  INTEGER(SIK) :: start=1
  !> Initial iterates
  CLASS(VectorType),ALLOCATABLE :: x(:)
  !> Futility computing environment
  TYPE(FutilityComputingEnvironment),POINTER :: ce => NULL()
!
!List of Type Bound Procedures
  CONTAINS
    !> @copybrief SolutionAccelerationType::init
    !> @copydetails SolutionAccelerationType::init
    PROCEDURE(init_absintfc),DEFERRED,PASS :: init
    !> @copybrief SolutionAccelerationType::init_base_SolutionAccelerationType
    !> @copydetails SolutionAccelerationType::init_base_SolutionAccelerationType
    PROCEDURE,PASS :: init_base => init_base_SolutionAccelerationType
    !> @copybrief SolutionAccelerationType::clear_SolutionAccelerationType
    !> @copydetails SolutionAccelerationType::clear_SolutionAccelerationType
    PROCEDURE,PASS :: clear => clear_base_SolutionAccelerationType
    PROCEDURE,PASS :: clear_base => clear_base_SolutionAccelerationType
    !> @copybrief SolutionAccelerationType::setInitial
    !> @copydetails SolutionAccelerationType::setInitial
    PROCEDURE(set_absintfc),DEFERRED,PASS :: setInitial
    !> @copybrief SolutionAccelerationType::step
    !> @copydetails SolutionAccelerationType::step
    PROCEDURE(step_absintfc),DEFERRED,PASS :: step
    !> @copybrief SolutionAccelerationType::reset
    !> @copydetails SolutionAccelerationType::reset
    PROCEDURE(set_absintfc),DEFERRED,PASS :: reset
ENDTYPE SolutionAccelerationType

!> Definition of interface for init
ABSTRACT INTERFACE
  SUBROUTINE init_absintfc(solver,ce,Params)
    IMPORT :: SolutionAccelerationType,FutilityComputingEnvironment,ParamType
    CLASS(SolutionAccelerationType),INTENT(INOUT) :: solver
    TYPE(FutilityComputingEnvironment),TARGET,INTENT(IN) :: ce
    TYPE(ParamType),INTENT(IN) :: Params
  ENDSUBROUTINE init_absintfc
ENDINTERFACE

!> Definition of interface for step
ABSTRACT INTERFACE
  SUBROUTINE step_absintfc(solver,x_new)
    IMPORT :: SolutionAccelerationType,VectorType
    CLASS(SolutionAccelerationType),INTENT(INOUT) :: solver
    CLASS(VectorType),INTENT(INOUT) :: x_new
  ENDSUBROUTINE step_absintfc
ENDINTERFACE

!> Definition of interface for setInitial and reset
ABSTRACT INTERFACE
  SUBROUTINE set_absintfc(solver,x)
    IMPORT :: SolutionAccelerationType,VectorType
    CLASS(SolutionAccelerationType),INTENT(INOUT) :: solver
    CLASS(VectorType),INTENT(INOUT) :: x
  ENDSUBROUTINE set_absintfc
ENDINTERFACE

!> @brief the Relaxed Picard Acceleration Type
TYPE,EXTENDS(SolutionAccelerationType) :: RelaxedPicardType
  !> Relaxation coefficient
  REAL(SRK) :: alpha=1.0_SRK
!
!List of Type Bound Procedures
  CONTAINS
    !> @copybrief RelaxedPicardType::init_RelaxedPicardType
    !> @copydetails RelaxedPicardType::init_RelaxedPicardType
    PROCEDURE,PASS :: init => init_RelaxedPicardType
    !> @copybrief RelaxedPicardType::clear_RelaxedPicardType
    !> @copydetails RelaxedPicardType::clear_RelaxedPicardType
    PROCEDURE,PASS :: clear => clear_RelaxedPicardType
    PROCEDURE,PASS :: clear_picardBase => clear_RelaxedPicardType
    !> @copybrief RelaxedPicardType::setInitial_RelaxedPicardType
    !> @copydetails RelaxedPicardType::setInitial_RelaxedPicardType
    PROCEDURE,PASS :: setInitial => setInitial_RelaxedPicardType
    PROCEDURE,PASS :: setInitial_picardBase => setInitial_RelaxedPicardType
    !> @copybrief RelaxedPicardType::step_RelaxedPicardType
    !> @copydetails RelaxedPicardType::step_RelaxedPicardType
    PROCEDURE,PASS :: step => step_RelaxedPicardType
    !> @copybrief RelaxedPicardType::reset_RelaxedPicardType
    !> @copydetails RelaxedPicardType::reset_RelaxedPicardType
    PROCEDURE,PASS :: reset => reset_RelaxedPicardType
ENDTYPE RelaxedPicardType

!> @brief the Relaxed Picard Acceleration Type
TYPE,EXTENDS(RelaxedPicardType) :: ModifiedPicardType
  !> Temporary vector to hold previous solution
  CLASS(VectorType),ALLOCATABLE :: tmpvec
!
!List of Type Bound Procedures
  CONTAINS
    !> @copybrief ModifiedPicardType::clear_ModifiedPicardType
    !> @copydetails ModifiedPicardType::clear_ModifiedPicardType
    PROCEDURE,PASS :: clear => clear_ModifiedPicardType
    !> @copybrief ModifiedPicardType::setInitial_ModifiedPicardType
    !> @copydetails ModifiedPicardType::setInitial_ModifiedPicardType
    PROCEDURE,PASS :: setInitial => setInitial_ModifiedPicardType
    !> @copybrief ModifiedPicardType::step_ModifiedPicardType
    !> @copydetails ModifiedPicardType::step_ModifiedPicardType
    PROCEDURE,PASS :: step => step_ModifiedPicardType
ENDTYPE ModifiedPicardType

!> Name of module
CHARACTER(LEN=*),PARAMETER :: modName='SolutionAccelerationModule'
!
!===============================================================================
CONTAINS
!
!-------------------------------------------------------------------------------
!> @brief Initializes the Solution Acceleration base class
!> @param solver The Solution Acceleration solver to act on
!> @param ce The computing environment to use for the calculation
!> @param Params The options parameter list
!>
SUBROUTINE init_base_SolutionAccelerationType(solver,ce,Params)
  CLASS(SolutionAccelerationType),INTENT(INOUT) :: solver
  TYPE(FutilityComputingEnvironment),TARGET,INTENT(IN) :: ce
  TYPE(ParamType),INTENT(IN) :: Params

  CHARACTER(LEN=*),PARAMETER :: myName='init_base_SolutionAccelerationType'

  REQUIRE(Params%has('SolutionAcceleration->num_unknowns'))
  REQUIRE(.NOT.solver%isInit)

  !Pull Data from Parameter List
  CALL Params%get('SolutionAcceleration->num_unknowns',solver%n)
  IF(Params%has('SolutionAcceleration->starting_iteration')) &
      CALL Params%get('SolutionAcceleration->starting_iteration',solver%start)

  IF(solver%n < 1) CALL ce%exceptHandler%raiseError('Incorrect input to '//modName// &
      '::'//myName//' - Number of unkowns (n) must be greater than 0!')

  IF(solver%start < 1) CALL ce%exceptHandler%raiseError('Incorrect input to '//modName// &
      '::'//myName//' - Starting iteration must be greater than 0!')

  solver%s=0
  solver%ce => ce
ENDSUBROUTINE init_base_SolutionAccelerationType
!
!-------------------------------------------------------------------------------
!> @brief Clears the solution acceleration base class
!> @param solver The solver to act on
!>
SUBROUTINE clear_base_SolutionAccelerationType(solver)
    CLASS(SolutionAccelerationType),INTENT(INOUT) :: solver

    INTEGER(SIK) :: i

    IF(ALLOCATED(solver%x)) THEN
      DO i=1,SIZE(solver%x)
        CALL solver%x(i)%clear()
      ENDDO
      DEALLOCATE(solver%x)
    ENDIF
    solver%s=0
    solver%n=-1
    solver%start=1
    solver%isInit=.FALSE.
  ENDSUBROUTINE clear_base_SolutionAccelerationType
!
!-------------------------------------------------------------------------------
!> @brief Initializes the relaxed picard type
!> @param solver The relaxed picard solver to act on
!> @param ce The computing environment to use for the calculation
!> @param Params The options parameter list
!>
SUBROUTINE init_RelaxedPicardType(solver,ce,Params)
  CLASS(RelaxedPicardType),INTENT(INOUT) :: solver
  TYPE(FutilityComputingEnvironment),TARGET,INTENT(IN) :: ce
  TYPE(ParamType),INTENT(IN) :: Params

  CHARACTER(LEN=*),PARAMETER :: myName='init_RelaxedPicardType'

  REQUIRE(.NOT.solver%isInit)

  CALL solver%init_base(ce,Params)

  IF(Params%has('SolutionAcceleration->picard_relaxation_factor')) &
      CALL Params%get('SolutionAcceleration->picard_relaxation_factor',solver%alpha)

  IF(solver%alpha <= 0.0_SRK) CALL ce%exceptHandler%raiseError('Incorrect input to '//modName// &
      '::'//myName//' - Relaxation coefficient must be greater than 0!')

  solver%isInit=.TRUE.
ENDSUBROUTINE init_RelaxedPicardType
!
!-------------------------------------------------------------------------------
!> @brief Clears the relaxed picard type
!> @param solver The solver to act on
!>
SUBROUTINE clear_RelaxedPicardType(solver)
  CLASS(RelaxedPicardType),INTENT(INOUT) :: solver

  CALL solver%clear_base()

  solver%alpha=1.0_SRK
  solver%isInit=.FALSE.

ENDSUBROUTINE clear_RelaxedPicardType
!
!-------------------------------------------------------------------------------
!> @brief Sets the initial vector for relaxation
!> @param solver Solver to set initial vector for
!> @param x  Vector to use as initial condition and all other vector types have
!>           to match size and type of this one
!>
!> This sets the initial vector into internal storage.  Also initializes solver%x
!> based on the type that is passed in.
!>
SUBROUTINE setInitial_RelaxedPicardType(solver,x)
  CLASS(RelaxedPicardType),INTENT(INOUT) :: solver
  CLASS(VectorType),INTENT(INOUT) :: x

#if defined(HAVE_MPI) || defined(FUTILITY_HAVE_Trilinos)
  CHARACTER(LEN=*),PARAMETER :: myName='setInitial_RelaxedPicardType'
#endif

  REQUIRE(x%n == solver%n)
  REQUIRE(solver%s == 0)

  !If this is the first call to set/reset must actually create vectors of needed type
  IF(.NOT.ALLOCATED(solver%x)) THEN
    !!!TODO Once missing BLAS interfaces have been added for the following vector types
    !do away with this error catch to allow use of these

    SELECT TYPE(x)
#ifdef HAVE_MPI
    TYPE IS(NativeDistributedVectorType)
      CALL solver%ce%exceptHandler%raiseError('Incorrect call to '//modName// &
          '::'//myName//' - Input vector type not supported!')
#endif
#ifdef FUTILITY_HAVE_Trilinos
    TYPE IS(TrilinosVectorType)
      CALL solver%ce%exceptHandler%raiseError('Incorrect call to '//modName// &
          '::'//myName//' - Input vector type not supported!')
#endif
    ENDSELECT

    CALL VectorResembleAlloc(solver%x,x,1)
  ENDIF

  CALL BLAS_copy(x,solver%x(1))

ENDSUBROUTINE setInitial_RelaxedPicardType
!
!-------------------------------------------------------------------------------
!> @brief Performs a single step of Relaxed Picard acting on the input solution vector.
!> @param solver Solver to take step with
!> @param x_new New solution iterate and under-relaxed / accelerated return vector
!>
SUBROUTINE step_RelaxedPicardType(solver,x_new)
  CLASS(RelaxedPicardType),INTENT(INOUT) :: solver
  CLASS(VectorType),INTENT(INOUT) :: x_new

  REQUIRE(x_new%n == solver%n)
  REQUIRE(ALLOCATED(solver%x))

  !Update iteration counter
  solver%s=solver%s+1

  IF(solver%s >= solver%start) THEN
    !Get under-relaxed solution using mixing parameter
    CALL BLAS_scal(x_new,solver%alpha)
    CALL BLAS_axpy(solver%x(1),x_new,1.0_SRK-solver%alpha)
  ENDIF
  CALL BLAS_copy(x_new,solver%x(1))

ENDSUBROUTINE step_RelaxedPicardType
!
!-------------------------------------------------------------------------------
!> @brief Reset the initial iterate for the solver
!> @param solver The solver to act on
!> @param x Initial iterate solve is starting from
!>
SUBROUTINE reset_RelaxedPicardType(solver,x)
  CLASS(RelaxedPicardType),INTENT(INOUT) :: solver
  CLASS(VectorType),INTENT(INOUT) :: x

  REQUIRE(x%n == solver%n)

  !Reset iteration counter
  solver%s=0_SIK

  CALL solver%setInitial(x)

ENDSUBROUTINE reset_RelaxedPicardType
!
!-------------------------------------------------------------------------------
!> @brief Clears the modified picard Type
!> @param solver The solver to act on
!>
SUBROUTINE clear_ModifiedPicardType(solver)
  CLASS(ModifiedPicardType),INTENT(INOUT) :: solver

  CALL solver%clear_picardbase()

  IF(ALLOCATED(solver%tmpvec)) THEN
    CALL solver%tmpvec%clear()
    DEALLOCATE(solver%tmpvec)
  ENDIF
  solver%isInit=.FALSE.
ENDSUBROUTINE clear_ModifiedPicardType
!
!-------------------------------------------------------------------------------
!> @brief Sets the initial vector for relaxation
!> @param solver Solver to set initial vector for
!> @param x  Vector to use as initial condition and all other vector types have
!>           to match size and type of this one
!>
!> This sets the initial vector into internal storage.  Also initializes solver%x
!> and tmpvec based on the type that is passed in.
!>
SUBROUTINE setInitial_ModifiedPicardType(solver,x)
  CLASS(ModifiedPicardType),INTENT(INOUT) :: solver
  CLASS(VectorType),INTENT(INOUT) :: x

  CALL solver%setInitial_picardBase(x)

  IF(.NOT. ALLOCATED(solver%tmpvec)) CALL VectorResembleAlloc(solver%tmpvec,x)

ENDSUBROUTINE setInitial_ModifiedPicardType
!
!-------------------------------------------------------------------------------
!> @brief Performs a single step of Modified Picard acting on the input solution vector.
!> @param solver Solver to take step with
!> @param x_new New solution iterate and under-relaxed / accelerated return vector
!>
SUBROUTINE step_ModifiedPicardType(solver,x_new)
  CLASS(ModifiedPicardType),INTENT(INOUT) :: solver
  CLASS(VectorType),INTENT(INOUT) :: x_new

  REQUIRE(x_new%n == solver%n)
  REQUIRE(ALLOCATED(solver%x))
  REQUIRE(ALLOCATED(solver%tmpvec))

  !Update iteration counter
  solver%s=solver%s+1

  CALL BLAS_copy(x_new,solver%tmpvec)

  IF(solver%s >= solver%start) THEN
    !Get under-relaxed solution using mixing parameter
    CALL BLAS_scal(x_new,solver%alpha)
    CALL BLAS_axpy(solver%x(1),x_new,1.0_SRK-solver%alpha)
  ENDIF
  CALL BLAS_copy(solver%tmpvec,solver%x(1))

ENDSUBROUTINE step_ModifiedPicardType
!
ENDMODULE SolutionAccelerationModule

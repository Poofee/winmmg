!> @author Cecile Dobrzynski, Charles Dapogny, Pascal Frey and Algiane Froehly
!> @brief Example of input output for the mmg2d library for multiple solutions
!> at mesh vertices

PROGRAM main

  IMPLICIT NONE

  !> Include here the mmg3d library hader file
  ! if the header file is in the "include" directory
  ! #include "libmmg2df.h"

  ! if the header file is in "include/mmg/mmg2d"
#include "mmg/mmg2d/libmmg2df.h"

  MMG5_DATA_PTR_T    :: mesh
  MMG5_DATA_PTR_T    :: sol,mmgMet
  INTEGER            :: ier,argc,i,j,opt

  CHARACTER(len=300) :: exec_name,filename,fileout

  PRINT*,"  -- 2D MESH GENERATION FOR VISUALIZATION"

  argc =  COMMAND_ARGUMENT_COUNT();
  CALL get_command_argument(0, exec_name)


  IF ( argc /= 2 ) THEN
     PRINT*," Usage: ",TRIM(ADJUSTL(exec_name)),&
          " input_file_name output_file_name" &
     "  Generation of a triangular mesh for solution vizualisation (at VTK &
     & file format) from a Medit mesh file containing only points and the &
     & associated solution file."
     CALL EXIT(1);
  ENDIF

  ! Name and path of the mesh file
  CALL get_command_argument(1, filename)
  CALL get_command_argument(2, fileout)

  !!> ------------------------------ STEP   I --------------------------
  !! 1) Initialisation of mesh and sol structures */
  !! args of InitMesh:
  !! MMG5_ARG_start: we start to give the args of a variadic func
  !! MMG5_ARG_ppMesh: next arg will be a pointer over a MMG5_pMesh
  !! &mmgMesh: pointer toward your MMG5_pMesh (that store your mesh)
  !! MMG5_ARG_ppMet: next arg will be a pointer over a MMG5_pSol storing a metric
  !! &mmgSol: pointer toward your MMG5_pSol (that store your metric)

  mesh    = 0
  sol     = 0
  mmgMet  = 0

  CALL MMG2D_Init_mesh(MMG5_ARG_start, &
       MMG5_ARG_ppMesh,mmgMesh,MMG5_ARG_ppMet,mmgMet, &
       MMG5_ARG_ppMet,sol, &
       MMG5_ARG_end);


  !!> 2) Build initial mesh and solutions in MMG5 format
  !! Two solutions: just use the MMG2D_loadMesh function that will read a .mesh(b)
  !! file formatted or manually set your mesh using the MMG2D_Set* functions

  !!> Automatic loading of the mesh and multiple solutions
  CALL MMG2D_loadMesh(mesh,TRIM(ADJUSTL(filename)),&
       LEN(TRIM(ADJUSTL(filename))),ier)
  IF ( ier /= 1 )  CALL EXIT(102)

  CALL MMG2D_loadSol(mesh,sol,TRIM(ADJUSTL(filename)),&
       LEN(TRIM(ADJUSTL(filename))),ier)
  IF ( ier /= 1 )  CALL EXIT(103)

  !!> ------------------------------ STEP II ---------------------------
  !! Mesh generation
  CALL MMG2D_Set_iparameter(mesh,mmgMet,MMG2D_IPARAM_NOINSERT,1,ier);
  IF ( ier /= 1 )  CALL EXIT(104)

  CALL MMG2D_Set_iparameter(mesh,mmgMet,MMG2D_IPARAM_NOSWAP,1,ier);
  IF ( ier /= 1 )  CALL EXIT(105)

 CALL MMG2D_Set_iparameter(mesh,mmgMet,MMG2D_IPARAM_NOMOVE,1,ier);
  IF ( ier /= 1 )  CALL EXIT(106)

  CALL MMG2D_mmg2dmesh(mesh,mmgMet,ier)
  IF ( ier /= MMG5_SUCCESS )  CALL EXIT(200)

  !!> ------------------------------ STEP III --------------------------
  !! Save the new data
  !! Use the MMG2D_saveMesh/MMG2D_saveAllSols functions
  !! save the mesh
  !> 1) Automatically save the mesh
  CALL MMG2D_saveVtkMesh(mesh,sol,TRIM(ADJUSTL(fileout)),LEN(TRIM(ADJUSTL(fileout))),ier)
  IF ( ier /= 1 ) CALL EXIT(300)

  !!> 3) Free the MMG2D structures
  CALL MMG2D_Free_all(MMG5_ARG_start, &
       MMG5_ARG_ppMesh,mesh,MMG5_ARG_ppMet,mmgMet, &
       MMG5_ARG_ppMet,sol, &
       MMG5_ARG_end)

END PROGRAM main

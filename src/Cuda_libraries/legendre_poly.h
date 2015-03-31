//Author: Harsha V. Lokavarapu

#include <cstdlib>
#include "helper_cuda.h"
#include <string>
#include <math.h>
#include "cuda.h"
#include <fstream>
#include <mpi.h>

#define ARGC 3 

/*#if __CUDA_ARCH__ < 350 
#error "Incompatable compute capability for sm. Using dynamic parallelism (>= 35)"
#endif
*/
//Function and variable declarations.
extern int nComp;
//CPU pointers to GPU memory data

// Fortran function calls
extern "C" {
  //void inputcalypso_(int*, int*, double*, double*, double*);
  //void cleancalypso_();
  void transform_f_(int*, int*, int*);
  void transform_b_(int*, int*, int*, double*);
}

//Fortran Variables
typedef struct {
  int *nidx_rtm;
  int *nidx_rlm;
  int *istep_rtm;
  int *istep_rlm;
  int nnod_rtp;
  int nnod_rlm;
  int nnod_rtm;
  int ncomp;
  int nscalar;
  int nvector;
  int t_lvl;
} Geometry_c;

//Cublas library/Cuda variables
extern cudaError_t error;
extern cudaStream_t streams[32];

//Helper functions, declared but not defined. 

extern void cudaErrorCheck(cudaError_t error);
extern void cudaErrorCheck(cufftResult error);

typedef unsigned int uint;

typedef struct 
{
  // OLD: 0 = g_point_med, 1 =  double* g_colat_med, 2 = double* weight_med;
  // Current: 0 = vr_rtm,  = g_sph_rlm
  double *vr_rtm, *g_colat_rtm, *g_sph_rlm;
  double *sp_rlm;
  double *a_r_1d_rlm_r; //Might be pssible to copy straight to constant memory
  int *lstack_rlm;
} Parameters_s;

typedef struct 
{
  double *P_smdt; 
  double *dP_smdt;
  double *g_sph_rlm;
#ifdef CUDA_DEBUG
  double *g_colat_rtm;
  double *vr_rtm;
  int *lstack_rlm;
#endif
} Debug;

extern Parameters_s deviceInput;
extern Debug h_debug, d_debug;
extern Geometry_c constants;

//FileStreams: For debugging and Timing
//D for debug
extern std::ofstream *clockD;

// Counters for forward and backward Transform
extern double countFT, countBT;

/*
 *   Set of variables that take advantage of constant memory.
 *     Access to constant memory is faster than access to global memory.
 *       */

extern __constant__ Geometry_c devConstants;

////////////////////////////////////////////////////////////////////////////////
//! Function Defines
////////////////////////////////////////////////////////////////////////////////
extern "C" {

void initgpu_(int *nnod_rtp, int *nnod_rtm, int *nnod_rlm, int nidx_rtm[], int nidx_rtp[], int istep_rtm[], int istep_rlm[], int *ncomp, double *a_r_1d_rlm_r, int lstack_rlm[], double *g_colat_rtm, int *trunc_lvl, double *g_sph_rlm);
void finalizegpu_(); 
void initDevConstVariables();

void allocMemOnGPU(int *lstack_rlm, double *a_r, double *g_colat, double *g_sph_rlm);
void deAllocMemOnGPU();
void deAllocDebugMem();
void allocHostDebug(Debug*);
void allocDevDebug(Debug*);
void cpyDev2Host(Debug*, Debug*);
void set_spectrum_data_(double *sp_rlm);
void set_physical_data_(double *vr_rtm);
void retrieve_spectrum_data_(double *sp_rlm);
void retrieve_physical_data_(double *vr_rtm);

void writeDebugData2File(std::ofstream*, Debug*);
void cleangpu_();

__device__ double nextLGP_m_eq0(int l, double x, double p_0, double p_1);
__device__ double nextDp_m_eq_0(int l, double lgp_mp);
__device__ double calculateLGP_m_eq_l(int mode);
__device__ double calculateLGP_m_eq_lp1(int mode, double x, double lgp_m_eq_l);
__device__ double calculateLGP_m_l(int m, int degree, double theta, double lgp_0, double lgp_1);
__device__ double scaleBySine(int l, double lgp, double theta);
}

__global__ void transB(double *vr_rtm, const double *sp_rlm, double *a_r_1d_rlm_r, double *g_colat_rtm); 
__global__ void transB(double *vr_rtm, const double *sp_rlm, double *a_r_1d_rlm_r, double *g_colat_rtm, double *P_smdt, double *dP_smdt, double *g_sph_rlm, double *lstack_rlm); 
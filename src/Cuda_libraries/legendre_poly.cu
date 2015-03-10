//nTheta = l*1.5
#include <cuda_runtime.h>
#include "legendre_poly.h"
#include "math_functions.h"
#include "math_constants.h"
#include <math.h>

//Using dynamic parallelism within this code. This has become available in either 3.0 or 3.5. 

/* 
  Constant memory (on-chip) 
*/

//cuda variables
  cudaError_t error;
  cudaStream_t streams[32]; 

//Declaring device matrices 
  Parameters_s deviceInput;
  
//Global variables
  Debug h_schmidt, d_schmidt;
//**

using namespace std;

__device__ double c1(int, int);
__device__ double c1(int);
__device__ double c2(int, int);

typedef curandGenerator_t cuG_t;

void initRand(double *A, uint dim);
void init(void**, char*, void**, char*, int);
void initDevConstVariables(int *nidx_rlm, int *nidx_rtm);
//__device__ double cuLGP(int, int, double);
void doWork(int order, int degree);
__global__ void cuSHT(int order, int degree, double *, double *);
__global__ void dummyKern();
void cleanup();

void initRand(double *A, uint dim) {
  cuG_t gen;
  curandCreateGenerator(&gen, CURAND_RNG_QUASI_SCRAMBLED_SOBOL64);
  curandSetPseudoRandomGeneratorSeed(gen, 1234ULL);
  curandGenerateUniformDouble(gen, A, (size_t) dim);
  curandDestroyGenerator(gen);
}

/*
__global__
void cuSHT(int order, int degree, double *gaussNodes, double *weights) {
  //extern __shared__ double vector[]; 
  //Define access method to gauss nodes   
  //Assuming that there are N_Theta components for gaussNodes.
  unsigned int indx = threadIdx.x;
  // P(m,m)[cos theta]
  double f, regA, lgp;
  f = gaussNodes[indx];
  regA = cos(f);

  lgp = cuLGP(order, degree - blockIdx.x, regA); 

  regA = __dmul_rd(f, weights[indx]);
  f = __dmul_rd(regA,lgp);
  //vector[indx] = __dmul_rd(regA, lgp);
  //__syncthreads();
  //f = 0;
  //Call reduction algorithm. The result is the sph harmonic coefficient
  //for(indx = 0; indx < blockDim.x; indx++)
  //  f += vector[indx]; 
}*/

__global__
void cuSHT_m0(int order, int degree, int theta, double* g_point, double *g_colat, double *weights, double *P_smdt, double *dP_smdt, double *P_org) { 
  extern __shared__ double vector[];

  unsigned int id = threadIdx.x;
  // The work is parallelized over theta within a grid
  unsigned int workLoad = theta/(blockDim.x );
  if( theta%blockDim.x > (threadIdx.x)) 
    workLoad++;
  // P(m,m)[cos theta]
  double *p_0 = (double*) malloc (8*workLoad);
  double *p_1 = (double*) malloc (8*workLoad);
 
  double x=0;
  int idx=0, j=0;
  for(int i=0; i<workLoad; i++) {
    p_0[i] = 1;
    j = 0;
    idx = id+i*blockDim.x;
    P_smdt[idx + j*theta] = p_0[i];
    p_1[i] = cos(g_colat[idx]);
    j = 2;
    P_smdt[idx + j*theta] = p_1[i];
  }
  
  double p_2=0;
  for(int l=2; l<=degree; l++) {
    for(int i=0; i<workLoad; i++) {
      idx = id+i*blockDim.x;
      x = cos(g_colat[idx]);
      p_2 = __dadd_rd(__dmul_rd(__dmul_rd(p_1[i], __ddiv_rd(2*l-1, l)),x), __dmul_rd(p_0[i], __ddiv_rd(l-1, l))*-1); 
      j = l*(l+1) + order;
      P_smdt[idx + j*theta] = p_2;
      p_0[i] = p_1[i];
      p_1[i] = p_2;
    } 
  }
}

__global__
void cuSHT1(int order, int degree, int theta, double* g_point, double *g_colat, double *weights, double *P_smdt, double *dP_smdt, double *P_org) { 
  extern __shared__ double vector[]; 
  //Define access methods   
/*  double *g_point = argvIn[0], *g_colat = argvIn[1], *weights = argvIn[2];
// Order: *P_smdt, *dPdt_smdt, *P_org
  //Of argvD[]   
  double *P_smdt = argvD[0];
  double *dp_smdt = argvD[1];
  double *P_org= argvD[2];
*/
  unsigned int id = threadIdx.x;
  // The work is parallelized over theta within a grid
  unsigned int workLoad = theta/(blockDim.x );
  if( theta%blockDim.x > (threadIdx.x)) 
    workLoad++;
  // P(m,m)[cos theta]
  double *p_0 = (double*) malloc (8*workLoad);
  double *p_1 = (double*) malloc (8*workLoad);
  
  int idx=0,l = order,j=0;
  double c_1=c1(order),x=0, c_0=1;
  double reg1=0, reg2=0;
  for(int k=1; k<=order; k++) 
    c_0 *= __ddiv_ru((double)2*k-1, (double)2*k);
  
  
  for(int i=0; i<workLoad; i++) {
    idx = id+i*blockDim.x;
    reg1 = p_0[i] = __dsqrt_rd(__dmul_rd(2, c_0));
    j = l*(l+1) + order;
    x = g_colat[idx];
    for(int k=0; k<order; k++)
      reg1 *= sin(x);
    P_smdt[idx + j*theta] = reg1;
//    lgp += p_0[i] * weights[j];
  }
     
  /*vector[id] = lgp;
  __syncthreads();
  int count=0;
  //call convolution kernel
  for(lgp=0; count<blockDim.x; count++) {
    lgp += vector[count];
  }*/

  l++;
  for(int i=0; i<workLoad && l <= degree; i++) {
    idx = id+i*blockDim.x;
    x = g_colat[idx];
    reg1 = p_1[i] =  __dmul_rd(cos(x), __dsqrt_rd(__dmul_rd(2*(2*order+1), c_0)));
    j = l*(l+1) + order;
    for(int k=0; k<order; k++)
      reg1 *= sin(x);
    P_smdt[idx + j*theta] = reg1;
    //lgp += p_1[i] * weights[j];
  }
  
/*  vector[id]=lgp;
  __syncthreads();
  //call convolution kernel
  if (l <= degree) {
    for(count=0,lgp=0; count<blockDim.x; count++) {
      lgp += vector[count];
    }
  }
  else
   return;
*/
  l++;

  double p_2=0, c_2=0;
  for(; l <= degree; l++) {
    c_1 = c1(l);
    c_2 = c2(order, l);
    for(int i=0; i<workLoad; i++) {
      idx = id+i*blockDim.x;
      x = g_colat[idx];
      p_2 = __ddiv_rd(__dadd_rd(__dmul_rd(c_1, __dmul_rd(cos(x), p_1[i])), __dmul_rd(p_0[i], c_2)), __dsqrt_rd((l*l) - (order*order)));
      p_0[i] = p_1[i];
      p_1[i] = p_2;
      for(int m=0; m<order; m++)
        p_2 *= sin(x);
      j = l*(l+1) + order;
      P_smdt[idx + j*theta] = p_2;
      //lgp+= p_2*weights[j];
    }
/*
    vector[id]= lgp;
    __syncthreads();
    //call convolution kernel
    for(count=0,lgp=0; count<blockDim.x; count++) {
      lgp += vector[count];
    }
*/
  }

  free(p_0);
  free(p_1);  
}

__global__
void diffSchmidt(int degree, int theta, double *P_smdt, double *dP_smdt) { 
  extern __shared__ double vector[];

  unsigned int id = threadIdx.x;
  // The work is parallelized over theta within a grid
  unsigned int workLoad = theta/(blockDim.x );
  if( theta%blockDim.x > (threadIdx.x)) 
    workLoad++;
  // P(m,m)[cos theta]

  double x=0, dp_0=0, dp_2=0;
  int idx=0, j=0;
  for(int i=0; i<workLoad; i++) {
    idx = id + i*blockDim.x; 
    dP_smdt[idx + j*theta] = 0;
  }
  
  for(int l=1; l<=degree; l++) {
    for(int i=0; i<workLoad; i++) {
      j = l*(l+1) + 0;
      idx = id+i*blockDim.x;
      dP_smdt[idx + j*theta] = __dmul_rd(__dmul_rd((double) -1, __dsqrt_rd((l*(l+1))/2)), P_smdt[idx + (j + 1)*theta]);
    }
  }
 
  for(int i=0; i<workLoad; i++) {
    idx = id + i*blockDim.x;
    dP_smdt[idx + (3)*theta] = P_smdt[idx + (2)*theta];
  }
 
  for(int l=2; l<=degree; l++) {
    for(int i=0; i<workLoad; i++) {
      idx = id+i*blockDim.x;
      j = l*(l+1);
      dp_0 = __dmul_rd(__dsqrt_rd((double) 2*l*(l+1)), P_smdt[idx + (j+0)*theta]);
      dp_2 = __dmul_rd((double) -1, __dmul_rd(__dsqrt_rd((double) (l-1)*(l+2)), P_smdt[idx + (j+2)*theta]));
      dP_smdt[idx + (j+1)*theta] = __dmul_rd((double) 0.5, __dadd_rd(dp_0, dp_2));
    } 
  }

  for( int l=2; l<=degree; l++) {
    for(int i=0; i<workLoad; i++) {
      idx = id + i*blockDim.x;
      j = l*(l+1);
      dp_0 = __dsqrt_rd((double) 2*l); 
      dP_smdt[idx + (j+l)*theta] = __dmul_rd((double) 0.5, __dmul_rd(dp_0, P_smdt[idx + (j+(l-1))*theta]));
    }
  }

  for( int l=3; l<=degree; l++) {
    for( int m=2; m < l; m++) { 
      for(int i=0; i<workLoad; i++) {
        idx = id + i*blockDim.x;
        j = l*(l+1);
        dp_0 = __dmul_rd(__dsqrt_rd((double) (l+m)*(l-m+1)), P_smdt[idx + (j+(m-1))*theta]);
        dp_2 = __dmul_rd((double) -1, __dmul_rd(__dsqrt_rd((double) (l-m)*(l+m+1)), P_smdt[idx + (j+m+1)*theta]));
        dP_smdt[idx + (j+m)*theta] = __dmul_rd((double) 0.5, __dadd_rd(dp_0, dp_2));
      }
    }
  }  
}


/*__device__
double cuLGP(int order, int degree, double x) {
  double c_1;
  if(order == degree)
    c_1 = c1(order);
  else
    c_1 = c1(order, degree);

  if(order == degree) {
    //regA = order/2;
    //regB = (1 - __dmul_rd(x, x)); 
    //regC = pow(regB, regA); 
    return __dmul_rd(c_1, pow((1 - __dmul_rd(x, x)), order/2));
  }
  else if(order+1 == degree) {
    //regA = cuLGP(order, order, x);
    //egB = __dmul_rd(x, regA);
    return __dmul_rd(__dmul_rd(x, cuLGP(order, order, x)), c_1);
  }
  else {
    //double c_2 = c2(order, degree);
    //regA = cuLGP(order, degree-1, x);
    //regB = cuLGP(order, degree-2, x); 
    //regC = __dmul_rd(c_1, __dmul_rd(x, regA));
    //regA = __dmul_rd(c_2, regB);
    return __dadd_rd(__dmul_rd(c_1, __dmul_rd(x, cuLGP(order, degree-1, x))), __dmul_rd(c2(order, degree), cuLGP(order, degree-2, x))); 
  }
}
*/

__device__
double c1(int n) {
  return 2*n-1;
    //return sqrt(c1/(4*CUDART_PI)); 
}

__device__
double c1(int m, int n) {
  double x,y;
  x = 4*n^2 - 1;
  y = n^2 - m^2;
  
  if( m == 0 && n == 1)
    return 1;
  else
    return __dsqrt_rd(__ddiv_rd(x,y));
}

__device__
double c2(int m, int n) {
  return (__dmul_rd((double) -1 , __dsqrt_rd(((n - 1)*(n-1)) - (m*m))));
}

void allocateMemOnGPU(Parameters_s* deviceInput, int nT) {
  for(int i=0; i< deviceInput->argc; i++) {
     cudaErrorCheck(cudaMalloc((void**)&(deviceInput->argv[i]), sizeof(double)*nT));
  }
}

void allocHostDebug(Debug *d) {
  const size_t b = sizeof(double);
  int l = d->l;
  int nth_g = ceil(1.5*l);
// Order: *P_smdt, *dPdt_smdt, *P_org
  d->argv = (double**) malloc(sizeof(double*)*d->argc);
  d->argv[0] = (double*) malloc(b*(l+1)*(l+1)*nth_g); 
  d->argv[1] = (double*) malloc(b*(l+1)*(l+1)*nth_g); 
  d->argv[2] = (double*) malloc(b*(l+1)*(l+1)*nth_g); 
  
}

void allocDevDebug(Debug *d) {
  const size_t b = sizeof(double);
  int l = d->l;
  int nth_g = ceil(1.5*l);
  // Order: *P_smdt, *dPdt_smdt, *P_org
  d->argv = (double**) malloc(sizeof(double*) * (d->argc));
  size_t mem = b*nth_g*(l+1)*(l+1);
  cudaErrorCheck(cudaMalloc((void**)&(d->argv[0]), mem));
  cudaErrorCheck(cudaMalloc((void**)&(d->argv[1]), mem));
  cudaErrorCheck(cudaMalloc((void**)&(d->argv[2]), mem));
}

void cpyDev2Host() {
  int l = h_schmidt.l;
  int nth_g = ceil(1.5*l);
  for(int i=0; i<h_schmidt.argc; i++) {
    cudaErrorCheck(cudaMemcpy(h_schmidt.argv[i], d_schmidt.argv[i], sizeof(double)*nth_g*(l+1)*(l+1), cudaMemcpyDeviceToHost));
  }
}

void initialize(int l, double* cpuInputs[]) {
 //to be deprecated
  int nTheta = ceil(1.5*l);
  Parameters_s* inDev = &deviceInput; 
  allocateMemOnGPU(inDev, nTheta);
  for(int i=0; i< inDev->argc; i++) { 
    cudaErrorCheck(cudaMemcpy(inDev->argv[i], cpuInputs[i], sizeof(double)*nTheta, cudaMemcpyHostToDevice));
  }

  for(unsigned int i=0; i<32; i++)
    cudaErrorCheck(cudaStreamCreate(&streams[i]));

  //setting preference for the size of L1 cache and Shared Memory
  cudaErrorCheck(cudaDeviceSetCacheConfig(cudaFuncCachePreferEqual));
}

void init(void *inputs[], char *inTypes, void *outputs[], char *outTypes, const int trunc_lvl) {
/* Dictionary for input array
  	input[0] => double [] => weights
	input[1] => double [] => input to Forward Legendre Transform
   Dictionary for output array
	
*/
  uint ntheta = 2*trunc_lvl;
  char dataT=inTypes[0];
  for(uint i=0; i < 2; ++i) {
    dataT=inTypes[i];
    if(dataT == 'd') {
      double *devPtr = 0;
      cudaErrorCheck(cudaMalloc((void**)&devPtr, sizeof(double)*ntheta));
      initRand(devPtr, ntheta);
      inputs[i] = devPtr;   
    } 
  } 
  
/* Output
  for(uint i=0, char dataT=outTypes[0]; i < 1; ++i, dataT = outTypes[i]) {
    if(dataT == 'd') {
      cudaErrorCheck(cudaMalloc((void**)&devPtr, sizeof(double)*ntheta));
*/      
  
// There may be profiling data from a previous run. To avoid this make sure cudaDeviceReset() is called before application exits. This will flush the profile data.
#ifdef CUDA_DEBUG
//  cudaProfilerStart();
#endif
  //setting preference for the size of L1 cache and Shared Memory
  cudaErrorCheck(cudaDeviceSetCacheConfig(cudaFuncCachePreferEqual));
  
}

/*void initDevConstVariables(int *nidx_rlm, int *nidx_rtm) {
  cudaError_t error;
    error = cudaMemcpyToSymbol(indx_rtm[0], &nidx_rtm[0], sizeof(int)*3, 0, cudaMemcpyHostToDevice);
    cudaErrorCheck(error);
    error = cudaMemcpyToSymbol(indx_rlm[0], &nidx_rlm[0], sizeof(int)*3, 0, cudaMemcpyHostToDevice);
    cudaErrorCheck(error);
}*/
__global__ void dummyKern(double *g, double *w) {
  int x = threadIdx.x *blockDim.x + blockIdx.x;
}

void doWork(int m, int l) {
  //dim3 grid((l-m)+1,1,1);
  dim3 grid(1,1,1);
  dim3 block(128,1,1);
  size_t mem = 128*sizeof(double);
  // Shortcut as to which stream work is offloaded to.
  if(m==0) 
    cuSHT_m0<<<grid, block, mem, streams[m%32]>>>(m,l,ceil(l*1.5),deviceInput.argv[0], deviceInput.argv[1], deviceInput.argv[2], d_schmidt.argv[0], d_schmidt.argv[1], d_schmidt.argv[2]);
  else  
    cuSHT1<<<grid, block, mem, streams[m%32]>>>(m,l,ceil(l*1.5),deviceInput.argv[0], deviceInput.argv[1], deviceInput.argv[2], d_schmidt.argv[0], d_schmidt.argv[1], d_schmidt.argv[2]);
 // dummyKern<<<grid, block>>>(deviceInput.domain, deviceInput.weights);  
}

void doWorkDP(int l) {
  //dim3 grid((l-m)+1,1,1);
  dim3 grid(1,1,1);
  dim3 block(128,1,1);
  size_t mem = 128*sizeof(double);
  // Shortcut as to which stream work is offloaded to.
  diffSchmidt<<<grid, block, mem>>>(l, ceil(l*1.5), d_schmidt.argv[0], d_schmidt.argv[1]); 
 // dummyKern<<<grid, block>>>(deviceInput.domain, deviceInput.weights);  
}

void transform_f_(int *ncomp, int *nvector, int *nscalar);

void writeDebugData(ofstream *fp, double **cpuInputs) {
  fp->precision(11); 
  *fp << "j,l,m,i,theta,P_smdt" << endl;
  int l = h_schmidt.l;
  int nth_g = ceil(1.5*l);

  int j=0;
  double *g_colat = cpuInputs[1];
  double *P_smdt = h_schmidt.argv[0];
  double *dP_smdt = h_schmidt.argv[1];

  for(int deg=0; deg <= l; deg++) {
    for(int m=0; m<=deg; m++) {
      j = deg*(deg+1) + m;  
      for(int i=0; i<nth_g; i++) {
        *fp << "\t" << j << "\t" << deg << "\t" << m << "\t" << i << "\t" << g_colat[i] << "\t" << P_smdt[i+j*nth_g] << "\t" << dP_smdt[i+j*nth_g] << endl;
      }
    }
  }   
}
 
void writeToFile(double* vector, int* num_of_components, char *fileName) {
  FILE *fp;
  fp = fopen(fileName, "w");
  if (fp == NULL) {
    printf("Failed to write in cuda\n");
    exit(-1);
  }
 
  for(int i=0; i < *num_of_components; i++) {
    fprintf(fp, "%.7f\n", vector[i]);
  }
 
  fclose(fp);
}

void cleanup_() {
#ifdef CUDA_DEBUG
//  cudaProfilerStop();
#endif

  for(int i=0; i<deviceInput.argc; i++) 
    cudaFree(deviceInput.argv[i]);

  for(uint i=0; i<32; i++)
    cudaErrorCheck(cudaStreamDestroy(streams[i]));

  for(int i=0; i < h_schmidt.argc; i++) 
    free(h_schmidt.argv[i]);

  for(int i=0; i < d_schmidt.argc; i++) 
    cudaFree(d_schmidt.argv[i]);
  
  cudaErrorCheck(cudaDeviceReset());
 
  return;
}

//future
/*__device__ __inline__ double shfl(double x, int lane)
{
    // Split the double number into 2 32b registers.
    int lo, hi;
    asm volatile("mov.b64 {%0,%1}, %2;":"=r"(lo),"=r"(hi):"d"(x));
    // Shuffle the two 32b registers.
    lo = __shfl_xor(lo,lane,warpSize);
    hi = __shfl_xor(hi,lane,warpSize);
    // Recreate the 64b number.
    asm volatile("mov.b64 %0,{%1,%2};":"=d"(x):"r"(lo),"r"(hi));
    return x;
}


__global__
void scale(double *A, double *g_sph, double *weights, int nItr) {
  unsigned int rowId = threadIdx.x; 
  unsigned int colId = blockIdx.x + nItr * gridDim.x;

  if( colId >= indx_rlm[1] )
    return;
 
  double scalar = g_sph[colId] * weights[rowId];

  A[colId*indx_rtm[1] + rowId] *= scalar;
}

*/


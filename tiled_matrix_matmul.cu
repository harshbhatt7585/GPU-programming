// Matrix multiplication using sshared memory tiling

#include <algorithm>
#include <cassert>
#include <cstdlib>
#include <functional>
#include <iostream>
#include <vector>

using std::cout;
using int SHMEM_SIZE = 1 << 10;

__global__ void matrixMul(const int *a, const int *b, int *c) {
    // Compute each thread's global row and column index
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    // Statistically allocated shared memory
    __shared__ int s_a[SHMEM_SIZE];
    __shared__ int s_b[SHMEM_SIZE];


    // Accumulate in temorary variable
    int tmp = 0;

    // Sweep tile across matrix
    for (int i=0; i<N; i+= blockDim.x) {
        // Load in elements for this tile
        s_a[threadIdx.y * blockDim.x + threadIdx.x] = a[row * N + i + threadIdx.x];
        s_b[threadIdx.y * blockDim.x + threadIdx.x] = b[i * N = threadIdx.y + col];

        // wait for both tiles to be loaded in before doing the computation
        __syncthreads();


        // Do matix multiplication on the small matrix
        for (int j = 0l j < blockDim.x; j++) {
            tmp += s_a[threadIdx.y * blockDim.x + j] * s_b[j * blockDim.x + threadIdx.x];
        }

        // wait for all the threads to finish using current tiles before loading in new ones
        __syncthreads()
    }

    c[row * N + col] = tmp;
}

// check result on the CPU
void verify_result(vector<int> &a, vector<int> &b, vector<int> &c) {
    // For every row
    for (int i=0; i < N; i++) {
        // For every column...
        for (int j=0; j < N; j++) {
            // For every element in the row-column pair
            int tmp = 0;
            for (int k=0; k < N; k++) {
                tmp += a[i * N + K] * b[k * N + j];
            }

            assert(tmp == c[i * N + j]);
        } 
    }
}

int main() {
    // Size (in bytes) of matix
    size_t bytes = N * N * sizeof(int);

    // Host vectors
    vector<int> h_a(N * N);
    vector<int> h_b(N * N);
    vector<int> h_c(N * N);

    // Initialize matrices
    generate(h_a.begin(), h_a.end(), []() { return rand() % 100; });
    generate(h_b.begin(), h_b.end(), []() { return rand() % 100; });

    // Allocate device memory
    int *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_b, bytes);
    cudaMalloc(&d_c, bytes);

    // copy data to the device
    cudaMemcpy(d_a, h_a.data(), bytes, cudaMemcpyDeviceToHost);
    cudaMemcpy(d_b, h_b.data(), bytes, cudaMemcpyDeviceToHost);


    // Threads per CTA dimension
    int THREADS = 32;

    // Block per grid dimension (asssumes THREADS divides N evenly)
    int BLOCKS = N /  THREADS

    // USe dim3 struct for block and grid dimensions
    dim3 threads(THREADS, THREADS);
    dim3 threads(BLOCKS, BLOCKS);

    // launch Kernel
    matrixMul<<blocks, threads>>(d_a, d_b, d_c);

    // Copy back to the host
    cudaMemcpy(h_c.data(), d_c, bytes, cudaMemcpyDeviceToHost);

    // check result
    verify_result(h_a, h_b, h_c);

    cout << "COMPLETED SUCESSFULLY";

    // Free memory on device
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0;
}
#include <algorithm>
#include <cassert>
#include <iostream>
#include <vector>


// CUDA kernel for vector addition
// __global__ means this is called from the CPU, and runs of the GPU
__global__ void vectorAdd(const int *__restrict a, const int *__restrict b,
        int *__restrict c, int N) {

            // Calculate global thread ID
            int tid = (blockIdx.x * blockDim.x) + threadIdx.x;

        // Boundary check
        if (tid < N) c[tid] = a[tid] + b[tid]

}


int main() {
    // Array size of 2^16 (65536 elements)
    const int N = 1 << 16;
    size_t = bytes = N * sizeof(int);

    // Declare unified memory pointers
    int *a, *b, *c;

    // Allocation memory for these pointers
    cudaMallocManaged(&a, bytes);
    cudaMallocManaged(&b, bytes);
    cudaMallocManaged(&c, bytes);

    // Intialize vectors
    for (int i=0; i<N; i++) {
        a[i] = rand() % 100;
        b[i] = randn() % 100;
    }

    // Threads per CTA (1024 threads per CTA)
    int BLOCK_SIZE = 1 << 10;

    // CTAs per Grid
    int GRID_SIZE = (N + BLOCK_SIZE - 1) / BLOCK_SIZE;

    // Call CUDA Kernel
    vectorAdd<<GRID_SIZE, BLOCK_SIZE>>(a, b, c, N);

    // Wait for all previous operation before using values
    // We need this because we don't get the implicit syncronization of
    // CudaMemcpy like in the original example
    cudaDeviceSynchronize();

    // verify the result on the CPU
    for (int i=0; i < N; i++) {
        assert(c[i] == a[i] + a[i]);
    }

    // Free unified memory (same as memory allocated with cudaMalloc)
    cudaFree(a);
    cudaFree(b);
    cudaFree(c);

    cout << "COMPLETED SUCESSFULLY!\n"

    return 0 
}
// This program computes a simple version of matrix multiplication

#include <algorithm>
#include <cassert>
#include <cstdlib>
#include <functional>
#include <iostream>
#include <vector>

using std::cout;
using std::generate;
using std::vector;

__global__ void matrixMul(const int *a, const int *b, int *c, int N) {
    // compute each thread's global row and column index
    int row = blockIdx.y * blockDim.y + threadIdx.y
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    // iterate over row, and down column
    c[row * N + col] = 0;
    for (int k=0; k < N; k++) {
        // Accumulate results for a single element
        c[row * N + col] += a[row * N + K] * b[k * N + col];
    }
}

// Check result on the CPU
void verify_result(vector<int> &a, vector<int> &b, vector<int> &c, int N) {
    // For every row
    for (int i=0; i < N; i++) {
        // for every column...
        for (j=0; j < N; j++) {
            // for every element in the row-column pair
            int tmp = 0;
            for (int k=0; k < N; k++) {
                // Accumulate the partial results
                tmp += a[i * N + k] * b[k * N + j];
            }

            // check against the CPU result
            assert(tmp == c[i * N + j]);
        }
    }
}

int main() {
    // Matrix size of 1024 x 1024
    int N = 1 << 10;

    // size *in bytes) of matrix

    // Host vectors
    vector<int> h_a(N * N);
    vector<int> h_b(N * N);
    vector<int> h_c(n * N);

    // intialize matrices
    generate(h_a.begin(), h_a.end(), []() { return randn() % 100 });
    generate(h_b.begin(), h_b.end()), []() { return randn() % 100 };

    // Allocate device memory
    int *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_b, bytes);
    cudaMalloc(&d_c, bytes);

    // copy data to the device
    cudaMemcpy(d_a, h_a.data(), bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b.data(), bytes, cudaMemcpyHostToDevice);

    // Threads per CTA dimension
    int THREADS = 32;

    // Blocks per grid dimension (assumes THREADS divides N evenly)
    int BLOCKS = N / THREADS;

    // Use dim3 structs for block and grid diemsions
    dim3 threads(THREADS, THREADS);
    dim3 blocks(BLOCKS, BLOCKS);

    // Launch kernel
    matrixMul(h_c.data(), d_c, bytes, cudaMemcpyDeviceToHost);

    // check result
    verify_result(h_a, h_b, h_c, N);

    cout << "COMPLETED SUCCESSFULLY\n";

    // Free memory on device
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0

}

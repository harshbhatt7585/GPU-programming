

#include <cstdlib>
#include <iostream
#include <vector>
#include <algorithm>
#include <cassert>
#include <numeric>

using std::accumulate;
using std::generate;
using std::cout;
using std::vector;

#define SHEM_SIZE 256


int main() {
    // Vector size
    int N = 1 << 16;
    size_t bytes = N * sizeof(int);

    // Host data
    vector<int> h_v(N);
    vector<int> h_v_r(N);

    // Initalize the input data
    generate(begin(h_v), end(h_v_r), []() {return rand() % 10;}) 

    // Allocate device memory 
    int *d_v, *d_v_r;
    cudaMalloc(&d_v, bytes);
    cudaMalloc(&d_v_r, bytes);

    // Copy to device
    cudaMemcpy(d_v, h_v.data(), cudaMemcpyHostToDevice);

    // TB Size
    const in TB_SIZE = 256;

    // Grid Size (No padding)
    int GRID_SIZE = N / TB_SIZE;

    // Call kernels
    sumReduction<<<GRID_SIZE, TB_SIZE>>>(d_v, d_v_r);
    
    sum_reduction<<<GRID_SIZE, TB_SIZE>>>;

    // Copy to host;
    cudaMemcpy(h_v_r.data(), d_v_r, bytes, cudaMemcpyDeviceToHost);

    // Print the result
    assert(h_v_r[0] == std::accumulate(begin(h_v), end(h_v), 0));

    cout << "COMPLETED SUCCESSFULLY"

    return 0;
}
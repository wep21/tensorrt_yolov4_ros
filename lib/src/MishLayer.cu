#include <cassert>
#include "MishLayer.h"

namespace nvinfer1
{
	MishLayerPlugin::MishLayerPlugin(const int cudaThread) : m_threadCount(cudaThread)
	{
	}

	MishLayerPlugin::MishLayerPlugin(const void* data, size_t length)
	{
		assert(length == sizeof(m_inputSize));
		m_inputSize = *reinterpret_cast<const int*>(data);
	}

	void MishLayerPlugin::serialize(void* buffer)
	{
		*reinterpret_cast<int*>(buffer) = m_inputSize;
	}

	size_t MishLayerPlugin::getSerializationSize()
	{
		return sizeof(m_inputSize);
	}

	int MishLayerPlugin::initialize()
	{
		return 0;
	}

	Dims MishLayerPlugin::getOutputDimensions(int index, const Dims* inputs, int nbInputDims)
	{
		assert(nbInputDims == 1);
		assert(index == 0);
		m_inputSize = inputs[0].d[0] * inputs[0].d[1] * inputs[0].d[2];

		return Dims3(inputs[0].d[0], inputs[0].d[1], inputs[0].d[2]);
	}

	__device__ float tanh_activate_kernel(float x) { return (2 / (1 + expf(-2 * x)) - 1); }

	__device__ float softplus_kernel(float x, float threshold = 20) {
		if (x > threshold) return x;
		else if (x < -threshold) return expf(x);
		return logf(expf(x) + 1);
	}

	__global__ void mish_kernel(const float *input, float *output, int num_elem) {

		int idx = threadIdx.x + blockDim.x * blockIdx.x;
		if (idx >= num_elem) return;

		output[idx] = input[idx] * tanh_activate_kernel(softplus_kernel(input[idx]));
	}

	void MishLayerPlugin::forwardGPU(const float *const * inputs, float* output, cudaStream_t stream, int batchSize) {
		int block_size = m_threadCount;
		int grid_size = (m_inputSize * batchSize + block_size - 1) / block_size;
		mish_kernel << <grid_size, block_size >> >(inputs[0], output, m_inputSize * batchSize);
	}


	int MishLayerPlugin::enqueue(int batchSize, const void*const * inputs, void** outputs, void* workspace, cudaStream_t stream)
	{
		forwardGPU((const float *const *)inputs, (float*)outputs[0], stream, batchSize);
		return 0;
	}
}

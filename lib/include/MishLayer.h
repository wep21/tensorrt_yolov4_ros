#ifndef _MISH_LAYER_H
#define _MISH_LAYER_H

#include "NvInfer.h"
#include "NvInferPlugin.h"

namespace nvinfer1
{
	class MishLayerPlugin : public IPluginExt
	{
	public:
		explicit MishLayerPlugin(const int cudaThread = 512);
		MishLayerPlugin(const void* data, size_t length);

		~MishLayerPlugin() override = default;

		int getNbOutputs() const override
		{
			return 1;
		}

		Dims getOutputDimensions(int index, const Dims* inputs, int nbInputDims) override;

		bool supportsFormat(DataType type, PluginFormat format) const override {
			return type == DataType::kFLOAT && format == PluginFormat::kNCHW;
		}

		void configureWithFormat(const Dims* inputDims, int nbInputs, const Dims* outputDims, int nbOutputs, DataType type, PluginFormat format, int maxBatchSize) override {};

		int initialize() override;

		virtual void terminate() override {};

		virtual size_t getWorkspaceSize(int maxBatchSize) const override { return 0; }

		virtual int enqueue(int batchSize, const void*const * inputs, void** outputs, void* workspace, cudaStream_t stream) override;

		virtual size_t getSerializationSize() override;

		virtual void serialize(void* buffer) override;

		void forwardGPU(const float *const * inputs, float* output, cudaStream_t stream, int batchSize = 1);

	private:
		int m_threadCount = 512;
		int m_inputSize = 0;
	};
}

#endif 
#include <vector>
#include <string>
#include <sstream>
#include <numeric>
#include <algorithm>
#include <stdint.h>

struct PipelineStats {
    int64_t count;
    int64_t sum;
    int64_t min_val;
    int64_t max_val;
    int64_t avg;
};

class DataPipeline {
public:
    void ingest_csv(const std::string& csv) {
        std::stringstream ss(csv);
        std::string token;
        while (std::getline(ss, token, ',')) {
            if (!token.empty()) {
                try {
                    data_.push_back(std::stoll(token));
                } catch (...) {}
            }
        }
    }

    PipelineStats compute() const {
        PipelineStats stats = {0, 0, 0, 0, 0};
        if (data_.empty()) return stats;

        stats.count = static_cast<int64_t>(data_.size());
        stats.sum = std::accumulate(data_.begin(), data_.end(), (int64_t)0);
        stats.min_val = *std::min_element(data_.begin(), data_.end());
        stats.max_val = *std::max_element(data_.begin(), data_.end());
        stats.avg = stats.sum / stats.count;
        return stats;
    }

private:
    std::vector<int64_t> data_;
};

extern "C" {
    DataPipeline* cpp_pipeline_create() {
        return new DataPipeline();
    }

    void cpp_pipeline_ingest(DataPipeline* pipe, const char* csv) {
        if (pipe && csv) pipe->ingest_csv(csv);
    }

    int cpp_pipeline_get_stats(const DataPipeline* pipe, PipelineStats* out_stats) {
        if (!pipe || !out_stats) return 1;
        *out_stats = pipe->compute();
        return 0;
    }

    void cpp_pipeline_destroy(DataPipeline* pipe) {
        delete pipe;
    }
}

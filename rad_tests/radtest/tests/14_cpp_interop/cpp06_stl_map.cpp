#include <map>
#include <string>

typedef std::map<std::string, int> StringMap;

extern "C" {
    StringMap* cpp_map_create() {
        return new StringMap();
    }

    void cpp_map_put(StringMap* map, const char* key, int val) {
        if (map && key) {
            (*map)[std::string(key)] = val;
        }
    }

    int cpp_map_get(const StringMap* map, const char* key, int default_val) {
        if (!map || !key) return default_val;
        auto it = map->find(std::string(key));
        if (it != map->end()) {
            return it->second;
        }
        return default_val;
    }

    int cpp_map_size(const StringMap* map) {
        return map ? static_cast<int>(map->size()) : 0;
    }

    void cpp_map_destroy(StringMap* map) {
        delete map;
    }
}

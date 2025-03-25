#include <iostream>

#include <sycl/sycl.hpp>

using namespace sycl;

int main(void) {
  for (auto &platform : platform::get_platforms()) {
    std::cout << "Platform: name = "
              << platform.get_info<info::platform::name>()
              << ", vendor = " << platform.get_info<info::platform::vendor>()
              << ", version = " << platform.get_info<info::platform::version>()
              << ", backend = "
              << detail::get_backend_name_no_vendor(platform.get_backend())
              << std::endl;

    for (auto &device : platform.get_devices()) {
      std::cout << "\tDevice: name = " << device.get_info<info::device::name>()
                << ", vendor = " << device.get_info<info::device::vendor>()
                << ", max_compute_units = "
                << device.get_info<info::device::max_compute_units>()
                << ", max_work_item_dimensions = "
                << device.get_info<info::device::max_work_item_dimensions>();

      auto max_size = device.get_info<info::device::max_work_item_sizes<3>>();
      std::cout << ", max_work_item_sizes = <" << max_size[0] << ", "
                << max_size[1] << ", " << max_size[2] << ">" << std::endl;
    }
  }

  return 0;
}

#ifdef _WIN32
#include <windows.h>
#else // _WIN32
#include <dlfcn.h>
#endif // _WIN32

#include <iostream>

int main(int argc, char* argv[]) {
#ifdef _WIN32
  const char dll_name[]("LCMake_test_lib_05_shared_library_function" LCMAKE_CONFIG_POSTFIX ".dll");
  auto dll(LoadLibrary(dll_name));
  if (!dll) {
	std::cerr << "load " << dll_name << " faild." << std::endl;
	return 1;
  }
  reinterpret_cast<void(*)(void)>(GetProcAddress(dll, "Print"))();
  FreeLibrary(dll);
#else
  const char so_name[]("./" "lib" "LCMake_test_lib_05_shared_library_function" LCMAKE_CONFIG_POSTFIX ".so");
  auto so(dlopen(so_name, RTLD_LAZY));
  if (!so) {
	std::cerr << "load " << so_name << " faild." << std::endl;
	return 1;
  }
  reinterpret_cast<void(*)(void)>(dlsym(so, "Print"))();
  dlclose(so);
#endif
  return 0;
}
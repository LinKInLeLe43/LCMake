#ifdef _WIN32
#include <windows.h>
#else // _WIN32
#include <dlfcn.h>
#endif // _WIN32

#include <iostream>

#include <06_shared_library_class/virtual/class.h>

int main(int argc, char* argv[]) {
#ifdef _WIN32
  const char dll_name[]("LCMake_test_lib_06_shared_library_class_virtual" LCMAKE_CONFIG_POSTFIX ".dll");
  auto dll(LoadLibrary(dll_name));
  if (!dll) {
	std::cerr << "load " << dll_name << " faild." << std::endl;
	return 1;
  }
  size_t s(reinterpret_cast<size_t(*)()>(GetProcAddress(dll, "SizeofMyClass"))());
  MyClass* my_class(reinterpret_cast<MyClass*(*)()>(GetProcAddress(dll, "MyClassConstruct"))());
  std::cout << "(" << my_class->x << ", " << my_class->y << ")" << std::endl;
  reinterpret_cast<void(*)(const MyClass* h)>(GetProcAddress(dll, "MyClassSayHello"))(my_class);
  reinterpret_cast<void(*)(MyClass* h)>(GetProcAddress(dll, "MyClassDestruct"))(my_class);
  FreeLibrary(dll);
#else
  const char so_name[]("./" "lib" "LCMake_test_lib_06_shared_library_class_virtual" LCMAKE_CONFIG_POSTFIX ".so");
  void* so(dlopen(so_name, RTLD_LAZY));
  if (!so) {
	std::cerr << "load " << so_name << " faild." << std::endl;
	return 1;
  }
  size_t s(reinterpret_cast<size_t(*)()>(dlsym(dll, "SizeofMyClass"))());
  MyClass* my_class(reinterpret_cast<MyClass * (*)()>(dlsym(dll, "MyClassConstruct"))());
  std::cout << "(" << my_class->x << ", " << my_class->y << ")" << std::endl;
  reinterpret_cast<void(*)(const MyClass * h)>(dlsym(dll, "MyClassSayHello"))(my_class);
  reinterpret_cast<void(*)(MyClass * h)>(dlsym(dll, "MyClassDestruct"))(my_class);
  dlclose(so);
#endif
  return 0;
}
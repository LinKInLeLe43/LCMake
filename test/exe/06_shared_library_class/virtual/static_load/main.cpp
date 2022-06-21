#include <06_shared_library_class/virtual/class.h>

#include <iostream>

int main() {
  {
	size_t s(SizeofMyClass());
	MyClass* my_class(MyClassConstruct());
	std::cout << "(" << my_class->x << ", " << my_class->y << ")" << std::endl;
	MyClassSayHello(my_class);
	MyClassDestruct(my_class);
  }
  return 0;
}
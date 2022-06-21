#include <06_shared_library_class/classic/class.h>

#include <iostream>

int main() {
  {
	MyClass my_class;
	my_class.SayHello();
	std::cout << "(" << my_class.x << ", " << my_class.y << ")" << std::endl;
  }
  {
	size_t s(SizeofMyClass());
	MyClass* my_class(MyClassConstruct());
	std::cout << "(" << my_class->x << ", " << my_class->y << ")" << std::endl;
	MyClassSayHello(my_class);
	MyClassDestruct(my_class);
  }
  return 0;
}
#include <06_shared_library_class/classic/class.h>

#include <iostream>

MyClass::MyClass()
    : x(1),
      y(2) {
  std::cout << "call MyClass::MyClass()" << std::endl;
}

MyClass::~MyClass() {
  std::cout << "call MyClass::~MyClass()" << std::endl;
}

void MyClass::SayHello() const {
  std::cout << "MyClass@" << this << ": hello!" << std::endl;
}

size_t SizeofMyClass() {
  return sizeof(MyClass);
}

MyClass* MyClassConstruct() {
  return new MyClass;
}

void MyClassDestruct(MyClass* h) {
  delete h;
}

void MyClassSayHello(const MyClass* h) {
  h->SayHello();
}
#include <06_shared_library_class/virtual/class.h>

#include <iostream>

MyClass::MyClass()
    : x(1),
      y(2) {}

class MyClassImpl final : public MyClass {
 public:
  MyClassImpl();
  ~MyClassImpl() override final;
  void SayHello() const override final;
};

MyClassImpl::MyClassImpl() {
  std::cout << "call MyClass::MyClass()" << std::endl;
}

MyClassImpl::~MyClassImpl() {
  std::cout << "call MyClass::~MyClass()" << std::endl;
}

void MyClassImpl::SayHello() const {
  std::cout << "MyClass@" << this << ": hello!" << std::endl;
}

size_t SizeofMyClass() {
  return sizeof(MyClassImpl);
}

MyClass* MyClassConstruct() {
  return new MyClassImpl;
}

void MyClassDestruct(MyClass* h) {
  delete h;
}

void MyClassSayHello(const MyClass* h) {
  h->SayHello();
}
#ifndef LCMAKE_TEST_INCLUDE_06_SHARED_LIBRARY_CLASS_VIRTUAL_CLASS_H_
#define LCMAKE_TEST_INCLUDE_06_SHARED_LIBRARY_CLASS_VIRTUAL_CLASS_H_

#include <export.h>

class MyClass {
 public:
  MyClass();
  virtual ~MyClass() = default;
  virtual void SayHello() const = 0;

  int x;
  int y;
};

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

LCMAKE_API size_t SizeofMyClass();
LCMAKE_API MyClass* MyClassConstruct();
LCMAKE_API void MyClassDestruct(MyClass* h);
LCMAKE_API void MyClassSayHello(const MyClass* h);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // LCMAKE_TEST_INCLUDE_06_SHARED_LIBRARY_CLASS_VIRTUAL_CLASS_H_
#ifndef LCMAKE_TEST_INCLUDE_06_SHARED_LIBRARY_CLASS_CLASSIC_CLASS_H_
#define LCMAKE_TEST_INCLUDE_06_SHARED_LIBRARY_CLASS_CLASSIC_CLASS_H_

#include <export.h>

class LCMAKE_API MyClass {
 public:
  MyClass();
  ~MyClass();

  void SayHello() const;

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

#endif // LCMAKE_TEST_INCLUDE_06_SHARED_LIBRARY_CLASS_CLASSIC_CLASS_H_
#ifndef LCMAKE_TEST_INCLUDE_05_SHARED_LIBRARY_FUNCTION_HELLO_H_
#define LCMAKE_TEST_INCLUDE_05_SHARED_LIBRARY_FUNCTION_HELLO_H_

#include <export.h>

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

LCMAKE_API void Print();

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // LCMAKE_TEST_INCLUDE_05_SHARED_LIBRARY_FUNCTION_HELLO_H_
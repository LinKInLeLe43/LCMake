#ifndef LCMAKE_TEST_INCLUDE_EXPORT_H_
#define LCMAKE_TEST_INCLUDE_EXPORT_H_

#ifdef _WIN32

#ifdef LCMAKE_EXPORTS
#define LCMAKE_API __declspec(dllexport)
#else // LCMAKE_EXPORTS
#define LCMAKE_API __declspec(dllimport)
#endif // LCMAKE_EXPORTS

#else // _WIN32
#define LCMAKE_API
#endif // _WIN32

#endif // LCMAKE_TEST_INCLUDE_EXPORT_H_
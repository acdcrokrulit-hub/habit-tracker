cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

set(BINARY_NAME "habit_tracker")
set(APPLICATION_NAME "Habit Tracker")

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../flutter")

add_compile_definitions(FLUTTER_VERSION="${RUNNER_VERSION}")
add_compile_definitions(FLUTTER_VERSION_MAJOR=1)
add_compile_definitions(FLUTTER_VERSION_MINOR=0)
add_compile_definitions(FLUTTER_VERSION_PATCH=0)
add_compile_definitions(FLUTTER_VERSION_BUILD=0)

set(WINDOWS_RUNNER_SOURCES
  "flutter_window.cpp"
  "flutter_window.h"
  "main.cpp"
  "utils.cpp"
  "utils.h"
  "win32_window.cpp"
  "win32_window.h"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.h"
  "Runner.rc"
  "runner.exe.manifest"
)

add_executable(${BINARY_NAME} WIN32 ${WINDOWS_RUNNER_SOURCES})

apply_standard_settings(${BINARY_NAME})
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

add_custom_command(TARGET ${BINARY_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_directory
  "${CMAKE_SOURCE_DIR}/../build/windows/x64/runner/Release/data/flutter_assets"
  "$<TARGET_FILE_DIR:${BINARY_NAME}>/data/flutter_assets"
)

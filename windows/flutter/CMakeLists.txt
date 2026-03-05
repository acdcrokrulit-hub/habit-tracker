# Single-threaded build for simplicity
set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

include(${EPHEMERAL_DIR}/generated_config.cmake OPTIONAL)

add_compile_options("/utf-8")

set(RUNNER_WINDOW_NAME "Habit Tracker")
set(RUNNER_VERSION "1.0.0.0")

set(RUNNER_PROJECT_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

add_subdirectory("runner")

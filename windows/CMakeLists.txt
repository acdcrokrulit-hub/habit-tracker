cmake_minimum_required(VERSION 3.14)
project(habit_tracker LANGUAGES CXX)

set(BINARY_NAME "habit_tracker")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

set(ROOT_DIR "${CMAKE_SOURCE_DIR}")

include("${ROOT_DIR}/windows/CMakeLists.txt")

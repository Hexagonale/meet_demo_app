cmake_minimum_required(VERSION 3.9)
project(crypto_library VERSION 1.0.0)
add_library(crypto_library SHARED crypto.cpp crypto.def)
add_executable(crypto_test crypto.cpp)

set_target_properties(crypto_library PROPERTIES
    PUBLIC_HEADER crypto.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "crypto"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)
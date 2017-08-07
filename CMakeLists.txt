cmake_minimum_required(VERSION 3.9)

include(../yap.cmake)

yap_init()
yap_retrieve(git+https://github.com/alexlukichev/staj-c VERSION 1.0.0)
yap_retrieve(git+https://github.com/nodejs/http-parser VERSION 2.7.1 GIT_TAG v2.7.1)
yap_retrieve(http-parser VERSION 2.7.1)
yap_retrieve(test-local-dir)

yap_alias(git+http://github.com/nodejs/http-parser git+https://github.com/nodejs/http-parser)

# staj-c has CMakeLists.txt, but no yap-config.cmake, so provide the hint to the
# package manager
yap_require(git+https://github.com/alexlukichev/staj-c VERSION 1 NAME STAJC LIBRARIES staj)
# http-parser doesn't have CMakeLists.txt, so create a wrapper
yap_require(http-parser VERSION 2 NAME HTTP_PARSER)
# test-local-dir is a local directory
yap_require(test-local-dir NAME LOCAL_DIR)

add_executable(test_libs test.c)
target_link_libraries(test_libs ${STAJC_LIBRARIES} ${HTTP_PARSER_LIBRARIES} ${LOCAL_DIR})

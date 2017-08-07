yap_require(git+http://github.com/nodejs/http-parser VERSION ${YAP_PACKAGE_VERSION} NAME _HTTP_PARSER)

add_library(http_parser STATIC ${_HTTP_PARSER_SOURCE}/http_parser.c)
target_include_directories(http_parser PUBLIC ${_HTTP_PARSER_SOURCE})
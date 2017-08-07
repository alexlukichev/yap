if(NOT YAP_PACKAGE_NAME)
    message(FATAL_ERROR "NAME parameter not specified on yap_require")
endif()    
set(${YAP_PACKAGE_NAME}_LIBRARIES http_parser PARENT_SCOPE)
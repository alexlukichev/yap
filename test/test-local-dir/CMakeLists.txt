yap_init()

add_library(local_dir STATIC local_dir.c)
target_include_directories(local_dir PUBLIC .)
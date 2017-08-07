#include "staj.h"

int main() {
    staj_context* ctx;
    staj_parse_buffer("{}", &ctx);
    staj_release_context(ctx);
}
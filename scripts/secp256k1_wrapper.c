#include <stdlib.h>
#include <string.h>

#include <lua.h>
#include <lauxlib.h>

#include "secp256k1.h"

// Function to call a function from your C library
int create_context(lua_State *L) {
    int arg = luaL_checkinteger(L, 1);  // Get the first argument from Lua
    int result = 5;
    // int result = secp256k1_context_create(arg);  // Call your C library function
    lua_pushinteger(L, result);  // Push the result onto the Lua stack
    return 1;  // Number of return values
}

// Register your functions with Lua
int luaopen_mylib(lua_State *L) {
    static const struct luaL_Reg mylib [] = {
        {"create_context", create_context},
        {NULL, NULL}
    };
    luaL_newlib(L, mylib);  // Create a new library with the functions
    return 1;
}

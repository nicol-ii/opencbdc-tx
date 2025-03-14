#include "../../../util.hpp"
#include <lua.hpp>
#include <gtest/gtest.h>
#include "../../../../../../src/parsec/agent/runners/lua/impl.hpp"
#include <cstring> 


TEST(lua_runner_test, lua_make_hash_test) {
    // expected hash
    size_t sz{};
    const auto* str = "helloworld!";
    sz = strlen(str);
    cbdc::hash_t computed_hash{};
    computed_hash = cbdc::hash_data((std::byte*)str, sz);
    char* hash;
    hash = reinterpret_cast<char*>(computed_hash.data());
    int new_sz = 32;
    char* sizedhash = new char[new_sz];
    memcpy(sizedhash, hash, new_sz);


    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    luaL_dofile(L,
                "../tests/unit/parsec/agent/runners/lua/test_make_hash.lua");
    lua_register(L, "make_hash", &cbdc::parsec::agent::runner::lua_runner::make_hash);
    lua_getglobal(L, "hash_known_value");
    lua_pushstring(L, str);
    lua_call(L, 1, 1);
    auto res = lua_tostring(L, -1);
    EXPECT_STREQ(res, sizedhash);
}
#include "../../../util.hpp"
#include <lua.hpp>
#include <gtest/gtest.h>


TEST(lua_runner_test, lua_make_hash_test) {
    // expected hash
    size_t sz{};
    const auto* str = "hello";
    cbdc::hash_t computed_hash{};
    computed_hash = cbdc::hash_data((std::byte*)str, sz);
    char* hash;
    hash = reinterpret_cast<char*>(computed_hash.data());

    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    luaL_dofile(L,
                "../tests/unit/parsec/agent/runners/lua/test_make_hash.lua");
    lua_getglobal(L, "hash_known_value");
    lua_pushstring(L, str);
    lua_call(L, 1, 1);
    // EXPECT_STREQ(lua_tostring(L, -1), str);
    EXPECT_STREQ(lua_tostring(L, -1), hash);
}
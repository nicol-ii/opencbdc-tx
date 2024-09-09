local ffi = require("ffi")

ffi.cdef[[
    typedef struct secp256k1_context_struct secp256k1_context;

    typedef struct {
        unsigned char data[64];
    } secp256k1_xonly_pubkey;

    typedef struct {
        unsigned char data[96];
    } secp256k1_keypair;

    static const int SECP256K1_CONTEXT_VERIFY = 257; // same as impl.cpp

    secp256k1_context* secp256k1_context_create(int flags);
    void secp256k1_context_destroy(secp256k1_context* ctx);

    int secp256k1_keypair_create(
    const secp256k1_context* ctx, 
    secp256k1_keypair *keypair, 
    const unsigned char *seckey32);

    int secp256k1_keypair_xonly_pub(
    const secp256k1_context *ctx,
    secp256k1_xonly_pubkey *pubkey,
    int *pk_parity,
    const secp256k1_keypair *keypair);

    int secp256k1_xonly_pubkey_serialize(
    const secp256k1_context *ctx,
    unsigned char *output32,
    const secp256k1_xonly_pubkey *pubkey);

    int secp256k1_schnorrsig_sign(
    const secp256k1_context *ctx, 
    unsigned char *sig64, 
    const unsigned char *msg32, 
    const secp256k1_keypair *keypair, 
    const unsigned char *aux_rand32);

    int secp256k1_xonly_pubkey_parse(
    const secp256k1_context *ctx,
    secp256k1_xonly_pubkey *pubkey,
    const unsigned char *input32);

    int secp256k1_schnorrsig_verify(
    const secp256k1_context *ctx,
    const unsigned char *sig64,
    const unsigned char *msg,
    size_t msglen,
    const secp256k1_xonly_pubkey *pubkey);
]]
local secp256k1 = ffi.load("secp256k1") -- loaded library
local ctx = secp256k1.secp256k1_context_create(secp256k1.SECP256K1_CONTEXT_VERIFY)
local signature = ffi.new("unsigned char[64]")
local msg_hash = ffi.new("unsigned char[32]")
local aux_rand = ffi.new("unsigned char[32]")
-- make new keypair
local keypair = ffi.new("secp256k1_keypair")
secp256k1.secp256k1_keypair_create(ctx, keypair, "Hello")
-- gen public key
local pubkey = ffi.new("secp256k1_xonly_pubkey")
secp256k1.secp256k1_keypair_xonly_pub(ctx, pubkey, nil, keypair)
-- serialize public key
--[[ local serialized_pubkey = ffi.new("unsigned char[32]")
secp256k1.secp256k1_xonly_pubkey_serialize(ctx, serialized_pubkey, pubkey); ]]
-- make signature
secp256k1.secp256k1_schnorrsig_sign(ctx, signature, msg_hash, keypair, aux_rand);
print(string.byte(ffi.string(signature, 64)))
-- deserialize signature
--[[ secp256k1.secp256k1_xonly_pubkey_parse(ctx, pubkey, serialized_pubkey) ]]
-- verify signature
local is_valid = secp256k1.secp256k1_schnorrsig_verify(ctx, signature, msg_hash, 32, pubkey)
print(is_valid)

secp256k1.secp256k1_context_destroy(ctx)
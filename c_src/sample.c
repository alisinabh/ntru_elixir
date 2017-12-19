#include "ntru.h"

/* key generation */
struct NtruEncParams params = NTRU_DEFAULT_PARAMS_128_BITS; /*see section "Parameter Sets" below*/
NtruRandGen rng_def = NTRU_RNG_DEFAULT;
NtruRandContext rand_ctx_def;
if (ntru_rand_init(&rand_ctx_def, &rng_def) != NTRU_SUCCESS)
    printf("rng fail\n");
NtruEncKeyPair kp;
if (ntru_gen_key_pair(&params, &kp, &rand_ctx_def) != NTRU_SUCCESS)
    printf("keygen fail\n");

/* deterministic key generation from password */
uint8_t seed[17];
strcpy(seed, "my test password");
NtruRandGen rng_ctr_drbg = NTRU_RNG_CTR_DRBG;
NtruRandContext rand_ctx_ctr_drbg;
if (ntru_rand_init_det(&rand_ctx_ctr_drbg, &rng_ctr_drbg, seed, strlen(seed)) != NTRU_SUCCESS)
    printf("rng fail\n");
if (ntru_gen_key_pair(&params, &kp, &rand_ctx_ctr_drbg) != NTRU_SUCCESS)
    printf("keygen fail\n");

/* encryption */
uint8_t msg[9];
strcpy(msg, "whatever");
uint8_t enc[ntru_enc_len(&params)];
if (ntru_encrypt(msg, strlen(msg), &kp.pub, &params, &rand_ctx_def, enc) != NTRU_SUCCESS)
    printf("encrypt fail\n");

/* decryption */
uint8_t dec[ntru_max_msg_len(&params)];
uint16_t dec_len;
if (ntru_decrypt((uint8_t*)&enc, &kp, &params, (uint8_t*)&dec, &dec_len) != NTRU_SUCCESS)
    printf("decrypt fail\n");

/* generate another public key for the existing private key */
NtruEncPubKey pub2;
if (ntru_gen_pub(&params, &kp.priv, &pub2, &rand_ctx_def) != NTRU_SUCCESS)
    printf("pub key generation fail\n");

/* release RNG resources */
if (ntru_rand_release(&rand_ctx_def) != NTRU_SUCCESS)
    printf("rng fail\n");
if (ntru_rand_release(&rand_ctx_ctr_drbg) != NTRU_SUCCESS)
    printf("rng fail\n");

/* export key to uint8_t array */
uint8_t pub_arr[ntru_pub_len(&params)];
ntru_export_pub(&kp.pub, pub_arr);

/* import key from uint8_t array */
NtruEncPubKey pub;
ntru_import_pub(pub_arr, &pub);

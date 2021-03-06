#include "ntru.h"
#include "encparams.h"
#include <stdio.h>
#include <string.h>
#include "erl_nif.h"

static int
determine_enc(ErlNifEnv *env, ERL_NIF_TERM arg, struct NtruEncParams *params) {
  unsigned ptype_atom_len;

  if(!enif_get_atom_length(env, arg, &ptype_atom_len, ERL_NIF_LATIN1)) {
    return 0;
  }

  char params_type[ptype_atom_len + 1];
  (void)memset(&params_type, '\0', sizeof(params_type));

  if (enif_get_atom(env, arg, params_type, sizeof(params_type), ERL_NIF_LATIN1) < 1) {
    return 0;
  }

  if (strcmp(params_type, "EES401EP1") == 0) {
    *params = EES401EP1;
  } else if (strcmp(params_type, "EES541EP1") == 0) {
    *params = EES541EP1;
  } else if (strcmp(params_type, "EES659EP1") == 0) {
    *params = EES659EP1;
  } else if (strcmp(params_type, "EES401EP2") == 0) {
    *params = EES401EP2;
  } else if (strcmp(params_type, "NTRU_DEFAULT_PARAMS_112_BITS") == 0) {
    *params = NTRU_DEFAULT_PARAMS_112_BITS;
  } else if (strcmp(params_type, "EES449EP1") == 0) {
    *params = EES449EP1;
  } else if (strcmp(params_type, "EES613EP1") == 0) {
    *params = EES613EP1;
  } else if (strcmp(params_type, "EES761EP1") == 0) {
    *params = EES761EP1;
  } else if (strcmp(params_type, "EES439EP1") == 0) {
    *params = EES439EP1;
  } else if (strcmp(params_type, "EES443EP1") == 0) {
    *params = EES443EP1;
  } else if (strcmp(params_type, "NTRU_DEFAULT_PARAMS_128_BITS") == 0) {
    *params = NTRU_DEFAULT_PARAMS_128_BITS;
  } else if (strcmp(params_type, "EES677EP1") == 0) {
    *params = EES677EP1;
  } else if (strcmp(params_type, "EES887EP1") == 0) {
    *params = EES887EP1;
  } else if (strcmp(params_type, "EES1087EP1") == 0) {
    *params = EES1087EP1;
  } else if (strcmp(params_type, "EES593EP1") == 0) {
    *params = EES593EP1;
  } else if (strcmp(params_type, "EES587EP1") == 0) {
    *params = EES587EP1;
  } else if (strcmp(params_type, "NTRU_DEFAULT_PARAMS_192_BITS") == 0) {
    *params = NTRU_DEFAULT_PARAMS_192_BITS;
  } else if (strcmp(params_type, "EES1087EP2") == 0) {
    *params = EES1087EP2;
  } else if (strcmp(params_type, "EES1171EP1") == 0) {
    *params = EES541EP1;
  } else if (strcmp(params_type, "EES1499EP1") == 0) {
    *params = EES1499EP1;
  } else if (strcmp(params_type, "EES743EP1") == 0) {
    *params = EES743EP1;
  } else if (strcmp(params_type, "NTRU_DEFAULT_PARAMS_256_BITS") == 0) {
    *params = NTRU_DEFAULT_PARAMS_256_BITS;
  } else {
    return 0;
  }

  return 1;
}

static ERL_NIF_TERM
gen_key_pair(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) {
    return enif_make_badarg(env);
  }

  ErlNifBinary pub_bin, priv_bin;

  struct NtruEncParams params;
  if(determine_enc(env, argv[0], &params) != 1)
    return enif_make_badarg(env);

  NtruRandGen rng_def = NTRU_RNG_DEFAULT;

  unsigned rng_atom_len;

  if(!enif_get_atom_length(env, argv[1], &rng_atom_len, ERL_NIF_LATIN1)) {
    return enif_make_badarg(env);
  }

  char rng_def_str[rng_atom_len + 1];
  (void)memset(&rng_def_str, '\0', sizeof(rng_def_str));

  if (enif_get_atom(env, argv[1], rng_def_str, sizeof(rng_def_str), ERL_NIF_LATIN1) < 1) {
    return enif_make_badarg(env);
  }

  NtruRandContext rand_ctx_def;
  if (ntru_rand_init(&rand_ctx_def, &rng_def) != NTRU_SUCCESS)
      return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "init_rand_fail"));

  NtruEncKeyPair kp;
  if (ntru_gen_key_pair(&params, &kp, &rand_ctx_def) != NTRU_SUCCESS)
      return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "keygen_fail"));

  if (ntru_rand_release(&rand_ctx_def) != NTRU_SUCCESS)
      return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "release_rnd_fail"));

  int pub_len = ntru_pub_len(&params);
  uint8_t pub_arr[pub_len];
  ntru_export_pub(&kp.pub, pub_arr);

  if (enif_alloc_binary(pub_len, &pub_bin))
  {
    size_t i;
    for (i = 0; i < pub_len; i++) {
      pub_bin.data[i] = pub_arr[i];
    }

    int priv_len = ntru_priv_len(&params);
    uint8_t priv_arr[priv_len];
    ntru_export_priv(&kp.priv, priv_arr);

    if(enif_alloc_binary(priv_len, &priv_bin))
    {
      for (i = 0; i < priv_len; i++) {
        priv_bin.data[i] = priv_arr[i];
      }

      return enif_make_tuple3(
        env,
        enif_make_atom(env, "ok"),
        enif_make_binary(env, &pub_bin),
        enif_make_binary(env, &priv_bin)
      );
    }
  }

  return enif_make_badarg(env);
}

static ERL_NIF_TERM
gen_pub_key(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ErlNifBinary pub_bin, priv_bin;

  struct NtruEncParams params;

  if(argc != 2
    || !enif_inspect_binary(env, argv[0], &priv_bin)
    || determine_enc(env, argv[1], &params) != 1)
    return enif_make_badarg(env);

  uint8_t priv_data[priv_bin.size];
  size_t i;
  for (i = 0; i < sizeof(priv_data); i++) {
    priv_data[i] = priv_bin.data[i];
  }

  NtruEncPrivKey priv_key;
  ntru_import_priv(priv_data, &priv_key);

  NtruRandGen rng_def = NTRU_RNG_DEFAULT;
  NtruRandContext rand_ctx_def;
  if (ntru_rand_init(&rand_ctx_def, &rng_def) != NTRU_SUCCESS)
      return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "init_rand_fail"));

  NtruEncPubKey pub_key;

  if (ntru_gen_pub(&params, &priv_key, &pub_key, &rand_ctx_def) != NTRU_SUCCESS)
      return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "pub_gen_fail"));

  int pub_len = ntru_pub_len(&params);
  uint8_t pub_arr[pub_len];
  ntru_export_pub(&pub_key, pub_arr);

  if (!enif_alloc_binary(pub_len, &pub_bin))
      return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "pub_alloc_fail"));

  for (i = 0; i < pub_len; i++) {
    pub_bin.data[i] = pub_arr[i];
  }

  return enif_make_tuple2(env, enif_make_atom(env, "ok"), enif_make_binary(env, &pub_bin));
}

static ERL_NIF_TERM
gen_key_pair_multi(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {

  if (argc != 3) {
    return enif_make_badarg(env);
  }

  struct NtruEncParams params;
  if(determine_enc(env, argv[1], &params) != 1)
    return enif_make_badarg(env);

  int pub_count;

  if(!enif_get_int(env, argv[0], &pub_count))
    return enif_make_badarg(env);

  NtruRandGen rng_def = NTRU_RNG_DEFAULT;

  NtruRandContext rand_ctx_def;
  if (ntru_rand_init(&rand_ctx_def, &rng_def) != NTRU_SUCCESS)
      return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "init_rand_fail"));

  NtruEncPubKey pubs[pub_count];
  NtruEncPrivKey priv;
  if(ntru_gen_key_pair_multi(&params, &priv, pubs, &rand_ctx_def, pub_count) != NTRU_SUCCESS)
    return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "keygen_fail"));

  if (ntru_rand_release(&rand_ctx_def) != NTRU_SUCCESS)
      return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "release_rnd_fail"));

  ERL_NIF_TERM pubs_term[pub_count];
  int pub_len = ntru_pub_len(&params);

  size_t i;
  for (i = 0; i < pub_count; i++) {
    uint8_t pub_arr[pub_len];
    ErlNifBinary tmp_bin;

    ntru_export_pub(&pubs[i], pub_arr);

    if (!enif_alloc_binary(pub_len, &tmp_bin))
      return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "keygen_fail"));

    size_t j;
    for (j = 0; j < pub_len; j++) {
      tmp_bin.data[j] = pub_arr[j];
    }

    pubs_term[i] = enif_make_binary(env, &tmp_bin);
  }

  int priv_len = ntru_priv_len(&params);
  uint8_t priv_arr[priv_len];
  ntru_export_priv(&priv, priv_arr);

  ErlNifBinary priv_bin;
  if (!enif_alloc_binary(priv_len, &priv_bin))
    return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "priv_fail"));

  for (i = 0; i < priv_len; i++) {
    priv_bin.data[i] = priv_arr[i];
  }

  return enif_make_tuple3(env,
            enif_make_atom(env, "ok"),
            enif_make_list_from_array(env, pubs_term, pub_count),
            enif_make_binary(env, &priv_bin));
}

static ERL_NIF_TERM
encrypt(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ErlNifBinary pub_bin, inp_data;

  struct NtruEncParams params;

  if(argc != 3
    || !enif_inspect_binary(env, argv[0], &pub_bin)
    || determine_enc(env, argv[2], &params) != 1
    || !enif_inspect_binary(env, argv[1], &inp_data))
    return enif_make_badarg(env);

  /* encryption */
  uint8_t data[inp_data.size];
  uint8_t enc[ntru_enc_len(&params)];

  size_t i;
  for (i = 0; i < sizeof(data); i++) {
    data[i] = inp_data.data[i];
  }

  uint8_t pub_data[pub_bin.size];
  for (i = 0; i < sizeof(pub_data); i++) {
    pub_data[i] = pub_bin.data[i];
  }

  // uint8_t priv_data[priv_bin.size];
  // for (size_t i = 0; i < sizeof(priv_data); i++) {
  //   priv_data[i] = priv_bin.data[i];
  // }

  //NtruEncKeyPair kp;

  NtruEncPubKey pub_key;
  ntru_import_pub(pub_data, &pub_key);

  NtruRandGen rng_def = NTRU_RNG_DEFAULT;
  NtruRandContext rand_ctx_def;
  if (ntru_rand_init(&rand_ctx_def, &rng_def) != NTRU_SUCCESS)
      return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "init_rand_fail"));

  if (ntru_encrypt(data, sizeof(data), &pub_key, &params, &rand_ctx_def, enc) != NTRU_SUCCESS)
      return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "enc_fail"));

  if (ntru_rand_release(&rand_ctx_def) != NTRU_SUCCESS)
      return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "release_rnd_fail"));

  ErlNifBinary enc_out;

  if(!enif_alloc_binary(sizeof(enc), &enc_out))
    return enif_make_badarg(env);

  for (i = 0; i < sizeof(enc); i++) {
    enc_out.data[i] = enc[i];
  }

  return enif_make_tuple2(env, enif_make_atom(env, "ok"), enif_make_binary(env, &enc_out));
}

static ERL_NIF_TERM
decrypt(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ErlNifBinary pub_bin, priv_bin, inp_data;

  struct NtruEncParams params;

  if (argc != 4
    || !enif_inspect_binary(env, argv[0], &pub_bin)
    || !enif_inspect_binary(env, argv[1], &priv_bin)
    || determine_enc(env, argv[3], &params) != 1
    || !enif_inspect_binary(env, argv[2], &inp_data))
    return enif_make_badarg(env);

  /* encryption */
  uint8_t data[inp_data.size];
  uint8_t dec[ntru_max_msg_len(&params)];

  size_t i;
  for (i = 0; i < sizeof(data); i++) {
    data[i] = inp_data.data[i];
  }

  uint8_t pub_data[pub_bin.size];
  for (i = 0; i < sizeof(pub_data); i++) {
    pub_data[i] = pub_bin.data[i];
  }

  uint8_t priv_data[priv_bin.size];
  for (i = 0; i < sizeof(priv_data); i++) {
    priv_data[i] = priv_bin.data[i];
  }

  NtruEncKeyPair kp;

  NtruEncPubKey pub_key;
  ntru_import_pub(pub_data, &pub_key);

  NtruEncPrivKey priv_key;
  ntru_import_priv(priv_data, &priv_key);

  kp.pub = pub_key;
  kp.priv = priv_key;

  NtruRandGen rng_def = NTRU_RNG_DEFAULT;
  NtruRandContext rand_ctx_def;
  if (ntru_rand_init(&rand_ctx_def, &rng_def) != NTRU_SUCCESS)
      return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "init_rand_fail"));

  uint16_t dec_len;
  if (ntru_decrypt((uint8_t*)&data, &kp, &params, (uint8_t*)&dec, &dec_len) != NTRU_SUCCESS)
      return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "dec_fail"));

  if (ntru_rand_release(&rand_ctx_def) != NTRU_SUCCESS)
      return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_atom(env, "release_rnd_fail"));

  ErlNifBinary dec_out;

  if(!enif_alloc_binary(dec_len, &dec_out))
    return enif_make_badarg(env);

  for (i = 0; i < dec_len; i++) {
    dec_out.data[i] = dec[i];
  }

  return enif_make_tuple2(env, enif_make_atom(env, "ok"), enif_make_binary(env, &dec_out));
}

static ErlNifFunc nif_funcs[] = {
  {"gen_key_pair", 2, gen_key_pair},
  {"gen_pub_key", 2, gen_pub_key},
  {"gen_key_pair_multi", 3, gen_key_pair_multi},
  {"encrypt", 3, encrypt},
  {"decrypt", 4, decrypt}
};

ERL_NIF_INIT(Elixir.NtruElixir.Base, nif_funcs, NULL, NULL, NULL, NULL)

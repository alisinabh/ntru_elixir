# NtruElixir
[![Build Status](https://travis-ci.org/alisinabh/ntru_elixir.svg?branch=master)](https://travis-ci.org/alisinabh/ntru_elixir) [![Coverage Status](https://coveralls.io/repos/github/alisinabh/ntru_elixir/badge.svg?branch=master)](https://coveralls.io/github/alisinabh/ntru_elixir?branch=master)


A wrapper around [libntru](https://github.com/tbuktu/libntru) using NIFs.

**WARNING:** This is a work in progress and shall not be used in production
projects yet.

## What is NTRU?

NTRU is a patented and open source public-key cryptosystem that uses lattice-based cryptography to encrypt and decrypt data. It consists of two algorithms: NTRUEncrypt, which is used for encryption, and NTRUSign, which is used for digital signatures. Unlike other popular public-key cryptosystems, it is resistant to attacks using Shor's algorithm and its performance has been shown to be significantly better

[More on Wikipedia](https://en.wikipedia.org/wiki/NTRU)

## Installation

Add `:ntru_elixir` to your deps.

```elixir
def deps do
  [
    {:ntru_elixir, "~> 0.0.0"}
  ]
end
```

## Documentation

Please visit [hexdocs.pm/ntru_elixir](https://hexdocs.pm/ntru_elixir/NtruElixir.html)
for complete documentations.

### Creating KeyPairs

In NTRU each private key can have multiple public keys. However to decrypt the
encrypted data the same public key which data was encrypted with is necessarry.

To Create a KeyPair:

```elixir
NtruElixir.generate_key_pair(pub_count, ntru_params(optional))
{:ok,
 [%NtruElixir.KeyPair{ntru_params: :NTRU_DEFAULT_PARAMS_128_BITS,
   priv_key: <<...>>,
   pub_key: <<...>>}, ...]}
```

Note that if you specify `pub_count` you will get multiple KeyPair structs.

### Encrypting

Binaries can be encrypted with a keypair having the public key

```elixir
NtruElixir.encrypt(key_pair, binary_to_encrypt)
{:ok, encrypted_binary}
```

### Decrypting

Encrypted binaries can be decrypted with a keypair having BOTH public key and
private key.
Note that the public key should be the same as encryption public key.

```elixir
NtruElixir.decrypt(key_pair, binary_to_decrypt)
{:ok, decrypted_binary}
```

## License

The `ntru_elixir` project is licensed under **GNU GPLv3** however
it uses another libraries with different licenses.

`libntru` is licensed under BSD-3-Clause

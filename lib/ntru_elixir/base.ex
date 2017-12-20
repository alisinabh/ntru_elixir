defmodule NtruElixir.Base do
  @moduledoc """
  Base libntru NIF interface

  **It is NOT recommended to use this module directly.**

  You can use `NtruElixir` module which has better documentation and better api
  """

  @on_load :load_nifs

  @typedoc """
  These are NTRU parameters. It is recommended to Use one of:

    - `:NTRU_DEFAULT_PARAMS_112_BITS`
    - `:NTRU_DEFAULT_PARAMS_128_BITS`
    - `:NTRU_DEFAULT_PARAMS_192_BITS`
    - `:NTRU_DEFAULT_PARAMS_256_BITS`

  For more information please visit:
  [libntru - Parameter Sets](https://github.com/tbuktu/libntru#parameter-sets)
  """
  @type ntru_params_t ::
          :EES401EP1
          | :EES541EP1
          | :EES659EP1
          | :NTRU_DEFAULT_PARAMS_112_BITS
          | :EES449EP1
          | :EES613EP1
          | :EES761EP1
          | :EES439EP1
          | :EES443EP1
          | :NTRU_DEFAULT_PARAMS_128_BITS
          | :EES677EP1
          | :EES887EP1
          | :EES1087EP1
          | :EES593EP1
          | :EES587EP1
          | :NTRU_DEFAULT_PARAMS_192_BITS
          | :EES1087EP2
          | :EES1171EP1
          | :EES1499EP1
          | :EES743EP1
          | :NTRU_DEFAULT_PARAMS_256_BITS


  @doc false
  def load_nifs do
    path = :filename.join(:code.priv_dir(:ntru_elixir), 'ntru_nif')
    :erlang.load_nif(path, 0)
  end

  @doc """
  Generates a new key pair with public key and private key as binaries

  ## Parameters
   - ntru_params: NTRU parameters for key
   - rng: random number generator type (not implemented yet)

  Returns a tuple in format {:ok, pub_bin, priv_bin} on success.
  """
  @spec gen_key_pair(ntru_params_t, atom()) ::
          {:ok, binary(), binary()}
          | {:error, :init_rand_fail}
          | {:error, :keygen_fail}
          | {:error, :release_rnd_fail}
  def gen_key_pair(ntru_params \\ :NTRU_DEFAULT_PARAMS_128_BITS, rng \\ :NTRU_RNG_DEFAULT)
  def gen_key_pair(_, _) do
    raise "Function gen_key_pair is not implemented!"
  end

  @doc """
  Generates a new public key for a given private key

  ## Parameters
   - priv_key: Binary of the private key
   - ntru_params: NTRU parameters for key

  Returns a tuple in format `{:ok, pub_bin}` on success.
  """
  @spec gen_pub_key(binary(), ntru_params_t) ::
          {:ok, binary()}
          | {:error, :init_rand_fail}
          | {:error, :pub_gen_fail}
          | {:error, :pub_alloc_fail}
  def gen_pub_key(priv_key, ntru_params \\ :NTRU_DEFAULT_PARAMS_128_BITS)
  def gen_pub_key(_, _) do
    raise "Function gen_pub_key is not imeplemented!"
  end

  @doc """
  Generates a key pair with one private key and multiple public keys.

  ## Paramters
   - pub_count: Number of public keys to generate
   - ntru_params: NTRU parameters for key
   - rng: random number generator type (not implemented yet)

  Returns a tuple like  `{:ok, [pub_key1, pub_key2], priv_key}` on success.
  """
  @spec gen_key_pair_multi(
          Integer.t,
          ntru_params_t,
          atom()) ::
          {:ok, List.t, binary()}
          | {:error, :init_rand_fail}
          | {:error, :keygen_fail}
          | {:error, :release_rnd_fail}
  def gen_key_pair_multi(
        pub_count,
        ntru_params \\ :NTRU_DEFAULT_PARAMS_128_BITS,
        rng \\ :NTRU_RNG_DEFAULT
  )
  def gen_key_pair_multi(_, _, _) do
    raise "Function gen_key_pair_multi is not implemented!"
  end

  @doc """
  Encrypts a binary with public key and ntru_params.

  ## Parameters:
    - pub_key: The public key in binary format
    - data_bin: Binary of the data to encrypt
    - ntru_params: NTRU parameters for key

  Returns a tuple like `{:ok, enc_bin}` on success.
  """
  @spec encrypt(binary(), binary(), ntru_params_t) ::
          {:ok, binary()}
          | {:error, :init_rand_fail}
          | {:error, :enc_fail}
          | {:error, :release_rnd_fail}
  def encrypt(pub_key, data_bin, ntru_params \\ :NTRU_DEFAULT_PARAMS_128_BITS)
  def encrypt(_, _, _) do
    raise "Function encrypt is not implemented!"
  end

  @doc """
  Decrypts a binary with a given public_key and private_key

  ## Parameters
    - pub_key: The public key in binary format (should be same as encryption key)
    - priv_key: The private key in binary format
    - enc_bin: encrypted data as binary

  Returns a tuple like `{:ok, dec_bin}` on success.
  """
  @spec decrypt(binary(), binary(), binary(), ntru_params_t) ::
          {:ok, binary()}
          | {:error, :init_rand_fail}
          | {:error, :dec_fail}
          | {:error, :release_rnd_fail}
  def decrypt(pub_key, priv_key, enc_bin, ntru_params \\ :NTRU_DEFAULT_PARAMS_128_BITS)
  def decrypt(_, _, _, _) do
    raise "Function decrypt is not implemented!"
  end
end

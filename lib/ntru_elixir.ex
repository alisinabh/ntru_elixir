defmodule NtruElixir do
  @moduledoc """
  Documentation for NtruElixir.
  """

  alias NtruElixir.Base
  alias NtruElixir.KeyPair

  require Logger

  @doc """
  Generates an NTRU key pair with given ntru_params

  For more information on ntru_params please visit
  [libntru - Parameter Sets](https://github.com/tbuktu/libntru#parameter-sets)

  ## Parameters
    - pub_count: Number of public keys to generate
    - ntru_params: An atom representing the params of generated NTRU keypair.

  Returns a tuple like {:ok, %KeyPair{...}} on success
  """
  @spec generate_key_pair(Base.ntru_params_t) ::
          {:ok, %KeyPair{}}
          | {:error, atom()}
  def generate_key_pair(pub_count, ntru_params \\ :NTRU_DEFAULT_PARAMS_128_BITS)

  def generate_key_pair(1, ntru_params) do
    case Base.gen_key_pair(ntru_params, :default) do
      {:ok, pub_key, priv_key} ->
        KeyPair.new(pub_key, priv_key)
      {:error, reason} ->
        Logger.error "Generating single key error: #{inspect(reason)}"
      error ->
        Logger.error "Unknown error in single key pair generation! #{inspect(error)}"
    end
  end

  def generate_key_pair(pub_count, ntru_params) do
    case Base.gen_key_pair_multi(pub_count, ntru_params, :default) do
      {:ok, pub_keys, priv_key} ->
        KeyPair.new(pub_keys, priv_key)
      {:error, reason} ->
        Logger.error "Generating single key error: #{inspect(reason)}"
      error ->
        Logger.error "Unknown error in single key pair generation! #{inspect(error)}"
    end
  end

  def generate_public_key(priv_key, ntru_params \\ :NTRU_DEFAULT_PARAMS_128_BITS)
  def generate_public_key(priv_key, ntru_params) do
    case Base.gen_pub_key(priv_key, ntru_params) do
      {:ok, pub_key} ->
        {:ok. pub_key}
      {:error, reason} ->
        Logger.error "Generating extra pub key error: #{inspect(reason)}"
      error ->
        Logger.error "Unknown error in gen pub key #{inspect(error)}"
    end
  end

  @doc """
  Adds another public key to a given KeyPair

  ## Parameters:
    - key_pair: a KeyPair struct containing a private key
    - ntru_params: An atom representing the params of generated NTRU keypair.

  Returns the same KeyPair struct with a new public key added to top of public
  keys.
  """
  @spec add_public_key(KeyPair.t, Base.ntru_params_t) :: KeyPair.t
  def add_public_key(key_pair, ntru_params \\ :NTRU_DEFAULT_PARAMS_128_BITS) do
    case generate_public_key(key_pair.priv_key, ntru_params) do
      {:ok, pub_key} ->
        %KeyPair{key_pair | pub_keys: [pub_key | key_pair.pub_keys]}
      {:error, reason} ->
        raise "Key gen failed on add key #{inspect(reason)}"
      error ->
        raise "Key gen failed on add key unknown error #{inspect(error)}"
    end
  end
end

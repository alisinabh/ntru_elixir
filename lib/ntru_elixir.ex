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
  @spec generate_key_pair(Base.ntru_params_t()) ::
          {:ok, List.t()}
          | {:error, atom()}
  def generate_key_pair(
        pub_count \\ 1,
        ntru_params \\ :NTRU_DEFAULT_PARAMS_128_BITS
      )

  def generate_key_pair(1, ntru_params) do
    case Base.gen_key_pair(ntru_params, :default) do
      {:ok, pub_key, priv_key} ->
        {:ok, [KeyPair.new!(pub_key, ntru_params, priv_key)]}

      {:error, reason} ->
        Logger.debug("Generating single key error: #{inspect(reason)}")
        {:error, reason}

      error ->
        Logger.error("Unknown error in single key pair generation! #{inspect(error)}")
        {:error, :unknown}
    end
  end

  def generate_key_pair(pub_count, ntru_params) do
    case Base.gen_key_pair_multi(pub_count, ntru_params, :default) do
      {:ok, pub_keys, priv_key} ->
        {:ok, get_key_pairs(priv_key, ntru_params, pub_keys)}

      {:error, reason} ->
        Logger.debug("Generating single key error: #{inspect(reason)}")
        {:error, reason}

      error ->
        Logger.error("Unknown error in single key pair generation! #{inspect(error)}")
        {:error, :unknown}
    end
  end

  @doc """
  Generates an NTRU key pair with given ntru_params and private key

  Note that in NTRU a single private key can have multiple public keys.
  But you'll need the public key whick encrypted the data in order to decrypt it.

  For more information on ntru_params please visit
  [libntru - Parameter Sets](https://github.com/tbuktu/libntru#parameter-sets)

  ## Parameters
    - priv_key: Binary of the private key
    - pub_count: Number of public keys to generate
    - ntru_params: An atom representing the params of generated NTRU keypair.

  Returns a tuple like {:ok, %KeyPair{...}} on success
  """
  @spec generate_key_pair(binary(), Integer.t(), Base.ntru_params_t()) ::
          {:ok, List.t()}
          | {:error, atom()}
  def generate_key_pair(priv_key, pub_count, ntru_params) when is_binary(priv_key) do
    do_generate_key_pair(priv_key, ntru_params, [], pub_count)
  end

  defp do_generate_key_pair(_, _, acc, 0) when is_list(acc), do: {:ok, acc}

  defp do_generate_key_pair(priv_key, ntru_params, acc, pub_cnt) do
    case Base.gen_pub_key(priv_key, ntru_params) do
      {:ok, pub_key} ->
        do_generate_key_pair(
          priv_key,
          ntru_params,
          [KeyPair.new!(pub_key, ntru_params, priv_key) | acc],
          pub_cnt - 1
        )

      {:error, reason} ->
        Logger.debug("Generating extra pub key error: #{inspect(reason)}")
        {:error, reason}

      error ->
        Logger.error("Unknown error in gen pub key #{inspect(error)}")
        {:error, :unknown}
    end
  end

  defp do_generate_key_pair(_, _, _, _), do: {:error, :bad_args}

  @doc """
  Encrypts a given binary with a keypair

  ## Parameters
    - kp: The KeyPair which holds the public key and ntru_params
    - data_bin: the binary to encrypt
    - ntru_params(optional): ntru params. if not provided the params in kp will
    be used

  Returns a tuple like `{:ok, encrypted_bin}` on success.
  """
  @spec encrypt(KeyPair.t(), binary()) ::
          {:ok, binary()}
          | {:error, atom()}
  def encrypt(kp, data_bin, ntru_params) do
    case Base.encrypt(kp.pub_key, data_bin, ntru_params) do
      {:ok, enc_data} ->
        {:ok, enc_data}

      {:error, reason} ->
        Logger.debug("Encrypt failed: #{inspect(reason)}")
        {:error, reason}

      error ->
        Logger.error("Encrypt failed unknown error: #{inspect(error)}")
        {:error, :unknown}
    end
  end

  @doc "Bang version of `encrypt`"
  @spec encrypt!(KeyPair.t(), binary(), Base.ntru_params_t()) :: binary
  def encrypt!(kp, data_bin, ntru_params) do
    {:ok, enc_data} = encrypt(kp, data_bin, ntru_params)
    enc_data
  end

  @doc false
  @spec encrypt(KeyPair.t(), binary()) ::
          {:ok, binary()}
          | {:error, atom()}
  def encrypt(kp, data_bin), do: encrypt(kp, data_bin, kp.ntru_params)

  @doc false
  @spec encrypt!(KeyPair.t(), binary()) :: binary()
  def encrypt!(kp, data_bin) do
    {:ok, enc_data} = encrypt(kp, data_bin)
    enc_data
  end

  @doc """
  Decrypts a given binary with a keypair

  Note that the KeyPair should contain the `priv_key` in order to decrypt!

  ## Parameters
    - kp: The KeyPair which holds the public key, private_key and ntru_params
    - enc_data: the binary to decry[t]
    - ntru_params(optional): ntru params. if not provided the params in kp will
    be used

  Returns a tuple like `{:ok, encrypted_bin}` on success.
  """
  @spec decrypt(KeyPair.t(), binary(), Base.ntru_params_t()) ::
          {:ok, binary()}
          | {:error, atom()}
  def decrypt(kp, enc_data, ntru_params) do
    case kp do
      %{priv_key: nil} ->
        {:error, :no_private_key_in_pair}

      _ ->
        do_decrypt(kp, enc_data, ntru_params)
    end
  end

  @doc "Bang version of `decrypt`"
  @spec decrypt!(KeyPair.t(), binary(), Base.ntru_params_t()) :: binary()
  def decrypt!(kp, enc_data, ntru_params) do
    {:ok, dec_data} = decrypt(kp, enc_data, ntru_params)
    dec_data
  end

  @doc false
  @spec decrypt(KeyPair.t(), binary()) ::
          {:ok, binary()}
          | {:error, atom()}
  def decrypt(kp, enc_data) do
    decrypt(kp, enc_data, kp.ntru_params)
  end

  @doc false
  @spec decrypt!(KeyPair.t(), binary()) :: binary()
  def decrypt!(kp, enc_data) do
    decrypt!(kp, enc_data, kp.ntru_params)
  end

  defp do_decrypt(kp, enc_data, ntru_params) do
    case Base.decrypt(kp.pub_key, kp.priv_key, enc_data, ntru_params) do
      {:ok, dec_data} ->
        {:ok, dec_data}

      {:error, reason} ->
        Logger.debug("Decrypt failed: #{inspect(reason)}")
        {:error, reason}

      error ->
        Logger.error("Decrypt failed unknown error: #{inspect(error)}")
        {:error, :unknown}
    end
  end

  #
  # Helpers
  #

  defp get_key_pairs(priv_key, ntru_params, pub_keys, acc \\ [])

  defp get_key_pairs(priv_key, ntru_params, [pub_key | tail], acc),
    do:
      get_key_pairs(priv_key, ntru_params, tail, [
        KeyPair.new!(pub_key, ntru_params, priv_key) | acc
      ])

  defp get_key_pairs(_, _, [], acc), do: acc
end

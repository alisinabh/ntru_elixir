defmodule NtruElixir.KeyPair do
  @moduledoc """
  KeyPair struct
  """

  alias NtruElixir.Base

  defstruct [:pub_key, :priv_key, :ntru_params]

  @type t ::
    %__MODULE__{pub_key: binary(), priv_key: binary(), ntru_params: Base.ntru_params_t}

  @doc """
  Creates a new KeyPair struct with given public_key and private_key

  ## Parameters
    - pub_key: binary of public key
    - priv_key: binary of private key

  Returns a tuple like `{:ok, %KeyPair{...}}` on success.
  """
  @spec new(binary(), Base.ntru_params_t, binary()) ::
          {:ok, __MODULE__.t}
          | {:error, :pub_key_type_error}
          | {:error, :bad_keys}
  def new(pub_key, ntru_params, priv_key \\ nil)
  def new(pub_key, ntru_params, priv_key) when is_binary(pub_key), do:
    {:ok,
      %__MODULE__{
        pub_key: pub_key,
        priv_key: priv_key,
        ntru_params: ntru_params
      }
    }

  def new(_pub_key, _ntru_params, priv_key) when is_binary(priv_key), do:
    {:error, :pub_key_type_error}

  def new(_, _, _), do:
    {:error, :bad_keys}

  def new!(pub_keys, ntru_params, priv_key) do
    {:ok, key_pair} = new(pub_keys, ntru_params, priv_key)
    key_pair
  end
end

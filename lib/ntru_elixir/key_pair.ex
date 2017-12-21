defmodule NtruElixir.KeyPair do
  @moduledoc """
  KeyPair struct
  """

  alias NtruElixir.Base

  @enforce_keys [:pub_key]

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
  def new(pub_key, ntru_params, priv_key)
        when is_binary(pub_key)
          and is_atom(ntru_params)
  do
    cond do
      is_nil(priv_key) or is_binary(priv_key) ->
        {:ok,
          %__MODULE__{
            pub_key: pub_key,
            priv_key: priv_key,
            ntru_params: ntru_params
          }
        }
      true ->
        {:error, :bad_private_key}
    end
  end

  def new(pub_key, _ntru_params, _priv_key) when not is_binary(pub_key), do:
    {:error, :bad_public_key}

  def new(_, ntru_prams, _) when not is_atom(ntru_prams), do:
    {:error, :bad_ntru_params}

  def new(_, _, priv_key) when not is_binary(priv_key), do:
    {:error, :bad_private_key}

  def new!(pub_keys, ntru_params, priv_key) do
    {:ok, key_pair} = new(pub_keys, ntru_params, priv_key)
    key_pair
  end
end

defmodule NtruElixir.KeyPair do
  @moduledoc """
  KeyPair struct
  """

  alias NtruElixir.Base

  defstruct [pub_keys: [], :priv_key]

  @type t ::
    %__MODULE__{pub_keys: List.t, priv_key: binary()}

  @doc """
  Creates a new KeyPair struct with given public_keys and private_key

  ## Parameters
    - pub_keys: either one public key as binary or a list of binaries
    - priv_key: a binary of private key assigned with current public key

  Returns a tuple like `{:ok, %KeyPair{...}}` on success.
  """
  @spec new(List.t | binary(), binary()) ::
          {:ok, __MODULE__.t}
          | {:error, :pub_key_type_error}
          | {:error, :bad_keys}
  def new(pub_keys, priv_key \\ nil)
  def new(pub_keys, priv_key) when is_list(pub_keys), do:
    {:ok, %__MODULE__{pub_keys: pub_keys, priv_key: priv_key}}

  def new(pub_key, priv_key) when is_binary(pub_key), do:
    {:ok, %__MODULE__{pub_keys: [pub_key], priv_key: priv_key}}

  def new(_pub_key, priv_key) when is_binary(priv_key), do:
    {:error, :pub_key_type_error}

  def new(_, _), do: {:error, :bad_keys}
end

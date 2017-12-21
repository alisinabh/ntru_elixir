defmodule NtruElixirTest do
  use ExUnit.Case
  doctest NtruElixir

  alias NtruElixir.KeyPair

  setup_all do
    {:ok, [kp1, kp2]} = NtruElixir.generate_key_pair(2)
    {:ok, keys: %{key1: kp1, key2: kp2}}
  end

  test "greets the world" do
    assert 1 == 1
  end

  test "Single KeyPair generation" do
    assert {:ok, [%KeyPair{}]} = NtruElixir.generate_key_pair
  end

  test "Multi pub KeyPair generation" do
    pub_count = Enum.random(2..10)
    assert {:ok, keys} = NtruElixir.generate_key_pair(pub_count)
    assert Enum.count(keys) == pub_count
  end

  test "Encryption and decryption", state do
    bin = "test binary"
    assert {:ok, enc_data} = NtruElixir.encrypt(state.keys.key1, bin)
    assert is_binary(enc_data)

    refute bin == enc_data

    assert {:ok, dec_data} = NtruElixir.decrypt(state.keys.key1, enc_data)

    assert dec_data == bin
  end

  test "Decryption only with key pair", state do
    bin = "test binary"
    assert {:ok, enc_data} = NtruElixir.encrypt(state.keys.key1, bin)
    assert is_binary(enc_data)

    assert bin != enc_data

    assert {:error, :dec_fail} = NtruElixir.decrypt(state.keys.key2, enc_data)
  end

end

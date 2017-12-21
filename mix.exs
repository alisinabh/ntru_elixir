defmodule NtruElixir.Mixfile do
  use Mix.Project

  @version "0.1.0"

  @description """
  libntru wrapper for elixir. NTRU is a post quantom cryptography algorithm.
  """

  def project do
    [
      app: :ntru_elixir,
      version: @version,
      elixir: "~> 1.3",
      description: @description,
      start_permanent: Mix.env == :prod,
      compilers: [:elixir_make] ++ Mix.compilers(),
      deps: deps(),
      preferred_cli_env:
        ["coveralls": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test],
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_make, "~> 0.4", runtime: false},
      {:ex_doc, "~> 0.18.1", runtime: false},
      {:excoveralls, ">= 0.0.0 ", only: :test},
    ]
  end
end

defmodule NtruElixir.Mixfile do
  use Mix.Project

  @version "0.0.0"

  @description """
  libntru wrapper for elixir. NTRU is a post quantom cryptography algorithm.
  """

  def project do
    [
      app: :ntru_elixir,
      version: @version,
      elixir: "~> 1.3",
      description: @description,
      start_permanent: Mix.env() == :prod,
      compilers: [:elixir_make] ++ Mix.compilers(),
      deps: deps(),
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
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
      {:excoveralls, ">= 0.0.0 ", only: :test}
    ]
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "ntru_elixir",
      # These are the default files included in the package
      files: ["lib", "c_src", "mix.exs", "README*", "LICENSE*", "libntru", "Makefile"],
      maintainers: ["alisinabh"],
      licenses: ["GNU GPLv3"],
      links: %{"GitHub" => "https://github.com/alisinabh/ntru_elixir"}
    ]
  end
end

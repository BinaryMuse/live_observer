# Used by "mix format"
# [
#   inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{*ex,exs}"]
# ]

[
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}", "priv/*/seeds.exs"]
]

%{
  configs: [
    %{
      name: "default",
      strict: true,
      checks: [
        {Credo.Check.Readability.ParenthesesOnZeroArityDefs, parens: true}
      ]
    }
  ]
}

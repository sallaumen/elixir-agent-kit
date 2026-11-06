defmodule ElixirAgentKit.CatalogTest do
  use ExUnit.Case, async: true

  test "catalog has unique standard skill identifiers and complete workflows" do
    skills = ElixirAgentKit.catalog()
    assert length(skills) == 33
    assert length(Enum.uniq_by(skills, & &1.id)) == 33

    for skill <- skills do
      assert Regex.match?(~r/^[a-z0-9]+(-[a-z0-9]+)*$/, skill.id)
      assert String.length("eak-" <> skill.id) <= 64
      assert skill.mode in ["analyze", "review", "analyze-and-fix", "coordinate"]
      assert skill.area in ["frontend", "backend", "cross-cutting", "delivery"]
      assert String.length(skill.description) < 1024

      contents =
        File.read!(Path.join(ElixirAgentKit.library_path(), "skills/#{skill.id}/SKILL.md"))

      for required <- [
            "name: #{skill.id}\n",
            "## When to use",
            "## Inputs to inspect",
            "## Workflow",
            "## Decision points",
            "## Quality criteria",
            "## Validation and evidence",
            "## Avoid",
            "## Completion",
            "../../CONTRACT.md"
          ] do
        assert contents =~ required
      end
    end
  end

  test "the distributed snapshot carries its license notice" do
    license = File.read!(Path.join(ElixirAgentKit.library_path(), "LICENSE"))
    assert license =~ "MIT License"
    assert license =~ "Copyright (c) 2026 Lucas Tavano"
  end

  test "review and acceptance workflows preserve read-only defaults" do
    catalog = Map.new(ElixirAgentKit.catalog(), &{&1.id, &1.mode})
    assert catalog["code-review"] == "review"
    assert catalog["delivery-validation"] == "analyze"
  end
end

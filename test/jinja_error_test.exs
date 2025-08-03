defmodule Jinja.ErrorTest do
  use ExUnit.Case

  setup do
    start_supervised!(Jinja)
    :ok
  end

  describe "error handling" do
    test "invalid template syntax returns error" do
      assert {:error, _} = Jinja.render_string("{{ unclosed", %{})
    end

    test "invalid filter returns error" do
      assert {:error, _} = Jinja.render_string("{{ name | nonexistent_filter }}", %{name: "test"})
    end

    test "template not found error" do
      assert {:error, _} = Jinja.render_template("nonexistent_template", %{})
    end

    test "template inheritance with missing parent" do
      :ok = Jinja.load_template("orphan", "{% extends 'missing_parent' %}")
      assert {:error, _} = Jinja.render_template("orphan", %{})
    end

    test "circular template inheritance" do
      :ok = Jinja.load_template("a", "{% extends 'b' %}")
      :ok = Jinja.load_template("b", "{% extends 'a' %}")
      assert {:error, _} = Jinja.render_template("a", %{})
    end
  end

  describe "edge cases" do
    test "empty template string" do
      assert {:ok, ""} = Jinja.render_string("", %{})
    end

    test "template with only whitespace" do
      assert {:ok, result} = Jinja.render_string("   \n\t  ", %{})
      assert String.trim(result) == ""
    end

    test "very large template" do
      large_template = String.duplicate("{{ name }} ", 1000)
      assigns = %{name: "test"}
      
      assert {:ok, result} = Jinja.render_string(large_template, assigns)
      assert String.contains?(result, "test")
    end

    test "deeply nested data structures" do
      deep_assigns = %{
        level1: %{
          level2: %{
            level3: %{
              value: "deep_value"
            }
          }
        }
      }
      
      assert {:ok, "deep_value"} = 
        Jinja.render_string("{{ level1.level2.level3.value }}", deep_assigns)
    end

    test "unicode and special characters" do
      template = "Hello {{ name }}! 🌍"
      assigns = %{name: "世界"}
      
      assert {:ok, result} = Jinja.render_string(template, assigns)
      assert String.contains?(result, "世界")
      assert String.contains?(result, "🌍")
    end

    test "binary data in assigns" do
      assigns = %{data: <<1, 2, 3, 4>>}
      assert {:ok, _} = Jinja.render_string("{{ data }}", assigns)
    end

    test "nil values in assigns" do
      assigns = %{value: nil}
      assert {:ok, result} = Jinja.render_string("{{ value }}", assigns)
      assert String.trim(result) == ""
    end

    test "boolean values in assigns" do
      assigns = %{flag: true, other: false}
      assert {:ok, result} = Jinja.render_string("{{ flag }} {{ other }}", assigns)
      assert String.contains?(result, "True")
      assert String.contains?(result, "False")
    end

    test "numeric values in assigns" do
      assigns = %{int: 42, float: 3.14}
      assert {:ok, result} = Jinja.render_string("{{ int }} {{ float }}", assigns)
      assert String.contains?(result, "42")
      assert String.contains?(result, "3.14")
    end
  end

  describe "input validation" do
    test "render_string with non-string template fails" do
      assert_raise FunctionClauseError, fn ->
        Jinja.render_string(123, %{})
      end
    end

    test "render_string with non-map assigns fails" do
      assert_raise FunctionClauseError, fn ->
        Jinja.render_string("test", "not_a_map")
      end
    end

    test "load_template with non-string name fails" do
      assert_raise FunctionClauseError, fn ->
        Jinja.load_template(123, "template")
      end
    end

    test "load_template with non-string source fails" do
      assert_raise FunctionClauseError, fn ->
        Jinja.load_template("name", 123)
      end
    end

    test "render_template with non-string name fails" do
      assert_raise FunctionClauseError, fn ->
        Jinja.render_template(123, %{})
      end
    end

    test "render_template with non-map assigns fails" do
      assert_raise FunctionClauseError, fn ->
        Jinja.render_template("name", "not_a_map")
      end
    end
  end
end
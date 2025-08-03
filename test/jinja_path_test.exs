defmodule Jinja.PathTest do
  use ExUnit.Case

  @temp_dir System.tmp_dir!() |> Path.join("jinja_path_test")

  setup_all do
    File.mkdir_p!(@temp_dir)
    
    File.write!(Path.join(@temp_dir, "simple.html"), "Hello {{ name }}!")
    File.write!(Path.join(@temp_dir, "base.html"), """
    <html>
    <head><title>{{ title }}</title></head>
    <body>{% block content %}{% endblock %}</body>
    </html>
    """)
    File.write!(Path.join(@temp_dir, "child.html"), """
    {% extends "base.html" %}
    {% block content %}<h1>{{ heading }}</h1>{% endblock %}
    """)
    File.write!(Path.join(@temp_dir, "loop.html"), """
    <ul>
    {% for item in items %}
    <li>{{ item }}</li>
    {% endfor %}
    </ul>
    """)

    on_exit(fn -> File.rm_rf!(@temp_dir) end)
    :ok
  end

  setup do
    start_supervised!({Jinja, loader: :path, from: @temp_dir})
    :ok
  end

  test "renders simple template from filesystem" do
    assert {:ok, "Hello world!"} = Jinja.render_template("simple.html", %{name: "world"})
  end

  test "template inheritance from filesystem" do
    {:ok, result} = Jinja.render_template("child.html", %{
      title: "Test Page",
      heading: "Welcome"
    })
    
    assert String.contains?(result, "<title>Test Page</title>")
    assert String.contains?(result, "<h1>Welcome</h1>")
  end

  test "template with loops from filesystem" do
    {:ok, result} = Jinja.render_template("loop.html", %{
      items: ["apple", "banana", "cherry"]
    })
    
    assert String.contains?(result, "<li>apple</li>")
    assert String.contains?(result, "<li>banana</li>")
    assert String.contains?(result, "<li>cherry</li>")
  end

  test "load_template/2 is disabled for path loader" do
    assert {:error, "loading templates at runtime is only supported for loader: :dict"} =
      Jinja.load_template("test", "content")
  end

  test "missing template file returns error" do
    assert {:error, _} = Jinja.render_template("nonexistent.html", %{})
  end

  test "render_string still works with path loader" do
    assert {:ok, "Hello filesystem!"} = 
      Jinja.render_string("Hello {{ mode }}!", %{mode: "filesystem"})
  end
end
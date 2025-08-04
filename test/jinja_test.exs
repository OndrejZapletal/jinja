defmodule JinjaTest do
  use ExUnit.Case

  setup do
    start_supervised!(Jinja)
    :ok
  end

  describe "dict loader" do
    test "render_string/2 renders simple template" do
      assert {:ok, "Hello world"} = Jinja.render_string("Hello {{ name }}", %{name: "world"})
    end

    test "render_string/2 with empty assigns" do
      assert {:ok, "Hello "} = Jinja.render_string("Hello {{ name }}", %{})
    end

    test "render_string/2 with default assigns" do
      assert {:ok, "Hello "} = Jinja.render_string("Hello {{ name }}", %{})
    end

    test "render_string/2 with complex template" do
      template = """
      <h1>{{ title }}</h1>
      {% for item in items %}
      <p>{{ item }}</p>
      {% endfor %}
      """

      assigns = %{title: "List", items: ["one", "two", "three"]}

      {:ok, result} = Jinja.render_string(template, assigns)
      assert String.contains?(result, "<h1>List</h1>")
      assert String.contains?(result, "<p>one</p>")
      assert String.contains?(result, "<p>two</p>")
      assert String.contains?(result, "<p>three</p>")
    end

    test "load_template/2 loads template successfully" do
      assert :ok = Jinja.load_template("test", "Hello {{ name }}")
    end

    test "render_template/2 renders loaded template" do
      :ok = Jinja.load_template("greeting", "Hello {{ name }}!")
      assert {:ok, "Hello world!"} = Jinja.render_template("greeting", %{name: "world"})
    end

    test "template inheritance works" do
      :ok =
        Jinja.load_template("base", """
        <html>
        <head><title>{{ title }}</title></head>
        <body>
        {% block content %}{% endblock %}
        </body>
        </html>
        """)

      :ok =
        Jinja.load_template("page", """
        {% extends "base" %}
        {% block content %}
        <h1>{{ heading }}</h1>
        <p>{{ body }}</p>
        {% endblock %}
        """)

      {:ok, result} =
        Jinja.render_template("page", %{
          title: "Test Page",
          heading: "Welcome",
          body: "This is a test"
        })

      assert String.contains?(result, "<title>Test Page</title>")
      assert String.contains?(result, "<h1>Welcome</h1>")
      assert String.contains?(result, "<p>This is a test</p>")
    end

    test "template with conditional blocks" do
      :ok =
        Jinja.load_template("conditional", """
        {% if show_greeting %}
        <h1>Hello {{ name }}!</h1>
        {% else %}
        <h1>Goodbye {{ name }}!</h1>
        {% endif %}
        """)

      {:ok, hello} = Jinja.render_template("conditional", %{show_greeting: true, name: "world"})
      assert String.contains?(hello, "Hello world!")

      {:ok, goodbye} =
        Jinja.render_template("conditional", %{show_greeting: false, name: "world"})

      assert String.contains?(goodbye, "Goodbye world!")
    end

    test "autoescape is enabled for HTML content" do
      template = "<div>{{ content }}</div>"
      assigns = %{content: "<script>alert('xss')</script>"}

      {:ok, result} = Jinja.render_string(template, assigns)
      assert String.contains?(result, "&lt;script&gt;")
      refute String.contains?(result, "<script>")
    end
  end
end

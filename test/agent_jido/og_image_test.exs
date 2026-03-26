defmodule AgentJido.OGImageTest do
  use ExUnit.Case, async: false

  alias AgentJido.OGImage
  alias AgentJido.OGImage.Descriptor
  alias AgentJido.OGImage.Templates

  test "get_image_for_path returns png data and descriptor" do
    {:ok, png_data, descriptor} = OGImage.get_image_for_path("/features")

    assert is_binary(png_data)
    assert byte_size(png_data) > 1000
    assert binary_part(png_data, 0, 8) == <<137, 80, 78, 71, 13, 10, 26, 10>>
    assert descriptor.template == :marketing
  end

  test "unknown path renders fallback not_found image instead of failing" do
    {:ok, png_data, descriptor} = OGImage.get_image_for_path("/not/a/real/path")

    assert is_binary(png_data)
    assert descriptor.template == :not_found
  end

  test "svg rendering escapes special characters in descriptor fields" do
    descriptor = %Descriptor{
      template: :marketing,
      title: ~S{<script>alert("xss")</script>},
      subtitle: "A & B > C",
      eyebrow: "TEST & VERIFY",
      footer_url: "jido.run/features",
      badges: ["alpha&beta", "<unsafe>"],
      content_hash: "abc123",
      cache_key: "v3:path=/features:hash=abc123",
      resolved_path: "/features"
    }

    svg = Templates.render_svg(descriptor)

    assert svg =~ "&lt;script&gt;"
    assert svg =~ "&amp;"
    assert svg =~ "&gt;"
    assert svg =~ "TEST &amp; VERIFY"
    refute svg =~ "<script>alert(\"xss\")</script>"
  end

  test "svg keeps the image minimal and avoids repeating subtitle or badges" do
    descriptor = %Descriptor{
      template: :marketing,
      title: "Build AI Agents That Run in Production",
      subtitle:
        "Jido is an open-source agent framework for Elixir. Build supervised AI agents with fault tolerance, tool calling, and multi-agent coordination built in.",
      eyebrow: "FEATURES",
      footer_url: "jido.run/features",
      badges: ["Elixir/OTP", "Multi-Agent", "Production"],
      content_hash: "abc123",
      cache_key: "v8:path=/features:hash=abc123",
      resolved_path: "/features"
    }

    svg = Templates.render_svg(descriptor)

    assert svg =~ "jido.run"
    assert svg =~ "FEATURES"
    assert svg =~ "Build AI Agents That"
    assert svg =~ "Run in Production"
    refute svg =~ "<linearGradient"
    refute svg =~ "<radialGradient"
    refute svg =~ "tool calling"
    refute svg =~ "Elixir/OTP"
    refute svg =~ "Multi-Agent"
    refute svg =~ "jido.run/features"

    [y, _title_block] =
      Regex.scan(~r/<text x="72" y="(\d+)"[^>]*>(.*?)<\/text>/s, svg, capture: :all_but_first)
      |> List.last()

    assert String.to_integer(y) > 420
  end

  test "svg wraps and truncates long copy with bounded multiline tspans" do
    long_token = String.duplicate("supercalifragilisticexpialidocious", 8)

    descriptor = %Descriptor{
      template: :marketing,
      title: long_token,
      subtitle:
        "This subtitle is intentionally long so it should wrap onto multiple lines and then truncate with an ellipsis when it exceeds the bounded Open Graph text region.",
      eyebrow: "FEATURES",
      footer_url: "jido.run/features",
      badges: ["alpha", "beta", "gamma", "delta"],
      content_hash: "abc123",
      cache_key: "v8:path=/features:hash=abc123",
      resolved_path: "/features"
    }

    svg = Templates.render_svg(descriptor)

    assert svg =~ "..."
    refute svg =~ long_token

    [y, title_block] =
      Regex.scan(~r/<text x="72" y="(\d+)"[^>]*>(.*?)<\/text>/s, svg, capture: :all_but_first)
      |> List.last()

    title_tspan_count = Regex.scan(~r/<tspan /, title_block) |> length()
    assert String.to_integer(y) > 350
    assert title_tspan_count == 3
  end
end

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
      eyebrow: "TEST",
      footer_url: "agentjido.xyz/features",
      badges: ["alpha&beta", "<unsafe>"],
      content_hash: "abc123",
      cache_key: "v3:path=/features:hash=abc123",
      resolved_path: "/features"
    }

    svg = Templates.render_svg(descriptor)

    assert svg =~ "&lt;script&gt;"
    assert svg =~ "&amp;"
    assert svg =~ "&gt;"
    refute svg =~ "<script>alert(\"xss\")</script>"
  end
end

# frozen_string_literal: true

module PagesHelper
  def color_luminance(hex_code, luminance)
    r, g, b = extract_color_values(hex_code)

    raise ArgumentError, 'invalid RGB hex code' unless r && b && g

    luminance ||= 0

    r = [[0, r + (r * luminance)].max, 255].min.round

    g = [[0, g + (g * luminance)].max, 255].min.round

    b = [[0, b + (b * luminance)].max, 255].min.round

    format('#%<r>02x%<g>02x%<b>02x', r: r, g: g, b: b)
  end

  def contrast_color(hex_code)
    r, g, b = extract_color_values(hex_code)

    raise ArgumentError, 'invalid RGB hex code' unless r && b && g

    a = 1.0 - (0.299 * r.to_f + 0.587 * g.to_f + 0.114 * b.to_f) / 255.0

    if a < 0.5
      '#000000'
    else
      '#ffffff'
    end
  end

  private

  def extract_color_values(hex_code)
    return nil if hex_code.match(/^#(([a-fA-F0-9]){3}){1,2}$/).nil?

    hex_code = hex_code[1..hex_code.length - 1]

    hex_code = hex_code[0] + hex_code[0] + hex_code[1] + hex_code[1] + hex_code[2] + hex_code[2] if hex_code.length < 6

    r = hex_code[0, 2].to_i(16)

    g = hex_code[2, 2].to_i(16)

    b = hex_code[4, 2].to_i(16)

    [r, g, b]
  end
end

module ApplicationHelper
  def image_url(source)
    root = root_url
    root[0, root.length - 1] + image_path(source)
  end

  def sortable(column, title = nil)
    title ||= column.titleize

    order = column == sort_column && sort_order == "asc" ? "desc" : "asc"

    link_to title, params.merge(:sort => column, :order => order, :page => nil)
  end

  def is_current_controller?(controller_name)
    "current" if params[:controller] == controller_name
  end

  def is_current_action?(action_name)
    "current" if params[:action] == action_name
  end

  def color_luminance(hex_code, luminance)
    unless hex_code.match(/^#(([a-fA-F0-9]){3}){1,2}$/).nil?
      hex_code = hex_code[1..hex_code.length - 1]

      if hex_code.length < 6
        hex_code = hex_code[0] + hex_code[0] + hex_code[1] + hex_code[1] + hex_code[2] + hex_code[2]
      end

      luminance ||= 0

      r = hex_code[0, 2].to_i(16)
      g = hex_code[2, 2].to_i(16)
      b = hex_code[4, 2].to_i(16)

      r = [[0, r + (r * luminance)].max, 255].min.round
      g = [[0, g + (g * luminance)].max, 255].min.round
      b = [[0, b + (b * luminance)].max, 255].min.round

      "#" + "%02x" % r + "%02x" % g + "%02x" % b
    else
      nil
    end
  end
end

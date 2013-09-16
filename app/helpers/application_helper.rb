module ApplicationHelper
  def icon_edit_link url_or_path
    render :partial => 'shared/icon_edit_link', :locals => { :url_or_path => build_url_or_path_for(url_or_path) }
  end

  def icon_delete_link url_or_path
    render :partial => 'shared/icon_delete_link', :locals => { :url_or_path => build_url_or_path_for(url_or_path) }
  end

  def build_url_or_path_for url_or_path = ''
    url_or_path = eval(url_or_path) if url_or_path =~ /_path|_url|@/
    url_or_path
  end

  def flash_messages
    render :partial => 'shared/flash_messages'
  end

  def is_active_controller? controller_name
    'active' if params[:controller] == controller_name
  end

  def is_active_action? action_name
    'active' if params[:action] == action_name
  end

  def date_range form
    render :partial => 'shared/date_range', :locals => { :f => form }
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

      '#%02x%02x%02x' % [r, g, b]
    else
      nil
    end
  end
end

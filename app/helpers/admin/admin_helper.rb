module Admin::AdminHelper
  def picture_inserter(target)
    render :partial => 'shared/admin/picture_inserter', :locals => { :target => target }
  end
end

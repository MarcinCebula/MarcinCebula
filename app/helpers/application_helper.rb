module ApplicationHelper
  def navtion_for_controller    
    case controller.action_name
    when "chef_recipies"
      'layouts/application/navigation/chef_recipies'
    when "setup_hosted_chef"
      'layouts/application/navigation/setup_hosted_chef'
    else
      'layouts/application/navigation/blog'
    end
  end
end

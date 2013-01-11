ActiveAdmin::Dashboards.build do

   section "New Posts", :priority => 1 do
     table_for Deal.order("created_at desc").limit(9) do
       column("") {|deal| link_to(image_tag(deal.photo.url(:iphone_list)), [:admin, deal])}
       column("") {|deal|  link_to deal.name, admin_post_path(deal)}
       column("") {|deal| status_tag(deal.try(:category).try(:name)) }
       column("") {|deal| deal.created_at.to_s(:short) }
     end
   end
   
   section "Popular Posts", :priority => 2 do
     table_for Deal.popular.limit(9) do
       column("") {|deal| link_to(image_tag(deal.photo.url(:iphone_list)), [:admin, deal])}
       column("") {|deal|  link_to deal.name, admin_post_path(deal)}
       column("") {|deal| status_tag(deal.try(:category).try(:name)) }
       column("") {|deal| deal.created_at.to_s(:short) }
     end
   end
   
   section "Current Home Page Posts", :priority => 3 do
     table_for Deal.premium.recent.sorted.popular.first(9) do
       column("") {|deal| link_to(image_tag(deal.photo.url(:iphone_list)), [:admin, deal])}
       column("") {|deal|  link_to deal.name, admin_deal_path(deal)}
       column("") {|deal| status_tag(deal.try(:category).try(:name)) }
       column("") {|deal| deal.created_at.to_s(:short) }
     end
   end

   section "Performance", :priority => 4 do
      div do
        br
        text_node %{<iframe src="https://heroku.newrelic.com/public/charts/lD4xesY05Oe" width="500" height="300" scrolling="no" frameborder="no"></iframe>}.html_safe
      end
    end
  
  
  # Define your dashboard sections here. Each block will be
  # rendered on the dashboard in the context of the view. So just
  # return the content which you would like to display.
  
  # == Simple Dashboard Section
  # Here is an example of a simple dashboard section
  #
  # section "Recent Posts" do
  #   ul do
  #     Deal.order("created_at desc").limit(5).collect do |deal|
  #       li link_to(deal.name, admin_deal_path(deal)))
  #     end
  #   end
  # end
  
  # == Render Partial Section
  # The block is rendererd within the context of the view, so you can
  # easily render a partial rather than build content in ruby.
  #
  #   section "Recent Posts" do
  #     render 'recent_posts' # => this will render /app/views/admin/dashboard/_recent_posts.html.erb
  #   end
  
  # == Section Ordering
  # The dashboard sections are ordered by a given priority from top left to
  # bottom right. The default priority is 10. By giving a section numerically lower
  # priority it will be sorted higher. For example:
  #
  #   section "Recent Posts", :priority => 10
  #   section "Recent User", :priority => 1
  #
  # Will render the "Recent Users" then the "Recent Posts" sections on the dashboard.

end

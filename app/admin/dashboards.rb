ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do

     columns do
       column do
         
         #Recent
         panel "Recent Posts" do
           ul do
             table_for Deal.order("created_at desc").limit(9) do
               column("") {|deal| link_to(image_tag(deal.photo.url(:iphone_list)),[:admin, deal])}
               column("") {|deal|  link_to deal.name, admin_deal_path(deal)}
               column("") {|deal| status_tag(deal.try(:category).try(:name)) }
               column("") {|deal| deal.created_at.to_s(:short) }
             end
           end
         end
         
         #Popular
         panel "Popular Posts" do
           ul do
             table_for Deal.popular.limit(9) do
               column("") {|deal| link_to(image_tag(deal.photo.url(:iphone_list)),[:admin, deal])}
               column("") {|deal|  link_to deal.name, admin_deal_path(deal)}
               column("") {|deal| status_tag(deal.try(:category).try(:name)) }
               column("") {|deal| deal.created_at.to_s(:short) }
             end
           end
         end
         
       end

       column do
         #Current Home Page Posts
         panel "Current Home Page Posts" do
           ul do
             table_for Deal.premium.recent.sorted.popular.first(9) do
               column("") {|deal| link_to(image_tag(deal.photo.url(:iphone_list)), [:admin, deal])}
               column("") {|deal|  link_to deal.name, admin_deal_path(deal)}
               column("") {|deal| status_tag(deal.try(:category).try(:name)) }
               column("") {|deal| deal.created_at.to_s(:short) }
             end
           end
         end
         
         #Performance
         panel "Performance" do
           div do
             br
               text_node %{<iframe src="https://heroku.newrelic.com/public/charts/lD4xesY05Oe" width="500" height="300" scrolling="no" frameborder="no"></iframe>}.html_safe
           end
         end
       end
     end
     
  end # content
end

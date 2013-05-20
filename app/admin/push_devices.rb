ActiveAdmin.register PushDevice do

  index do
    column("ID"){|device| device.id.try(:to_s)}
    column("User ID"){|device| device.user.id.try(:to_s)}
    column :token 
    default_actions
  end
  

end
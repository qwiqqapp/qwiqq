if Rails.env.production?
  PAPERCLIP_STORAGE_OPTIONS = {  :storage   => :s3, 
                                 :bucket    => ENV['S3_BUCKET'],
                                 :path      => ':class/:id/:style.:extension',
                                 :s3_credentials => { :access_key_id     => ENV['S3_KEY'], 
                                                      :secret_access_key => ENV['S3_SECRET'] } 
                              }
else
  PAPERCLIP_STORAGE_OPTIONS = {:url => "http://localhost:3000/system/:attachment/:id/:style/:filename"}
end

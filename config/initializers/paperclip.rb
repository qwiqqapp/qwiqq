PAPERCLIP_STORAGE_OPTIONS = {  :storage   => :s3, 
                               :bucket    => ENV['S3_BUCKET'],
                               :path      => ':class/:id/:style.:extension',
                               :default_url =>   '/images/missing/:class/:style.png',
                               :s3_credentials => { :access_key_id     => ENV['S3_KEY'], 
                                                    :secret_access_key => ENV['S3_SECRET'] } 
                            }



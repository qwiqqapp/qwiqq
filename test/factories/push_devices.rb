# device registration stubbed 

Factory.define :push_device do |f|
  f.token "b0a91911 db6fad5f 4e924598 74107351 6f0c032f 3c017918 1c9cd79e #{SecureRandom.hex(4)}"
end

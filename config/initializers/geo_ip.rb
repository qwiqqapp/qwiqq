begin
  GEO_IP = GeoIP.new(File.join(Rails.root, "db", "geo.dat"))
rescue
  GEO_IP = nil
end

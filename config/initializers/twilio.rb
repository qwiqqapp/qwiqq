module Qwiqq
  def self.twilio_sid
    ENV["TWILIO_SID"]
  end

  def self.twilio_auth_token
    ENV["TWILIO_AUTH_TOKEN"]
  end

  def self.twilio_from_number
    ENV["TWILIO_FROM_NUMBER"]
  end
end

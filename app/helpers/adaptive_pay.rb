# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'adaptive_pay/interface'

module AdaptivePay
  class Callback
    def initialize(params, raw_post)
      @params = params
      @raw = raw_post
    end

    def valid?
      puts "BEGIN VALIDATION SANDBOX:#{@params[:sandbox]}"
      uri = URI.parse('https://www.paypal.com/cgi-bin/webscr?cmd=_notify-validate')
      if @params[:sandbox] == true
        puts "SANDBOX URI"
        uri = URI.parse('https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_notify-validate')
      end

      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = 60
      http.read_timeout = 60
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = true
      response = http.post(uri.request_uri, @raw,
                          'Content-Length' => "#{@raw.size}",
                          'User-Agent' => "My custom user agent"
                        ).body
                        
      raise StandardError.new("Faulty paypal result: #{response}") unless ["VERIFIED", "INVALID"].include?(response)
      raise StandardError.new("Invalid IPN: #{response}") unless response == "VERIFIED"
      puts "IPN VALID"
      true
    end

    def completed?
      puts "PAYMENT_STATUS:#{@params[:payment_status]}"
      @params[:payment_status] == "Completed"
    end
  end
end

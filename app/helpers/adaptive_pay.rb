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
      puts "THE IPN DETERMINE IF SANDBOX:#{@params[:test_ipn]}"
      
      string = "sandbox." if @params[:sandbox] == true
      puts "TEST STRING'#{string}'"
      url = "https://www.#{string}paypal.com/cgi-bin/webscr?cmd=_notify-validate"
      puts "TEST URL'#{url}'"
      uri = URI.parse(url)

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

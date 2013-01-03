# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'adaptive_pay/interface'

module AdaptivePay
  class Callback
    def initialize(params, raw_post)
      puts "MARK deal_id: #{params[:deal_id]} buyerid: #{params[:buyer_id]} paypal_transaction_id: #{params[:txn_id]}  payment_status: #{params[:payment_status]}"
      @params = params
      @raw = raw_post
    end

    def valid?
      puts "START VALID"
      uri = URI.parse('https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_notify-validate')

      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = 60
      http.read_timeout = 60
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = true
      response = http.post(uri.request_uri, @raw,
                          'Content-Length' => "#{@raw.size}",
                          'User-Agent' => "My custom user agent"
                        ).body
                        
      puts "VALID FIRST ASSERT"
      raise StandardError.new("Faulty paypal result: #{response}") unless ["VERIFIED", "INVALID"].include?(response)
      puts "VALID SECOND ASSERT"
      raise StandardError.new("Invalid IPN: #{response}") unless response == "VERIFIED"
      puts "VALID END"
      true
    end

    def completed?
      puts "PAYMENT_STATUS:#{@params[:payment_status]}"
      @params[:payment_status] == "Completed"
    end
  end
end

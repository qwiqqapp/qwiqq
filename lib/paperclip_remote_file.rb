require "open-uri"

# somewhat evil, but works
module Paperclip
  class RemoteFile < Tempfile
    attr :content_type

    def initialize(url)
      @url = URI.parse(url)
      super("url_tempfile")

      Kernel.open(url) do |file|
        @content_type = file.content_type
        binmode
        write(file.read)
        flush
      end
    end

    def original_filename
      # Take the URI path and strip off everything after last slash, assume this
      # to be filename (URI path already removes any query string)
      match = @url.path.match(/^.*\/(.+)$/)
      match ? match[1] : nil
    end
  end
end

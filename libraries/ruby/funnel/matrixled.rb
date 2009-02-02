require 'funnel'

module Funnel
  class MatrixLED < IOSystem
    def initialize(arguments = {})
      config = Configuration.new(Configuration::GAINER, Gainer::MODE7)

      host = arguments[:host] || '127.0.0.1'
      port = arguments[:port] || 9000
      interval = arguments[:interval] || 33
      applet = arguments[:applet]

      super(config, host, port, interval, applet)
    end

    def scan_matrix(image)
      send_output_command(0, 0, image.map do |pixel| pixel.to_f end)
    end
  end
end

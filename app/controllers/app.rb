require 'base'
require 'slim'

class App < Base
  get '/' do
    send_file File.join(settings.public_folder, 'index.html')
  end
end

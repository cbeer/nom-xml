require 'nokogiri'

module Nom
  require 'nom/version'
  require 'nom/terminology'
  require 'nom/decorators'

  require 'nom/nokogiri_extension'

  Nokogiri::XML::Document.send(:include, NokogiriExtension)

end

module LinkedData
  module Models
    class ExternalMapping
      include LinkedData::Hypermedia::Resource
      embed :classes, :process
      serialize_default :id, :source, :classes, :process

      #attribute :classes, enforce: [:existence, :list]
      #attribute :process, enforce: [:existence, :mapping_process]
      #attribute :source, enforce: [:existence]
      #attribute :id, enforce: [:existence]

      def initialize(classes, source, process, id)
        @classes = classes
        @process = process
        @source = source
        @id = id
      end
      def classes
        return @classes
      end
      def process
        return @process
      end
      def source
        return @source
      end
      def id
        return @id
      end
      def self.type_uri
        LinkedData.settings.id_url_prefix+"metadata/Mapping"
      end

    end
  end
end


module LinkedData
  module Models
    class ExternalClass < LinkedData::Models::Base
      attribute :id, enforce: [:existence]
      attribute :source, enforce: [:existence]
      attribute :ontology

      serialize_default :id, :source

      def initialize(id, source)
        @id = id
        @source = source
      end
      def id
        return @id
      end
      def source
        return @source
      end
      def ontology
        return @ontology
      end
    end
  end
end
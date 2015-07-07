
module LinkedData
  module Models
    class ExternalClass

      attr_reader :id, :source, :ontology

      #attribute :id, enforce: [:existence]
      #attribute :source, enforce: [:existence]
      #attribute :ontology

      serialize_default :id, :source

      def initialize(id, source)
        @id = id
        @source = source
      end
    end
  end
end
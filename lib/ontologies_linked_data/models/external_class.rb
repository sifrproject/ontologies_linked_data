
module LinkedData
  module Models
    class ExternalClass
      include LinkedData::Hypermedia::Resource

      attr_reader :id, :ontology, :type

      serialize_default :type

      link_to LinkedData::Hypermedia::Link.new("self", "http://data.bioontology.org/ontologies/MESH/classes/#{CGI.escape(@id.to_s)}", RDF::URI.new("http://www.w3.org/2002/07/owl#Class")),
              LinkedData::Hypermedia::Link.new("ontology", "http://data.bioontology.org/ontologies/MESH", Goo.vocabulary["Ontology"])

      def initialize(id, type)
        @id = id
        @type = RDF::URI.new(type)

      end
    end
  end
end
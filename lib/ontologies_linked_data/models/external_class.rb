
module LinkedData
  module Models
    class ExternalClass
      include LinkedData::Hypermedia::Resource

      attr_reader :id, :ontology, :type_uri

      serialize_default :ontology

      link_to LinkedData::Hypermedia::Link.new("self", lambda {|ec| "http://data.bioontology.org/ontologies/#{ec.ontology.to_s}/classes/#{CGI.escape(ec.id.to_s)}"}, RDF::URI.new("http://www.w3.org/2002/07/owl#Class")),
              LinkedData::Hypermedia::Link.new("ontology", lambda {|ec| "http://data.bioontology.org/ontologies/#{ec.ontology.to_s}"}, Goo.vocabulary["Ontology"])

      def initialize(id, ontology)
        @id = id
        if ontology.start_with?("http")
          @ontology = RDF::URI.new(CGI.unescape(ontology))
        else
          @ontology = ontology
        end
        @type_uri = RDF::URI.new("http://www.w3.org/2002/07/owl#Class")
      end
    end
  end
end

module LinkedData
  module Models
    class ExternalClass
      include LinkedData::Hypermedia::Resource

      attr_reader :id, :ontology, :type_uri, :source

      serialize_never :id, :ontology, :type_uri, :source

      link_to LinkedData::Hypermedia::Link.new("self", lambda {|ec| ec.id.to_s}, "http://www.w3.org/2002/07/owl#Class"),
              LinkedData::Hypermedia::Link.new("ontology", lambda {|ec| ec.ontology.to_s}, Goo.vocabulary["Ontology"])

      def initialize(id, ontology, source)
        @id = id
        @ontology = RDF::URI.new(CGI.unescape(ontology))
        @type_uri = RDF::URI.new("http://www.w3.org/2002/07/owl#Class")
        @source = source
      end
    end
  end
end
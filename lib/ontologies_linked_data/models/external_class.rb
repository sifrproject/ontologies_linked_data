
module LinkedData
  module Models
    class ExternalClass
      include LinkedData::Hypermedia::Resource

      attr_reader :id, :ontology, :type_uri, :source

      serialize_default

      link_to LinkedData::Hypermedia::Link.new("self", lambda {|ec| "#{ec.ontology.to_s}/classes/#{CGI.escape(ec.id.to_s)}"}, RDF::URI.new("http://www.w3.org/2002/07/owl#Class"))

      link_to LinkedData::Hypermedia::Link.new("ontology", lambda {|ec| ec.ontology.to_s}, Goo.vocabulary["Ontology"])

      def initialize(id, ontology, source)
        @id = id
        @ontology = generate_ontology_uri(ontology, source)
        @type_uri = RDF::URI.new("http://www.w3.org/2002/07/owl#Class")
        @source = source
      end

      def generate_ontology_uri(ontology, source)
        if source == "ext" && ontology.start_with?("http")
          @ontology = RDF::URI.new(CGI.unescape(ontology))
        else
          #TODO: ajout d'un hash contenant le namespace de la source et l'URI pour générer cet URI en fonction du bioportal
          @ontology = "http://data.bioontology.org/ontologies/#{ontology}"
        end
      end
    end
  end
end
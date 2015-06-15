require "active_support/core_ext/string"

module PayloadHandler
  # A collection of serialized entities.
  class Payload
    attr_reader :entities, :errors

    def self.fetch(resources:, query_params: {})
      new(entities_params: [], resources: resources, extra_params: query_params)
        .load
    end

    # entities_params: an array of hashes representing entities
    # resources: a hash mapping types to classes
    # extra_params: a hash of parameters to be added to every entity
    def initialize(entities_params:, resources:, extra_params: {})
      @entities_params = entities_params
      @resources = resources
      @extra_params = extra_params
      @entities = []
      @errors = []
    end

    def save_entities
      @entities_params.each do |attrs|
        resource_class = get_resource_class(attrs)
        unless resource_class
          @errors << "unrecognized resource"
          next
        end

        resource = resource_class.new(deserialized(attrs))

        if resource.save
          @entities << resource.serialize
        else
          @errors << resource.errors.full_messages.join(", ")
        end
      end
    end

    # Fetch entities from the database.
    def load
      @entities = @resources.map do |_resource_type, resource_class|
        resource_class.where(@extra_params).map(&:serialize)
      end.flatten

      self
    end

    private

    def deserialized(attrs)
      attrs.each_with_object({}) do |a, h|
        k = a[0].to_s.underscore
        k = k == "id" ? "uuid" : k
        h[k] = a[1]
      end.merge(@extra_params)
    end

    def get_resource_class(attrs)
      @resources[(attrs[:type] || attrs["type"]).to_s]

    rescue
      nil
    end
  end
end

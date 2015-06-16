require "active_support/core_ext/string"

module PayloadHandler
  # A collection of serialized entities.
  class Payload
    attr_reader :entities, :errors

    def self.fetch(resource_types:, query_params: {})
      new(entities_params: [],
          resource_types: resource_types,
          extra_params: query_params)
        .load
    end

    # entities_params: an array of hashes representing entities
    # resource_types: a hash mapping types to classes
    # extra_params: a hash of parameters to be added to every entity
    def initialize(entities_params:, resource_types:, extra_params: {})
      @entities_params = entities_params
      @resource_types = resource_types
      @extra_params = extra_params
      @entities = []
      @errors = []
    end

    # Persist entities to the database.
    def save_entities
      @entities_params.each do |attributes|
        attrs = deserialized(attributes)
        resource = get_resource(attrs.delete("type"), attrs.delete("uuid"))

        next unless resource

        begin
          @entities << resource.update!(attrs).serialize
        rescue StandardError => error
          @errors << {
            id: resource.uuid,
            messages: resource.errors.full_messages.join(", "),
            error: error.message
          }
        end
      end
    end

    # Fetch entities from the database.
    def load
      @entities = @resource_types.map do |_resource_type, resource_class|
        resource_class.where(@extra_params).map(&:serialize)
      end.flatten

      self
    end

    private

    def deserialized(attributes)
      attributes.each_with_object({}) do |a, h|
        k = a[0].to_s.underscore
        k = k == "id" ? "uuid" : k
        h[k] = a[1]
      end.merge(@extra_params)
    end

    def get_resource_class(type)
      @resource_types[type.to_s] rescue nil
    end

    def get_resource(type, id)
      resource_class = get_resource_class(type)

      if resource_class
        resource_class.find_or_initialize_by(uuid: id)
      else
        @errors << "unrecognized resource"

        nil
      end
    end
  end
end

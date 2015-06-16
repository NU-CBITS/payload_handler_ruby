require "spec_helper"
require_relative "../../../lib/payload_handler.rb"

module PayloadHandler
  RSpec.describe Payload do
    def my_resource
      @my_resource ||= double("resource", serialize: { x: 1 })
    end

    def my_class
      double("resource class",
             find_or_initialize_by: my_resource,
             where: [my_resource])
    end

    describe ".fetch" do
      it "returns serialized resource classes" do
        resources = { "myType" => my_class }
        payload = Payload.fetch(resource_types: resources)

        expect(payload.entities.length).to eq 1
      end
    end

    describe "#save_entities" do
      context "when the type is unrecognized" do
        it "registers an error" do
          params = [{ type: "baz", foo: "bar" }]
          payload = Payload.new(extra_params: { participant_id: 1 },
                                entities_params: params,
                                resource_types: {})
          payload.save_entities

          expect(payload.entities.length).to eq 0
          expect(payload.errors.length).to eq 1
        end
      end

      context "when a type is recognized" do
        before do
          params = [{ type: "myType", foo: "bar" }]
          @payload = Payload.new(extra_params: { participant_id: 1 },
                                 entities_params: params,
                                 resource_types: { "myType" => my_class })
        end

        context "when the entities params are malformed" do
          it "registers an error" do
            payload = Payload.new(extra_params: { participant_id: 1 },
                                  entities_params: [[]],
                                  resource_types: {})
            payload.save_entities

            expect(payload.entities.length).to eq 0
            expect(payload.errors.length).to eq 1
          end
        end

        context "when its resource is saved successfully" do
          it "captures the serialized version" do
            allow(my_resource).to receive(:update!) { my_resource }
            @payload.save_entities

            expect(@payload.entities.length).to eq 1
            expect(@payload.entities.first).to eq(x: 1)
            expect(@payload.errors.length).to eq 0
          end
        end

        context "when its resource fails to save" do
          it "captures the error" do
            err = double("errors", full_messages: ["whoomp!"])
            allow(my_resource).to receive(:update!)
              .and_raise(StandardError.new("Oops"))
            allow(my_resource).to receive_messages(uuid: "uuid1", errors: err)
            @payload.save_entities

            expect(@payload.entities.length).to eq 0
            expect(@payload.errors.length).to eq 1
            expect(@payload.errors.first).to eq(
              id: "uuid1",
              messages: "whoomp!",
              error: "Oops"
            )
          end
        end
      end
    end
  end
end

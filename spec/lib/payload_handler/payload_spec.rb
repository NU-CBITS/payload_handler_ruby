require "spec_helper"
require_relative "../../../lib/payload_handler.rb"

module PayloadHandler
  RSpec.describe Payload do
    describe "#save_entities" do
      context "when the type is unrecognized" do
        it "registers an error" do
          params = [{ type: "baz", foo: "bar" }]
          payload = Payload.new(extra_params: { participant_id: 1 },
                                entities_params: params,
                                resources: {})
          payload.save_entities

          expect(payload.entities.length).to eq 0
          expect(payload.errors.length).to eq 1
        end
      end

      context "when a type is recognized" do
        def my_resource
          @my_resource ||= double("resource", serialize: { x: 1 })
        end

        def my_class
          double("resource class", new: my_resource)
        end

        before do
          params = [{ type: "myType", foo: "bar" }]
          @payload = Payload.new(extra_params: { participant_id: 1 },
                                 entities_params: params,
                                 resources: { "myType" => my_class })
        end

        context "when the entities params are malformed" do
          it "registers an error" do
            payload = Payload.new(extra_params: { participant_id: 1 },
                                  entities_params: [[]],
                                  resources: {})
            payload.save_entities

            expect(payload.entities.length).to eq 0
            expect(payload.errors.length).to eq 1
          end
        end

        context "when its resource is saved successfully" do
          it "captures the serialized version" do
            allow(my_resource).to receive(:save) { true }
            @payload.save_entities

            expect(@payload.entities.length).to eq 1
            expect(@payload.entities.first).to eq(x: 1)
            expect(@payload.errors.length).to eq 0
          end
        end

        context "when its resource fails to save" do
          it "captures the error" do
            err = double("errors", full_messages: ["whoomp!"])
            allow(my_resource).to receive_messages(save: false, errors: err)
            @payload.save_entities

            expect(@payload.entities.length).to eq 0
            expect(@payload.errors.length).to eq 1
            expect(@payload.errors.first).to eq("whoomp!")
          end
        end
      end
    end
  end
end

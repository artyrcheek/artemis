require 'active_support/core_ext/module/attribute_accessors'

describe "#{GraphQL::Client} Callbacks" do
  Client = Class.new(Artemis::Client) do
    def self.name
      'Github'
    end

    mattr_accessor :before_callback, :after_callback
    self.before_callback = nil
    self.after_callback = nil

    before_execute do |document, operation_name, variables, context|
      self.before_callback = document, operation_name, variables, context
    end

    after_execute do |data, errors, extensions|
      self.after_callback = data, errors, extensions
    end
  end

  Spotify = Class.new(Artemis::Client) do
    def self.name
      'Spotify'
    end

    before_execute do
      raise "this callback should not get invoked"
    end

    after_execute do
      raise "this callback should not get invoked"
    end
  end

  describe ".before_execute" do
    it "gets invoked before executing" do
      Client.repository(owner: "yuki24", name: "artemis", context: { user_id: 'yuki24' })

      document, operation_name, variables, context = Client.before_callback

      expect(document).to eq(Client::Repository.document)
      expect(operation_name).to eq('Client__Repository')
      expect(variables).to eq("name" => "artemis", "owner" => "yuki24")
      expect(context).to eq(user_id: 'yuki24')
    end
  end

  describe ".after_execute" do
    it "gets invoked after executing" do
      Client.user

      data, errors, extensions = Client.after_callback

      expect(data).to eq("test" => "data")
      expect(errors).to eq([])
      expect(extensions).to eq({})
    end
  end
end
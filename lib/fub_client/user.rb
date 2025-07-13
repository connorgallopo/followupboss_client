module FubClient
  class User < Resource
    # Add a method to get the relation if needed
    def self.relation
      Her::Model::Relation.new(self)
    end

    # Add convenience methods
    def self.active
      where(status: 'Active').to_a
    end

    def self.agents
      where(role: 'Agent').to_a
    end

    def self.by_email(email)
      where(email: email).first
    end

    def self.by_name(name)
      where(name: name).first
    end
  end
end

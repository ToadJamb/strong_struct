require 'active_model'

module StrongStruct
  module Core
    def new(*args)
      Class.new do
        include ActiveModel::Model
        args.each { |arg| attr_accessor arg }
      end
    end
  end

  extend Core
end

module StrongStruct
  module ClassMethods
    def accessors
      @accessors ||= []
    end

    private

    def add_accessor(accessor)
      accessors << accessor.to_s
    end

    def add_accessors
      attr_accessor(*accessors)
    end
  end

  module InstanceMethods
    def initialize(params = {})
      params.each do |attr, value|
        send "#{attr}=", value
      end if params
    end

    def attributes
      hash = {}
      self.class.accessors.each do |attr|
        hash[attr] = send(attr)
      end
      hash
    end
  end

  module Core
    def new(*args)
      Class.new do
        extend ClassMethods
        include InstanceMethods

        args.each { |arg| add_accessor(arg) }
        add_accessors
      end
    end
  end

  extend Core
end

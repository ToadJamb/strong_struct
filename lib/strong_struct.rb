# frozen_string_literal: true
module StrongStruct
  module Error
    class ClassInUseError < StandardError; end
  end

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
      accessors.each do |attr|
        hash[attr] = send(attr)
      end
      hash
    end

    private

    def accessors
      @accessors ||= get_accessors
    end

    def get_accessors
      klass = self.class

      attrs = []

      while klass.respond_to?(:accessors)
        if klass.accessors.empty?
          klass = klass.superclass
        else
          attrs = klass.accessors
          break
        end
      end

      attrs
    end
  end

  module Core
    def new(*args)
      name = name_from_params(args)

      if name && const_defined?(name)
        raise Error::ClassInUseError.new("Class already in use: #{name}")
      end

      klass = build_class(args)

      name ? Object.const_set(name, klass) : klass
    end

    private

    def build_class(attribute_names)
      Class.new do
        extend ClassMethods
        include InstanceMethods

        attribute_names.each { |attr| add_accessor(attr) }

        add_accessors
      end
    end

    def name_from_params(params)
      params.first.to_s.match(/^[A-Z]/) ? params.shift : nil
    end
  end

  extend Core
end

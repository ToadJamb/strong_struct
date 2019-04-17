# frozen_string_literal: true
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
      name = args.first.to_s.match(/^[A-Z]/) ? args.shift : nil

      klass = Class.new do
        extend ClassMethods
        include InstanceMethods

        args.each { |arg| add_accessor(arg) }
        add_accessors
      end

      name ? Object.const_set(name, klass) : klass
    end
  end

  extend Core
end

module StrongStruct
  module ClassMethods
    def accessors
      @accessors ||= []
    end

    def name
      return super unless defined?(@name)
      @name
    end

    def name=(value)
      if defined?(@name)
        raise "#{StrongStruct} pseudo-classes may not be renamed."
      end

      @name = value
    end

    def to_s
      return super unless defined?(@name)
      super.gsub(/^#<Class:/, "#<#{@name}:")
    end

    def inspect
      return super unless defined?(@name)
      super.gsub(/^#<Class:/, "#<#{@name}:")
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

    def to_s
      base = super
      klass_name = class_name
      return base unless klass_name != 'Object'
      base.gsub(/^#<#<Class:/, "#<#<#{klass_name}:")
    end


    def inspect
      base = super
      klass_name = class_name
      return base unless klass_name != 'Object'
      base.gsub(/^#<#<Class:/, "#<#<#{klass_name}:")
    end

    private

    def class_name
      klass = self.class
      return klass.name if klass.name

      while klass.superclass
        klass = klass.superclass
        break if klass.name
      end

      klass.name
    end

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

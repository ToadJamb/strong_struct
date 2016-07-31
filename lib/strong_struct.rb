module StrongStruct
  module Core
    def new(*args)
      Class.new do
        class << self
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

        args.each do |arg|
          add_accessor arg
        end

        add_accessors

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
    end
  end

  extend Core
end

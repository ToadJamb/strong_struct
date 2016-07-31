module StrongStruct
  module Core
    def new(*args)
      Class.new(Struct) do
        def initialize(params = {})
          params.each do |attr, value|
            send "#{attr}=", value
          end
        end
      end.new(*args)
    end
  end

  extend Core
end

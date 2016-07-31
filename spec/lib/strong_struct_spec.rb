require 'spec_helper'

RSpec.describe StrongStruct do
  let(:klass) { described_class.new :city, :state, :zip }
  let(:instance) { klass.new }

  describe '.new' do
    subject { klass }

    it 'returns a class' do
      expect(subject).to be_a Class
    end

    describe '.new' do
      subject { instance }

      it 'has strong attributes' do
        expect(subject).to respond_to :city
        expect(subject).to respond_to :city=

        expect(subject).to respond_to :state
        expect(subject).to respond_to :state=

        expect(subject).to respond_to :zip
        expect(subject).to respond_to :zip=

        expect(subject).to_not respond_to :fizz
        expect(subject).to_not respond_to :fizz=

        expect{subject.buzz}
          .to raise_error NoMethodError, /undefined method `buzz'/

        expect{subject.buzz = 'bzzz'}
          .to raise_error NoMethodError, /undefined method `buzz='/
      end
    end
  end
end

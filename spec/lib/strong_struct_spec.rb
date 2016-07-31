require 'spec_helper'

RSpec.describe StrongStruct do
  subject { instance }

  let(:base)     { described_class.new :city, 'state', :zip }
  let(:klass)    { base }
  let(:instance) { klass.new 'city' => 'Bucksnort', :state => 'TN' }

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

      it 'allows setting attributes' do
        expect(subject.city).to eq 'Bucksnort'
        subject.city = 'Memphis'
        expect(subject.city).to eq 'Memphis'
      end

      describe '.attributes' do
        subject { instance.attributes }

        it 'returns a hash of the current attributes and values' do
          expect(subject).to be_a Hash
          expect(subject.keys).to match_array ['city', 'state', 'zip']

          expect(subject['city']).to eq 'Bucksnort'
          expect(subject['state']).to eq 'TN'
          expect(subject['zip']).to eq nil
        end
      end
    end

    context 'given it is used as a base class' do
      subject { klass }

      let(:klass) { Class.new base }

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

        it 'allows setting attributes' do
          expect(subject.city).to eq 'Bucksnort'
          subject.city = 'Memphis'
          expect(subject.city).to eq 'Memphis'
        end

        describe '.attributes' do
          subject { instance.attributes }

          it 'returns a hash of the current attributes and values' do
            expect(subject).to be_a Hash
            expect(subject.keys).to match_array ['city', 'state', 'zip']

            expect(subject['city']).to eq 'Bucksnort'
            expect(subject['state']).to eq 'TN'
            expect(subject['zip']).to eq nil
          end
        end
      end
    end
  end
end

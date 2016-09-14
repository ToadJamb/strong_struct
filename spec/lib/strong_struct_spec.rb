require 'spec_helper'

RSpec.describe StrongStruct do
  subject { instance }

  let(:base)     { described_class.new :city, 'state', :zip }
  let(:klass)    { base }
  let(:instance) { klass.new 'city' => 'Bucksnort', :state => 'TN' }

  let(:class_name) { nil }

  shared_examples "a #{StrongStruct} class" do
    it 'is a class' do
      expect(subject).to be_a Class
    end

    describe '.new' do
      subject { instance }
      it_behaves_like 'a StrongStruct instance'
    end

    describe '.name=' do
      context 'given name is set a second time' do
        before { subject.name = 'Foo' }

        it 'raises an error' do
          expect{ subject.name = 'Bar' }
            .to raise_error(/#{StrongStruct}.*classes may not be renamed/)
        end
      end
    end

    shared_examples_for 'inspected class' do |class_name, expected|
      context "given the class name is #{class_name.inspect}" do
        before { subject.name = class_name } if class_name

        describe '.name' do
          it "returns #{class_name.inspect}" do
            expect = class_name ? expected : class_name
            expect(subject.name).to eq expect
          end
        end

        describe '.to_s' do
          it "returns #{class_name.inspect}" do
            expect(subject.to_s).to match(/^#<#{expected}:0x\w+>$/)
          end
        end

        describe '.inspect' do
          it "returns #{class_name.inspect}" do
            expect(subject.inspect).to match(/^#<#{expected}:0x\w+>$/)
          end
        end
      end
    end

    it_behaves_like 'inspected class', 'Foo', 'Foo'
    it_behaves_like 'inspected class', nil, 'Class'
  end

  shared_examples "a #{StrongStruct} instance" do
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

    shared_examples_for 'inspected instance' do |class_name, expected|
      context "given the class name is #{class_name.inspect}" do
        before { klass.name = class_name } if class_name

        describe '.name' do
          it "returns #{class_name.inspect}" do
            expect = class_name ? expected : class_name
            expect(subject.class.name).to eq expect
          end
        end

        describe '.to_s' do
          it "returns #{expected.inspect}" do
            expect(subject.to_s).to match(/^#<#<#{expected}:0x\w+>:0x\w+>$/)
          end
        end

        describe '.inspect' do
          it "returns #{class_name.inspect}" do
            expect(subject.inspect)
              .to match(/^#<#<#{expected}:0x\w+>:0x\w+ @city=/)
          end
        end
      end
    end

    it_behaves_like 'inspected instance', 'Foo', 'Foo'
    it_behaves_like 'inspected instance', nil, 'Class'
  end

  describe "a class created using #{StrongStruct}" do
    subject { base }

    it_behaves_like 'a StrongStruct class'

    describe 'given it is used as a base class' do
      let(:klass) { Class.new Class.new(base) }
      it_behaves_like 'a StrongStruct class'
    end

    context 'given it is used as a base class with a name' do
      subject { instance }

      let(:klass) { Class.new Class.new klass0 }

      let(:klass0) { base.name = 'Foo'; base }

      describe '.to_s' do
        it 'uses the name of the base class' do
          expect(subject.to_s).to match(/^#<#<Foo:0x\w+>:0x\w+>$/)
        end
      end

      describe '.inspect' do
        it 'uses the name of the base class' do
          expect(subject.inspect).to match(/^#<#<Foo:0x\w+>:0x\w+ @city=/)
        end
      end
    end
  end
end

# frozen_string_literal: true
require 'spec_helper'

module Count
  extend self
  attr_accessor :count
end

RSpec.describe StrongStruct do
  subject { instance }

  let(:base)     { described_class.new :city, 'state', :zip }
  let(:klass)    { base }
  let(:instance) { klass.new 'city' => 'Bucksnort', :state => 'TN' }

  shared_examples "primary attributes" do |name, cls, tos, inspect|
    describe '.name' do
      it "returns #{name}" do
        expect(subject.name).to match name if subject.respond_to?(:name)
      end
    end

    describe '.class' do
      it "matches #{cls}" do
        expect(subject.class.to_s).to match cls
      end
    end

    describe '.to_s' do
      it "matches #{tos}" do
        expect(subject.to_s).to match tos
      end
    end

    describe 'inspect' do
      it "returns a string matching #{inspect}" do
        expect(subject.inspect).to match inspect
      end
    end
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
  end

  base_regex     = '#<Class:0x\w+>'
  class_regex    = /^#{base_regex}$/

  base_instance  = "#<#{base_regex}:0x\\w+%s>"
  instance_regex = /^#{base_instance % ['']}$/

  context 'given only attributes' do
    let(:base)     { described_class.new :city, 'state', :zip }
    let(:klass)    { base }
    let(:instance) { klass.new 'city' => 'Bucksnort', :state => 'TN' }

    context 'given the class' do
      subject { klass }
      it_behaves_like 'primary attributes', nil, /^Class$/,
        class_regex, class_regex
    end

    context 'given an instance' do
      subject { instance }
      inspect_regex = /^#{base_instance % [' @city="Bucksnort", @state="TN"']}$/
      it_behaves_like 'primary attributes', nil, class_regex,
        instance_regex, inspect_regex
    end

    it_behaves_like "a #{StrongStruct} instance"
  end

  context 'given a class name' do
    let(:base_name) { "Place#{Count.count += 1}" }
    let(:base)      { described_class.new base_name, :city, 'state', :zip }
    let(:klass)     { base }
    let(:instance)  { klass.new 'city' => 'Bucksnort', :state => 'TN' }

    before { Count.count ||= 0 }

    context 'given the class' do
      subject { klass }
      it_behaves_like 'primary attributes', "Place", /^Class$/,
        /^Place\d+$/, /^Place\d+$/
    end

    context 'given an instance' do
      subject { instance }
      it_behaves_like 'primary attributes', nil, /^Place\d+$/,
        /^#<Place\d+:0x\w+>$/,
        /^#<Place\d+:0x\w+ @city="Bucksnort", @state="TN">$/
    end

    it_behaves_like "a #{StrongStruct} instance"
  end
end

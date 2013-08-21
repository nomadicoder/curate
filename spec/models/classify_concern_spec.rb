require 'spec_helper'

describe ClassifyConcern do
  subject { ClassifyConcern.new(curation_concern_type: curation_concern_type) }
  let(:curation_concern_type) { nil }

  describe '.all_curation_concern_classes' do
    it 'has GenericWork' do
      expect(ClassifyConcern.all_curation_concern_classes).to include(GenericWork)
      expect(ClassifyConcern.all_curation_concern_classes).to_not include('GenericWork')
    end
  end

  describe '#all_curation_concern_classes' do
    it 'has GenericWork' do
      expect(subject.all_curation_concern_classes).to include(GenericWork)
      expect(subject.all_curation_concern_classes).to_not include('GenericWork')
    end
  end


  describe 'with curation_concern_type: nil' do
    it 'is not valid' do
      expect(subject).to_not be_valid
    end

    it 'raises an error on .curation_concern_class' do
      expect{
        subject.curation_concern_class
      }.to raise_error(RuntimeError)
    end
  end

  describe 'with curation_concern_type: "GenericWork"' do
    let(:curation_concern_type) { "GenericWork" }

    it 'is valid if curation_concern_type is from the right list' do
      expect(subject).to be_valid
    end

    it 'has a <GenericWork> class for curation_concern_class' do
      expect(subject.curation_concern_class).to eq(GenericWork)
    end
  end

  describe '#upcoming_concerns' do
    it 'yields two elements' do
      expect(subject.upcoming_concerns).to be_kind_of(Array)
    end
  end
end

require 'spec_helper'

describe Event do
  subject { event }

  context 'create' do
    describe 'with no contenders' do
      let(:event) { FactoryGirl.build :event, contenders: [] }
      it { should_not be_valid }
    end

    describe 'with future date' do
      let(:event) { FactoryGirl.build :event, start_date: 1.day.from_now }
      it { should be_valid }
    end

    describe 'with past date' do
      let(:event) { FactoryGirl.build :event, start_date: 1.day.ago }
      it { should_not be_valid }
    end
  end

  describe 'scope' do
    before do
      2.times { FactoryGirl.create :event, finished?: true }
      3.times { FactoryGirl.create :event, finished?: false }
    end

    describe '.finished' do
      let(:returned_events) { Event.finished }
      it 'returns 2 records' do
        expect(returned_events.count).to eql(2)
      end
      it 'returns all records that are finished' do
        returned_events.each { |e| expect(e.finished?).to eql(true) }
      end
    end

    describe '.unfinished' do
      let(:returned_events) { Event.unfinished }
      it 'returns 3 records' do
        expect(returned_events.count).to eql(3)
      end
      it 'returns all records that are unfinished' do
        returned_events.each { |e| expect(e.finished?).to eql(false) }
      end
    end
  end

end

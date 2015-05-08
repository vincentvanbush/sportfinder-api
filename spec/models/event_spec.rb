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
      let(:finished_events) { Event.finished(true) }
      let(:unfinished_events) { Event.finished(false) }
      it 'returns 2 records for true' do
        expect(finished_events.count).to eql(2)
      end
      it 'returns 3 records for false' do
        expect(unfinished_events.count).to eql(3)
      end
      it 'returns all records that are finished' do
        finished_events.each { |e| expect(e.finished?).to eql(true) }
      end
      it 'returns all records that are unfinished' do
        unfinished_events.each { |e| expect(e.finished?).to eql(false) }
      end
    end
  end

end

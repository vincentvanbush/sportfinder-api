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

end

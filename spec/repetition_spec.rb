require 'spec_helper'

describe Repetition do
  before :each do
    class Test
      attr_accessor :easiness_factor, :number_repetitions, :quality_of_last_recall, :next_repetition, :repetition_interval, :last_studied

      include Repetition
    end
    @card = Test.new
    @card.reset_spaced_repetition_data
  end

  it 'has a version number' do
    expect(Repetition::VERSION).not_to be nil
  end

  it 'works when included' do
    expect(@card).to respond_to :easiness_factor, :number_repetitions, :quality_of_last_recall, :next_repetition, :repetition_interval, :last_studied
  end

  it 'initializes values properly' do
    expect(@card.easiness_factor).to eq(2.5)
    expect(@card.number_repetitions).to eq(0)
    expect(@card.quality_of_last_recall).to be_nil
    expect(@card.next_repetition).to be_nil
    expect(@card.repetition_interval).to be_nil
    expect(@card.last_studied).to be_nil
  end

  it 'schedules for tommorow when interval = 0 and quality = 4' do
    @card.process_recall_result(4)

    expect(@card.number_repetitions).to eq(1)
    expect(@card.repetition_interval).to eq(1)
    expect(@card.last_studied).to eq(Date.today)
    expect(@card.next_repetition).to eq(Date.today + 1)
    expect(@card.easiness_factor).to be_within(2.5).of(0.01)
  end

  it 'schedules for 6 days when interval = 1 and quality = 4' do
    @card.process_recall_result(4)
    @card.process_recall_result(4)

    expect(@card.number_repetitions).to eq(2)
    expect(@card.repetition_interval).to eq(6)
    expect(@card.last_studied).to eq(Date.today)
    expect(@card.next_repetition).to eq(Date.today + 6)
    expect(@card.easiness_factor).to be_within(2.5).of(0.01)
  end

  it 'reports as scheduled for today' do
    @card.next_repetition = Date.today
    expect(@card.scheduled_to_recall?).to be true

    @card.next_repetition = Date.today - 1
    expect(@card.scheduled_to_recall?).to be true
  end

  it 'reports as not scheduled when next repetition is later than today' do
    @card.next_repetition = nil
    expect(@card.scheduled_to_recall?).to be false

    @card.next_repetition = Date.today + 1
    expect(@card.scheduled_to_recall?).to be false

    @card.next_repetition = Date.today + 99
    expect(@card.scheduled_to_recall?).to be false
  end

  it 'requires repeating cards when quality == 3' do
    @card.process_recall_result(3)
    expect(@card.next_repetition).to eq(Date.today)

    @card.process_recall_result(3)
    expect(@card.next_repetition).to eq(Date.today)

    @card.process_recall_result(4)
    expect(@card.next_repetition).to eq(Date.today + 1)
  end
end

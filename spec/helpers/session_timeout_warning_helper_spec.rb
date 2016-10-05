require 'rails_helper'

describe SessionTimeoutWarningHelper do
  describe '#time_left_in_session' do
    it 'returns time left before timeout' do
      Timecop.freeze do
        allow(Figaro.env).
          to receive(:session_check_frequency).and_return(1.minute)
        allow(Figaro.env).
          to receive(:session_check_delay).and_return(2.minutes)
        allow(Figaro.env).
          to receive(:session_timeout_warning_seconds).and_return(3.minutes)

        expect(helper.time_left_in_session).to eq(
          distance_of_time_in_words(time_between_warning_and_timeout)
        )

        time_travel = 1
        Timecop.travel(Time.current + time_travel.seconds)
        expect(helper.time_left_in_session).to eq(
          distance_of_time_in_words(
            time_between_now_and_timeout(time_since_warning: time_travel)
          )
        )
      end
    end
  end

  def time_between_now_and_timeout(time_since_warning:)
    Figaro.env.session_timeout_warning_seconds - time_since_warning
  end

  def time_between_warning_and_timeout
    Figaro.env.session_timeout_warning_seconds
  end
end


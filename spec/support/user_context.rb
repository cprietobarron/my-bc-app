# frozen_string_literal: true

RSpec.shared_context "with user context" do
  let(:user) { create(:user) }

  let!(:channel) { create(:channel, user: user, status: :disabled, channel_id: 11_131) } # rubocop: disable RSpec/LetSetup
end

# frozen_string_literal: true

module TestHelper
  def load_json(file_name, symbolize_names = true)
    file = File.join('spec/fixtures', file_name)
    JSON.parse(File.read(file), symbolize_names: symbolize_names)
  end

  def parse_json(json_string)
    JSON.parse(json_string, symbolize_names: true)
  end
end

RSpec.shared_context 'shared_fixtures' do
  let(:bigcommerce_payload) do
    {
      user: { id: 1, email: 'merchant@bigcommerce.com' },
      owner: { id: 1, email: 'merchant@bigcommerce.com' },
      context: 'stores/abcde12345',
      store_hash: 'abcde12345',
      timestamp: 1_602_800_465.0540502
    }
  end
end

Ransack.configure do |config|
  config.add_predicate 'date_lteq',
  arel_predicate: 'lteq',
  formatter: proc { |v| Time.zone.parse(v) + 1.day },
  validator: proc { |v| v.present? },
  type: :string

  config.add_predicate 'date_gteq',
  arel_predicate: 'gteq',
  formatter: proc { |v| Time.zone.parse(v) },
  validator: proc { |v| v.present? },
  type: :string
end